(** Tests for the Page module *)

open Alcotest

let page_testable = testable (Fmt.of_to_string Core.Page.pp) ( = )

let test_url () =
  check string "index url" "/" (Core.Page.url Core.Page.Index);
  check string "blog feed url" "/blog/feed.xml"
    (Core.Page.url Core.Page.Blog_feed);
  check string "papers url" "/papers" (Core.Page.url Core.Page.Papers);
  check string "error url" "/404.html" (Core.Page.url Core.Page.Error);
  check string "sitemap url" "/sitemap.xml" (Core.Page.url Core.Page.Sitemap);
  check string "robots url" "/robots.txt" (Core.Page.url Core.Page.Robots_txt)

let test_static_page () =
  let static =
    {
      Core.Static.title = "About Us";
      description = Some "Learn more about our team";
      layout = "default";
      name = "about";
      body_html = "<p>About content here</p>";
      in_nav = true;
      nav_order = Some 1;
    }
  in

  check string "static title" "About Us" static.Core.Static.title;
  check string "static name" "about" static.Core.Static.name;
  check bool "in navigation" true static.Core.Static.in_nav;
  check (option int) "nav order" (Some 1) static.Core.Static.nav_order;

  let page = Core.Page.Static_page static in
  check string "static page url" "/about" (Core.Page.url page)

let test_blog_page () =
  let post =
    {
      Core.Blog.authors =
        [ Core.Blog.Name { name = "Author"; slug = "author" } ];
      title = "Test Post";
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-01";
      slug = "test-post";
      tags = [];
      synopsis = "Test";
      description = "Test";
      body_html = "<p>Test</p>";
      body_words = [ "Test" ];
      path = "test.md";
      link = None;
      links = [];
    }
  in

  let page = Core.Page.Blog_post post in
  check string "blog post url" "/blog/test-post" (Core.Page.url page)

let test_blog_index_page () =
  let index =
    { Core.Blog.filter = None; page = 2; posts = []; all_posts = [] }
  in

  let page = Core.Page.Blog_index index in
  check string "blog index page 2 url" "/blog/page/2" (Core.Page.url page);

  let index_with_filter =
    { index with filter = Some (Core.Blog.Tag "ocaml") }
  in
  let page_with_filter = Core.Page.Blog_index index_with_filter in
  check string "blog index with tag url" "/blog/tag/ocaml/page/2"
    (Core.Page.url page_with_filter)

let test_pp () =
  let pp_output = Core.Page.pp Core.Page.Index in
  check string "index pp" "Index" pp_output;

  let static =
    {
      Core.Static.title = "Test";
      description = None;
      layout = "default";
      name = "test";
      body_html = "<p>Test</p>";
      in_nav = false;
      nav_order = None;
    }
  in

  let static_pp = Core.Page.pp (Core.Page.Static_page static) in
  check bool "static page pp" true
    (Astring.String.is_infix ~affix:"Static_page" static_pp)

let suite =
  [
    ( "page",
      [
        test_case "page urls" `Quick test_url;
        test_case "static page" `Quick test_static_page;
        test_case "blog page" `Quick test_blog_page;
        test_case "blog index page" `Quick test_blog_index_page;
        test_case "pretty printing" `Quick test_pp;
      ] );
  ]
