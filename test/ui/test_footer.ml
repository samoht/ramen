(** Tests for the Footer component *)

open Alcotest

let test_render () =
  let site =
    {
      Core.Site.name = "Test Site";
      url = "https://test.com";
      title = "Test";
      tagline = "Testing";
      description = "Test site";
      author = "Test Author";
      author_email = "test@test.com";
      social =
        Some
          { twitter = Some "@test"; github = Some "testuser"; linkedin = None };
      analytics = None;
      footer =
        {
          copyright = "© 2024 Test";
          links =
            [
              { href = "/privacy"; text = "Privacy" };
              { href = "/terms"; text = "Terms" };
            ];
        };
      posts_per_page = Some 10;
    }
  in

  let footer = { Ui.Footer.site; palette = Ui.Colors.default_palette } in

  let html = Ui.Footer.render footer in
  let html_str = Ui.Html.to_string html in

  check bool "contains copyright" true
    (Astring.String.is_infix ~affix:"© 2024 Test" html_str);
  check bool "contains privacy link" true
    (Astring.String.is_infix ~affix:"Privacy" html_str);
  check bool "contains terms link" true
    (Astring.String.is_infix ~affix:"Terms" html_str);
  check bool "contains twitter icon" true
    (Astring.String.is_infix ~affix:"twitter" html_str);
  check bool "contains github icon" true
    (Astring.String.is_infix ~affix:"github" html_str)

let test_render_no_social () =
  let site =
    {
      Core.Site.name = "No Social Site";
      url = "https://nosocial.com";
      title = "No Social";
      tagline = "Testing no social";
      description = "No social test site";
      author = "Test Author";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© 2024 No Social"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let footer = { Ui.Footer.site; palette = Ui.Colors.default_palette } in

  let html = Ui.Footer.render footer in
  let html_str = Ui.Html.to_string html in

  check bool "contains copyright" true
    (Astring.String.is_infix ~affix:"© 2024 No Social" html_str);
  check bool "no twitter link" false
    (Astring.String.is_infix ~affix:"twitter.com" html_str);
  check bool "no github link" false
    (Astring.String.is_infix ~affix:"github.com" html_str)

let suite =
  [
    ( "footer",
      [
        test_case "render" `Quick test_render;
        test_case "render without social" `Quick test_render_no_social;
      ] );
  ]
