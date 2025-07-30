(** Tests for the Section module *)

open Alcotest

let test_basic () =
  let content = Ui.Html.(p [ txt "Section content" ]) in
  let section = Ui.Section.render [ content ] in
  let html = Ui.Html.to_string section in

  check bool "is section tag" true
    (Astring.String.is_infix ~affix:"<section" html);
  check bool "contains content" true
    (Astring.String.is_infix ~affix:"Section content" html)

let test_with_background () =
  let content = Ui.Html.(h2 [ txt "Title" ]) in
  let section = Ui.Section.render ~background:`Gray [ content ] in
  let html = Ui.Html.to_string section in

  check bool "is section tag" true
    (Astring.String.is_infix ~affix:"<section" html);
  check bool "contains title" true (Astring.String.is_infix ~affix:"Title" html)

let suite =
  [
    ( "section",
      [
        test_case "basic section" `Quick test_basic;
        test_case "section with background" `Quick test_with_background;
      ] );
  ]
