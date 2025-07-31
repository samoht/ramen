(** Tests for the HTML module *)

open Alcotest
open Ui.Tw

let test_txt () =
  let text = Ui.Html.txt "Hello World" in
  let html_str = Ui.Html.to_string text in
  check string "text content" "Hello World" html_str

let test_element_creation () =
  let div = Ui.Html.div ~tw:[ p (int 4); bg white ] [ Ui.Html.txt "Content" ] in
  let html_str = Ui.Html.to_string div in

  check bool "is div element" true
    (Astring.String.is_prefix ~affix:"<div" html_str);
  check bool "contains content" true
    (Astring.String.is_infix ~affix:"Content" html_str);
  check bool "has classes" true
    (Astring.String.is_infix ~affix:"class=" html_str)

let test_attributes () =
  let link =
    Ui.Html.a
      ~at:[ Ui.Html.At.href "/about"; Ui.Html.At.title "About page" ]
      ~tw:[ text ~shade:600 blue; on_hover [ underline ] ]
      [ Ui.Html.txt "About" ]
  in
  let html_str = Ui.Html.to_string link in

  check bool "has href" true
    (Astring.String.is_infix ~affix:"href=\"/about\"" html_str);
  check bool "has title" true
    (Astring.String.is_infix ~affix:"title=\"About page\"" html_str);
  check bool "contains text" true
    (Astring.String.is_infix ~affix:"About" html_str)

let test_nesting () =
  let nested =
    Ui.Html.div
      [
        Ui.Html.h1 [ Ui.Html.txt "Title" ];
        Ui.Html.p
          [
            Ui.Html.txt "Paragraph with ";
            Ui.Html.span ~tw:[ font_bold ] [ Ui.Html.txt "bold" ];
            Ui.Html.txt " text.";
          ];
      ]
  in
  let html_str = Ui.Html.to_string nested in

  check bool "has h1" true (Astring.String.is_infix ~affix:"<h1>" html_str);
  check bool "has paragraph" true
    (Astring.String.is_infix ~affix:"<p>" html_str);
  check bool "has span with bold" true
    (Astring.String.is_infix ~affix:"<span" html_str);
  check bool "correct nesting" true
    (Astring.String.is_infix ~affix:"Paragraph with" html_str
    && Astring.String.is_infix ~affix:"bold" html_str
    && Astring.String.is_infix ~affix:"text." html_str)

let test_to_tw () =
  let elem =
    Ui.Html.div
      ~tw:[ p (int 4); bg white; text ~shade:900 gray; rounded lg ]
      [ Ui.Html.span ~tw:[ font_bold ] [ Ui.Html.txt "Text" ] ]
  in

  let tw_classes = Ui.Html.to_tw elem in
  check Alcotest.int "collected 5 classes" 5 (List.length tw_classes);
  check bool "has p_4" true
    (List.exists (fun tw -> to_string tw = "p-4") tw_classes);
  check bool "has font_bold" true
    (List.exists (fun tw -> to_string tw = "font-bold") tw_classes)

let test_pp () =
  let elem = Ui.Html.div ~tw:[ p (int 2) ] [ Ui.Html.txt "Test" ] in
  let pp_output = Ui.Html.pp elem in

  check bool "pp contains element tag" true
    (Astring.String.is_infix ~affix:"<div" pp_output);
  check bool "pp contains classes" true
    (Astring.String.is_infix ~affix:"p-2" pp_output)

let suite =
  [
    ( "html",
      [
        test_case "txt" `Quick test_txt;
        test_case "element creation" `Quick test_element_creation;
        test_case "attributes" `Quick test_attributes;
        test_case "nesting" `Quick test_nesting;
        test_case "to_tw" `Quick test_to_tw;
        test_case "pretty printing" `Quick test_pp;
      ] );
  ]
