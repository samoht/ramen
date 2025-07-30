(** Tests for the Prose module *)

open Alcotest

let test_paragraph () =
  let palette = Ui.Colors.default_palette in
  let content = [ Ui.Html.txt "Some prose content" ] in
  let p = Ui.Prose.p ~palette content in
  let html = Ui.Html.to_string p in

  check bool "is paragraph" true (Astring.String.is_infix ~affix:"<p" html);
  check bool "contains content" true
    (Astring.String.is_infix ~affix:"Some prose content" html)

let test_with_size () =
  let palette = Ui.Colors.default_palette in
  let content = [ Ui.Html.txt "Small text" ] in
  let p = Ui.Prose.p ~size:`Small ~palette content in
  let html = Ui.Html.to_string p in

  check bool "has paragraph" true (Astring.String.is_infix ~affix:"<p" html);
  check bool "contains content" true
    (Astring.String.is_infix ~affix:"Small text" html)

let suite =
  [
    ( "prose",
      [
        test_case "prose paragraph" `Quick test_paragraph;
        test_case "prose with size" `Quick test_with_size;
      ] );
  ]
