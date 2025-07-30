(** Tests for the Author_card module *)

open Alcotest

let test_render_author_card () =
  let author = Core.Blog.Name { name = "Jane Doe"; slug = "jane-doe" } in

  let card = Ui.Author_card.render author in
  let html = Ui.Html.to_string card in

  check bool "contains author name" true
    (Astring.String.is_infix ~affix:"Jane Doe" html)

let suite =
  [
    ( "author_card",
      [ test_case "render author card" `Quick test_render_author_card ] );
  ]
