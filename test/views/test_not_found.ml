(** Tests for the Not_found page module *)

open Alcotest
open Views
open Core

let test_render_404 () =
  let site =
    {
      Site.name = "Test Site";
      url = "https://test.com";
      title = "Test Site";
      tagline = "Testing 404";
      description = "Test site";
      author = "Test Author";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let layout = Not_found.render ~site in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "contains 404 message" true
    (Astring.String.is_infix ~affix:"404" html
    || Astring.String.is_infix ~affix:"not found" html
    || Astring.String.is_infix ~affix:"Not Found" html);
  check bool "contains site name" true
    (Astring.String.is_infix ~affix:"Test Site" html)

let test_render_with_home_link () =
  let site =
    {
      Site.name = "Link Test";
      url = "https://linktest.com";
      title = "Link Test";
      tagline = "Testing links";
      description = "Test site";
      author = "Test Author";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let layout = Not_found.render ~site in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  (* Should have a link back to homepage *)
  check bool "has link to home" true
    (Astring.String.is_infix ~affix:"href=\"/\"" html
    || Astring.String.is_infix ~affix:"home" html
    || Astring.String.is_infix ~affix:"Home" html)

let suite =
  [
    ( "not_found",
      [
        test_case "render 404 page" `Quick test_render_404;
        test_case "render with home link" `Quick test_render_with_home_link;
      ] );
  ]
