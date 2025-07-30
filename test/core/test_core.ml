(** Tests for the Core module *)

open Alcotest

let test_type () =
  (* Test basic Core.t record type functionality *)
  let empty_core =
    {
      Core.site =
        {
          Core.Site.name = "Test Site";
          title = "Test Site";
          tagline = "A test tagline";
          description = "A test site";
          author = "Test Author";
          author_email = "test@example.com";
          url = "http://localhost";
          social = None;
          analytics = None;
          footer = { copyright = "© 2024 Test"; links = [] };
          posts_per_page = Some 10;
        };
      blog_posts = [];
      authors = [];
      static_pages = [];
      papers = [];
      files = [];
    }
  in
  check string "site name" "Test Site" empty_core.site.name;
  check int "empty blog posts" 0 (List.length empty_core.blog_posts);
  check int "empty authors" 0 (List.length empty_core.authors);
  check int "empty static pages" 0 (List.length empty_core.static_pages);
  check int "empty papers" 0 (List.length empty_core.papers);
  check int "empty files" 0 (List.length empty_core.files)

let test_pp () =
  (* Test pretty printing *)
  let core_data =
    {
      Core.site =
        {
          Core.Site.name = "Test Site";
          title = "Test Site";
          tagline = "A test tagline";
          description = "A test site";
          author = "Test Author";
          author_email = "test@example.com";
          url = "http://localhost";
          social = None;
          analytics = None;
          footer = { copyright = "© 2024 Test"; links = [] };
          posts_per_page = Some 5;
        };
      blog_posts = [];
      authors = [];
      static_pages = [];
      papers = [];
      files = [];
    }
  in
  let output = Core.pp core_data in
  check bool "pp output contains site" true
    (Astring.String.is_infix ~affix:"Test Site" output);
  check bool "pp output contains blog_posts" true
    (Astring.String.is_infix ~affix:"blog_posts" output)

let test_module_exports () =
  (* Test that all expected modules are exported *)
  let _ = Core.Site.pp in
  let _ = Core.Blog.pp in
  let _ = Core.Author.pp in
  let _ = Core.Page.pp in
  let _ = Core.Static.pp in
  let _ = Core.Paper.pp in
  let _ = Core.File.pp in
  let _ = Core.Date.pretty_date in
  let _ = Core.Pp.str in
  ()

let suite =
  [
    ( "core",
      [
        test_case "core type" `Quick test_type;
        test_case "core pp" `Quick test_pp;
        test_case "module exports" `Quick test_module_exports;
      ] );
  ]
