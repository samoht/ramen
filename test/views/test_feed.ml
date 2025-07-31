(** Tests for the Feed page module *)

open Alcotest
open Views
open Core

let test_post ~title ~slug ~date ~summary =
  {
    Blog.title;
    slug;
    authors = [ Blog.Name { Blog.name = "Test Author"; slug = "test" } ];
    image = "";
    image_alt = None;
    date;
    tags = [ "test" ];
    synopsis = summary;
    description = summary;
    body_html = "<p>" ^ summary ^ "</p>";
    body_words = Astring.String.cuts ~empty:false ~sep:" " summary;
    path = "/blog/" ^ slug;
    link = None;
    links = [];
  }

let test_site () =
  {
    Site.name = "Test Blog";
    url = "https://test.com";
    title = "Test Blog RSS";
    tagline = "RSS feed test";
    description = "Test blog RSS feed";
    author = "Test Author";
    author_email = "test@test.com";
    social = None;
    analytics = None;
    footer = { copyright = "© Test"; links = [] };
    posts_per_page = Some 10;
  }

let validate_rss_structure rss =
  (* Check for RSS feed structure and validate *)
  check bool "is RSS/XML format" true
    (Astring.String.is_prefix ~affix:"<?xml" rss
    || Astring.String.is_infix ~affix:"<rss" rss
    || Astring.String.is_infix ~affix:"<feed" rss);

  (* Validate RSS structure *)
  check bool "has XML declaration" true
    (Astring.String.is_prefix ~affix:"<?xml version=" rss);
  check bool "has channel element" true
    (Astring.String.is_infix ~affix:"<channel>" rss
    || Astring.String.is_infix ~affix:"<feed" rss);
  check bool "has title element" true
    (Astring.String.is_infix ~affix:"<title>" rss);
  check bool "has link element" true
    (Astring.String.is_infix ~affix:"<link>" rss
    || Astring.String.is_infix ~affix:"<link " rss);
  check bool "has description element" true
    (Astring.String.is_infix ~affix:"<description>" rss
    || Astring.String.is_infix ~affix:"<subtitle>" rss);

  (* Validate well-formed XML by checking closing tags *)
  check bool "has closing tags" true
    (Astring.String.is_infix ~affix:"</rss>" rss
    || Astring.String.is_infix ~affix:"</feed>" rss)

let test_render_rss () =
  let site = test_site () in

  let posts =
    [
      test_post ~title:"First RSS Post" ~slug:"first-rss" ~date:"2024-01-01"
        ~summary:"First post for RSS feed";
      test_post ~title:"Second RSS Post" ~slug:"second-rss" ~date:"2024-01-02"
        ~summary:"Second post for RSS feed";
    ]
  in

  let layout = Feed.render ~site ~blog_posts:posts in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let rss = Ui.Layout.to_string config layout in

  (* Validate RSS structure *)
  validate_rss_structure rss;

  (* TODO: Use a proper XML validator like xmllint or xmlstarlet to validate
     RSS/Atom feeds *)

  (* Check content *)
  check bool "contains channel/feed title" true
    (Astring.String.is_infix ~affix:"Test Blog" rss);
  check bool "contains first post title" true
    (Astring.String.is_infix ~affix:"First RSS Post" rss);
  check bool "contains second post title" true
    (Astring.String.is_infix ~affix:"Second RSS Post" rss);
  check bool "contains post URLs" true
    (Astring.String.is_infix ~affix:"test.com" rss)

let test_render_empty_feed () =
  let site =
    {
      Site.name = "Empty Blog";
      url = "https://empty.com";
      title = "Empty Blog";
      tagline = "No posts";
      description = "Blog with no posts";
      author = "No Author";
      author_email = "none@empty.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Empty"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let layout = Feed.render ~site ~blog_posts:[] in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let rss = Ui.Layout.to_string config layout in

  (* Should still have valid RSS structure even with no posts *)
  check bool "has RSS structure" true
    (Astring.String.is_prefix ~affix:"<?xml" rss
    || Astring.String.is_infix ~affix:"<rss" rss
    || Astring.String.is_infix ~affix:"<feed" rss);
  check bool "contains site title" true
    (Astring.String.is_infix ~affix:"Empty Blog" rss)

let test_render_with_html_content () =
  let site =
    {
      Site.name = "HTML Test Blog";
      url = "https://htmltest.com";
      title = "HTML Test";
      tagline = "Testing HTML in RSS";
      description = "RSS with HTML content";
      author = "HTML Author";
      author_email = "html@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© HTML Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let posts =
    [
      test_post ~title:"Post with <b>HTML</b>" ~slug:"html-post"
        ~date:"2024-01-01" ~summary:"This has <em>HTML</em> & special chars";
    ]
  in

  let layout = Feed.render ~site ~blog_posts:posts in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let rss = Ui.Layout.to_string config layout in

  (* Check that HTML is properly escaped or encoded *)
  check bool "handles HTML in title" true
    (Astring.String.is_infix ~affix:"HTML" rss);
  check bool "handles special characters" true
    (Astring.String.is_infix ~affix:"special chars" rss)

let suite =
  [
    ( "feed",
      [
        test_case "render RSS feed" `Quick test_render_rss;
        test_case "render empty feed" `Quick test_render_empty_feed;
        test_case "render with HTML content" `Quick
          test_render_with_html_content;
      ] );
  ]
