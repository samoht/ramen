(** Tests for the Heading module *)

open Alcotest

let test_levels () =
  let palette = Ui.Colors.default_palette in
  let h1 = Ui.Heading.h1 "Main Title" ~palette in
  let h2 = Ui.Heading.h2 "Subtitle" ~palette in
  let h3 = Ui.Heading.h3 "Section" ~palette in

  let h1_str = Ui.Html.to_string h1 in
  let h2_str = Ui.Html.to_string h2 in
  let h3_str = Ui.Html.to_string h3 in

  check bool "h1 tag" true (Astring.String.is_infix ~affix:"<h1" h1_str);
  check bool "h2 tag" true (Astring.String.is_infix ~affix:"<h2" h2_str);
  check bool "h3 tag" true (Astring.String.is_infix ~affix:"<h3" h3_str);

  check bool "h1 content" true
    (Astring.String.is_infix ~affix:"Main Title" h1_str);
  check bool "h2 content" true
    (Astring.String.is_infix ~affix:"Subtitle" h2_str);
  check bool "h3 content" true (Astring.String.is_infix ~affix:"Section" h3_str)

let test_with_id () =
  let palette = Ui.Colors.default_palette in
  let h2 = Ui.Heading.h2 ~id:"custom-id" "With ID" ~palette in
  let html = Ui.Html.to_string h2 in

  check bool "has id attribute" true
    (Astring.String.is_infix ~affix:"id=\"custom-id\"" html)

let suite =
  [
    ( "heading",
      [
        test_case "heading levels" `Quick test_levels;
        test_case "heading with id" `Quick test_with_id;
      ] );
  ]
