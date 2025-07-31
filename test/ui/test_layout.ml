(** Tests for the Layout module *)

open Alcotest
open Ui.Tw

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
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let content =
    [
      Ui.Html.h1 [ Ui.Html.txt "Page Title" ];
      Ui.Html.p [ Ui.Html.txt "Page content" ];
    ]
  in

  let layout =
    Ui.Layout.render ~title:"Test Page" ~description:"A test page" ~site
      Core.Page.Index content
  in

  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html_str = Ui.Layout.to_string config layout in

  check bool "has doctype" true
    (Astring.String.is_prefix ~affix:"<!DOCTYPE html>" html_str);
  check bool "has title" true
    (Astring.String.is_infix ~affix:"<title>Test | Test Page</title>" html_str);
  check bool "has description meta" true
    (Astring.String.is_infix ~affix:"name=\"description\"" html_str);
  check bool "has content" true
    (Astring.String.is_infix ~affix:"Page Title" html_str)

let test_og_metadata () =
  let og =
    {
      Ui.Layout.title = "OG Title";
      description = Some "OG Description";
      url = "https://test.com/page";
      typ = `Article;
      image = "https://test.com/image.jpg";
    }
  in

  let site =
    {
      Core.Site.name = "Test";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let layout = Ui.Layout.render ~title:"Page" ~og ~site Core.Page.Index [] in

  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html_str = Ui.Layout.to_string config layout in

  check bool "has og:title" true
    (Astring.String.is_infix ~affix:"property=\"og:title\"" html_str);
  check bool "has og:type article" true
    (Astring.String.is_infix ~affix:"content=\"article\"" html_str);
  check bool "has og:image" true
    (Astring.String.is_infix ~affix:"property=\"og:image\"" html_str)

let test_raw () =
  let raw_html = "<html><body>Raw content</body></html>" in
  let layout = Ui.Layout.raw raw_html in

  let config = { Ui.Layout.main_css = ""; js = [] } in
  let output = Ui.Layout.to_string config layout in

  check string "raw output" raw_html output

let test_to_tw () =
  let site =
    {
      Core.Site.name = "Test";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let content =
    [
      Ui.Html.div
        ~tw:[ p (int 4); bg white ]
        [ Ui.Html.span ~tw:[ text ~shade:900 gray ] [ Ui.Html.txt "Text" ] ];
    ]
  in

  let layout = Ui.Layout.render ~title:"Test" ~site Core.Page.Index content in
  let tw_classes = Ui.Layout.to_tw layout in

  check bool "collected classes" true (List.length tw_classes > 0);
  (* The layout includes header, footer and content, so we'll have many
     classes *)
  check bool "has content classes" true (List.length tw_classes > 10)

let suite =
  [
    ( "layout",
      [
        test_case "render" `Quick test_render;
        test_case "og metadata" `Quick test_og_metadata;
        test_case "raw" `Quick test_raw;
        test_case "to_tw" `Quick test_to_tw;
      ] );
  ]
