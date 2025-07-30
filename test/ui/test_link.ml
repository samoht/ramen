(** Tests for the Link module *)

open Alcotest

let test_internal_link () =
  let palette = Ui.Colors.default_palette in
  let content = [ Ui.Html.txt "About Us" ] in
  let link = Ui.Link.internal' ~palette content "/about" in
  let html = Ui.Html.to_string link in

  check bool "is anchor tag" true (Astring.String.is_infix ~affix:"<a" html);
  check bool "has href" true
    (Astring.String.is_infix ~affix:"href=\"/about\"" html);
  check bool "has content" true (Astring.String.is_infix ~affix:"About Us" html)

let test_external_link () =
  let palette = Ui.Colors.default_palette in
  let content = [ Ui.Html.txt "External" ] in
  let link = Ui.Link.external' ~palette content "https://example.com" in
  let html = Ui.Html.to_string link in

  check bool "has external href" true
    (Astring.String.is_infix ~affix:"href=\"https://example.com\"" html);
  check bool "has target blank" true
    (Astring.String.is_infix ~affix:"target=\"_blank\"" html);
  check bool "has rel noopener" true
    (Astring.String.is_infix ~affix:"rel=\"noopener noreferrer\"" html)

let test_external_nav_link () =
  let palette = Ui.Colors.default_palette in
  let link = Ui.Link.external_nav ~palette Ui.Link.ocaml_org in
  let html = Ui.Html.to_string link in

  check bool "has OCaml.org link" true
    (Astring.String.is_infix ~affix:"ocaml.org" html)

let suite =
  [
    ( "link",
      [
        test_case "internal link" `Quick test_internal_link;
        test_case "external link" `Quick test_external_link;
        test_case "external nav link" `Quick test_external_nav_link;
      ] );
  ]
