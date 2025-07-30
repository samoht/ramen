(** Tests for the Robots page module *)

open Alcotest
open Views

let test_render_robots () =
  let site =
    {
      Core.Site.name = "Test Site";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in
  let layout = Robots.render ~site in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let robots_txt = Ui.Layout.to_string config layout in

  (* Should be plain text robots.txt format *)
  check bool "has User-agent directive" true
    (Astring.String.is_infix ~affix:"User-agent:" robots_txt);
  check bool "has Allow or Disallow" true
    (Astring.String.is_infix ~affix:"Allow:" robots_txt
    || Astring.String.is_infix ~affix:"Disallow:" robots_txt)

let test_render_allows_all () =
  let site =
    {
      Core.Site.name = "Test Site";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in
  let layout = Robots.render ~site in
  let config = { Ui.Layout.main_css = ""; js = [] } in
  let robots_txt = Ui.Layout.to_string config layout in

  (* Default should allow all user agents *)
  check bool "allows all agents" true
    (Astring.String.is_infix ~affix:"User-agent: *" robots_txt)

let suite =
  [
    ( "robots",
      [
        test_case "render robots.txt" `Quick test_render_robots;
        test_case "allows all agents" `Quick test_render_allows_all;
      ] );
  ]
