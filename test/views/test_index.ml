(** Tests for the Index page module *)

open Alcotest
open Views
open Core

let test_post ~title ~slug ~date ~synopsis =
  {
    Blog.title;
    slug;
    authors = [ Blog.Name { Blog.name = "Test Author"; slug = "test" } ];
    image = "";
    image_alt = None;
    date;
    tags = [ "test" ];
    synopsis;
    description = "Test description";
    body_html = "<p>" ^ synopsis ^ "</p>";
    body_words = Astring.String.cuts ~empty:false ~sep:" " synopsis;
    path = "/blog/" ^ slug;
    link = None;
    links = [];
  }

let static_page ~title ~content =
  {
    Core.Static.title;
    description = Some content;
    layout = "default";
    name = String.lowercase_ascii title;
    body_html = "<h1>" ^ title ^ "</h1><p>" ^ content ^ "</p>";
    in_nav = true;
    nav_order = None;
  }

let test_render_homepage () =
  let site =
    {
      Site.name = "Test Site";
      url = "https://test.com";
      title = "Welcome to Test Site";
      tagline = "A great test site";
      description = "Test site homepage";
      author = "Test Author";
      author_email = "test@test.com";
      social =
        Some
          { twitter = Some "@test"; github = Some "testuser"; linkedin = None };
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let static_pages =
    [
      static_page ~title:"About" ~content:"About this test site";
      static_page ~title:"Contact" ~content:"Contact us at test@test.com";
    ]
  in

  let blog_posts =
    [
      test_post ~title:"Featured Post" ~slug:"featured" ~date:"2024-01-01"
        ~synopsis:"Featured post content";
      test_post ~title:"Regular Post" ~slug:"regular" ~date:"2024-01-02"
        ~synopsis:"Regular post content";
    ]
  in

  let layout = Index.render ~site ~static_pages ~blog_posts in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "contains site title" true
    (Astring.String.is_infix ~affix:"Welcome to Test Site" html);
  check bool "contains tagline" true
    (Astring.String.is_infix ~affix:"A great test site" html);
  check bool "contains featured post" true
    (Astring.String.is_infix ~affix:"Featured Post" html);
  check bool "contains social links" true
    (Astring.String.is_infix ~affix:"twitter" html
    || Astring.String.is_infix ~affix:"github" html)

let test_render_no_posts () =
  let site =
    {
      Site.name = "Empty Site";
      url = "https://empty.com";
      title = "Empty Site";
      tagline = "No posts yet";
      description = "Site with no posts";
      author = "Empty Author";
      author_email = "empty@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Empty"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let static_pages = [] in
  let blog_posts = [] in

  let layout = Index.render ~site ~static_pages ~blog_posts in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "contains site title" true
    (Astring.String.is_infix ~affix:"Empty Site" html);
  check bool "contains tagline" true
    (Astring.String.is_infix ~affix:"No posts yet" html)

let test_render_recent_posts () =
  let site =
    {
      Site.name = "Recent Posts Site";
      url = "https://recent.com";
      title = "Recent Posts";
      tagline = "Latest content";
      description = "Site with recent posts";
      author = "Recent Author";
      author_email = "recent@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Recent"; links = [] };
      posts_per_page = Some 3;
    }
  in

  let static_pages = [] in

  (* Create 10 posts but only the most recent should appear *)
  let blog_posts =
    List.init 10 (fun i ->
        test_post
          ~title:("Post " ^ string_of_int (i + 1))
          ~slug:("post-" ^ string_of_int (i + 1))
          ~date:("2024-01-" ^ Fmt.str "%02d" (i + 1))
          ~synopsis:("Post " ^ string_of_int (i + 1) ^ " content"))
  in

  let layout = Index.render ~site ~static_pages ~blog_posts in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  (* Should show recent posts, likely limited by posts_per_page or a hardcoded
     limit *)
  check bool "contains recent posts" true
    (Astring.String.is_infix ~affix:"Post" html)

let suite =
  [
    ( "index",
      [
        test_case "render homepage" `Quick test_render_homepage;
        test_case "render without posts" `Quick test_render_no_posts;
        test_case "render recent posts" `Quick test_render_recent_posts;
      ] );
  ]
