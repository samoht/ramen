(** Tests for the Post page module *)

open Alcotest
open Views
open Core

let test_author name : Blog.author =
  Author
    {
      name;
      title = Some "Test Role";
      hidden = false;
      avatar = None;
      slug = String.lowercase_ascii name;
      aliases = [];
      homepage = None;
    }

let blog_post ~title ~date ~content () =
  {
    Blog.title;
    slug =
      String.lowercase_ascii (String.map (function ' ' -> '-' | c -> c) title);
    authors = [ test_author "Test Author" ];
    image = "";
    image_alt = None;
    date;
    tags = [ "test"; "ocaml" ];
    synopsis = content;
    description = "Test post description";
    body_html =
      "<h2 id=\"introduction\">Introduction</h2>\n<p>" ^ content
      ^ "</p>\n<h2 id=\"main-content\">Main Content</h2>";
    body_words = Astring.String.cuts ~empty:false ~sep:" " content;
    path =
      "/blog/"
      ^ String.lowercase_ascii
          (String.map (function ' ' -> '-' | c -> c) title);
    link = None;
    links = [];
  }

let test_render_basic_post () =
  let site =
    {
      Site.name = "Test Blog";
      url = "https://test.com";
      title = "Test Blog";
      tagline = "A test blog";
      description = "Test blog";
      author = "Site Author";
      author_email = "site@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let post =
    blog_post ~title:"Test Post" ~date:"2024-01-01"
      ~content:"This is the post content." ()
  in

  let layout = Post.render ~site post in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "contains post title" true
    (Astring.String.is_infix ~affix:"Test Post" html);
  check bool "contains post date" true
    (Astring.String.is_infix ~affix:"2024" html);
  check bool "contains author" true
    (Astring.String.is_infix ~affix:"Test Author" html);
  check bool "contains tags" true (Astring.String.is_infix ~affix:"ocaml" html);
  check bool "contains content" true
    (Astring.String.is_infix ~affix:"This is the post content" html)

let test_render_with_long_content () =
  let site =
    {
      Site.name = "TOC Blog";
      url = "https://toc.com";
      title = "TOC Blog";
      tagline = "Blog with TOC";
      description = "Test TOC";
      author = "TOC Author";
      author_email = "toc@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© TOC"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let post =
    blog_post ~title:"Long Post" ~date:"2024-01-01"
      ~content:"Long content with sections." ()
  in

  let layout = Post.render ~site post in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  (* Should have headings in content *)
  check bool "has Introduction heading" true
    (Astring.String.is_infix ~affix:"Introduction" html);
  check bool "has Main Content heading" true
    (Astring.String.is_infix ~affix:"Main Content" html)

let test_render_multiple_tags () =
  let site =
    {
      Site.name = "Series Blog";
      url = "https://series.com";
      title = "Series Blog";
      tagline = "Blog with series";
      description = "Test series";
      author = "Series Author";
      author_email = "series@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Series"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let post =
    blog_post ~title:"OCaml Tutorial" ~date:"2024-01-02"
      ~content:"Learning OCaml basics." ()
  in

  let layout = Post.render ~site post in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  (* Should show tags *)
  check bool "has test tag" true (Astring.String.is_infix ~affix:"test" html);
  check bool "has ocaml tag" true (Astring.String.is_infix ~affix:"ocaml" html)

let test_file_function () =
  let post =
    blog_post ~title:"File Test" ~date:"2024-01-01"
      ~content:"Testing file function." ()
  in

  let file_path = Post.file post in
  check bool "has file path" true (String.length file_path > 0)

let suite =
  [
    ( "post",
      [
        test_case "render basic post" `Quick test_render_basic_post;
        test_case "render with long content" `Quick
          test_render_with_long_content;
        test_case "render multiple tags" `Quick test_render_multiple_tags;
        test_case "file function" `Quick test_file_function;
      ] );
  ]
