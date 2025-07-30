(** Tests for the Sitemap page module *)

open Alcotest
open Views
open Core

let make_test_site ~name ~url =
  {
    Site.name;
    url;
    title = name;
    tagline = "Testing sitemaps";
    description = "Test sitemap generation";
    author = "Sitemap Author";
    author_email = "sitemap@test.com";
    social = None;
    analytics = None;
    footer = { copyright = "© Sitemap"; links = [] };
    posts_per_page = Some 10;
  }

let validate_sitemap_structure xml =
  (* Check for XML sitemap structure and validate *)
  check bool "is XML format" true (Astring.String.is_prefix ~affix:"<?xml" xml);

  (* Validate sitemap XML structure *)
  check bool "has XML declaration" true
    (Astring.String.is_prefix ~affix:"<?xml version=\"1.0\"" xml);
  check bool "has urlset element" true
    (Astring.String.is_infix ~affix:"<urlset" xml);
  check bool "has xmlns attribute" true
    (Astring.String.is_infix ~affix:"xmlns=" xml
    || Astring.String.is_infix ~affix:"http://www.sitemaps.org/schemas/sitemap"
         xml);

  (* Check for URL entries *)
  check bool "has url elements" true
    (Astring.String.is_infix ~affix:"<url>" xml);
  check bool "has loc elements" true
    (Astring.String.is_infix ~affix:"<loc>" xml);
  check bool "has closing loc tags" true
    (Astring.String.is_infix ~affix:"</loc>" xml);
  check bool "has closing url tags" true
    (Astring.String.is_infix ~affix:"</url>" xml);

  (* Validate well-formed XML *)
  check bool "has closing urlset tag" true
    (Astring.String.is_infix ~affix:"</urlset>" xml)

let test_render_sitemap () =
  let site =
    make_test_site ~name:"Sitemap Test" ~url:"https://sitemaptest.com"
  in

  let pages =
    [
      Core.Page.Index;
      Core.Page.Blog_feed;
      Core.Page.Blog_index
        { posts = []; filter = None; page = 1; all_posts = [] };
      Core.Page.Papers;
      Core.Page.Error;
    ]
  in

  let layout = Sitemap.render ~site ~pages in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let xml = Ui.Layout.to_string config layout in

  (* Validate sitemap structure *)
  validate_sitemap_structure xml;

  (* TODO: Use a proper XML validator like xmllint to validate against sitemap
     XSD schema *)

  (* Check content *)
  check bool "has site URL" true
    (Astring.String.is_infix ~affix:"sitemaptest.com" xml)

let test_render_with_blog_posts () =
  let site =
    make_test_site ~name:"Blog Sitemap" ~url:"https://blogsitemap.com"
  in

  let blog_post =
    {
      Blog.title = "Test Post";
      slug = "test-post";
      authors = [];
      image = "";
      image_alt = None;
      date = "2024-01-01";
      tags = [];
      synopsis = "Test";
      description = "Test";
      body_html = "<p>Test</p>";
      body_words = [ "Test" ];
      path = "/blog/test-post";
      link = None;
      links = [];
    }
  in

  let pages = [ Core.Page.Index; Core.Page.Blog_post blog_post ] in

  let layout = Sitemap.render ~site ~pages in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let xml = Ui.Layout.to_string config layout in

  check bool "contains blog post URL" true
    (Astring.String.is_infix ~affix:"test-post" xml);
  check bool "has multiple URLs" true
    (Astring.String.is_infix ~affix:"<url" xml)

let test_render_empty_sitemap () =
  let site =
    {
      Site.name = "Empty Sitemap";
      url = "https://empty.com";
      title = "Empty";
      tagline = "No pages";
      description = "Empty sitemap";
      author = "Empty Author";
      author_email = "empty@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Empty"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let layout = Sitemap.render ~site ~pages:[] in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let xml = Ui.Layout.to_string config layout in

  (* Should still have valid XML structure *)
  check bool "has XML declaration" true
    (Astring.String.is_prefix ~affix:"<?xml" xml);
  check bool "has urlset" true (Astring.String.is_infix ~affix:"urlset" xml)

let suite =
  [
    ( "sitemap",
      [
        test_case "render sitemap" `Quick test_render_sitemap;
        test_case "render with blog posts" `Quick test_render_with_blog_posts;
        test_case "render empty sitemap" `Quick test_render_empty_sitemap;
      ] );
  ]
