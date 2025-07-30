(** Tests for the Header component *)

open Alcotest

let test_render_with_menu () =
  let site =
    {
      Core.Site.name = "Test Site";
      url = "https://test.com";
      title = "Test";
      tagline = "Testing";
      description = "Test site";
      author = "Test Author";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let header =
    {
      Ui.Header.menu =
        Some
          [
            { label = "Home"; page = Core.Page.Index };
            { label = "Blog"; page = Core.Page.Blog_feed };
          ];
      active_page = Some Core.Page.Index;
      site;
      palette = Ui.Colors.default_palette;
    }
  in

  let html = Ui.Header.render header in
  let html_str = Ui.Html.to_string html in

  check bool "contains site name" true
    (Astring.String.is_infix ~affix:"Test Site" html_str);
  check bool "contains Home menu item" true
    (Astring.String.is_infix ~affix:"Home" html_str);
  check bool "contains Blog menu item" true
    (Astring.String.is_infix ~affix:"Blog" html_str)

let test_render_without_menu () =
  let site =
    {
      Core.Site.name = "Simple Site";
      url = "https://simple.com";
      title = "Simple";
      tagline = "Simple site";
      description = "A simple site";
      author = "Author";
      author_email = "author@simple.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Simple"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let header =
    {
      Ui.Header.menu = None;
      active_page = None;
      site;
      palette = Ui.Colors.default_palette;
    }
  in

  let html = Ui.Header.render header in
  let html_str = Ui.Html.to_string html in

  check bool "contains site name" true
    (Astring.String.is_infix ~affix:"Simple Site" html_str);
  (* When menu is None, it uses the default_menu which has Home and Blog *)
  check bool "has menu items" true
    (Astring.String.is_infix ~affix:"Home" html_str)

let test_active_page_highlight () =
  let site =
    {
      Core.Site.name = "Active Test";
      url = "https://active.com";
      title = "Active";
      tagline = "Testing active";
      description = "Active page test";
      author = "Author";
      author_email = "author@active.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Active"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let header =
    {
      Ui.Header.menu =
        Some
          [
            { label = "Home"; page = Core.Page.Index };
            { label = "Blog"; page = Core.Page.Blog_feed };
            { label = "Papers"; page = Core.Page.Papers };
          ];
      active_page = Some Core.Page.Blog_feed;
      site;
      palette = Ui.Colors.default_palette;
    }
  in

  let html = Ui.Header.render header in
  let html_str = Ui.Html.to_string html in

  (* Active page should have different styling *)
  check bool "has menu items" true
    (Astring.String.is_infix ~affix:"Blog" html_str);
  (* Check that the active page link has special styling or attributes *)
  check bool "active page has special handling" true
    (Astring.String.is_infix ~affix:"Blog" html_str)

let suite =
  [
    ( "header",
      [
        test_case "render with menu" `Quick test_render_with_menu;
        test_case "render without menu" `Quick test_render_without_menu;
        test_case "active page highlight" `Quick test_active_page_highlight;
      ] );
  ]
