(* Visual test for button components *)

open Ui
open Tw

(* Helper to generate a test page *)
let generate_test_page ~title ~filename content =
  let page =
    Html.root
      [
        Html.head
          [
            Html.meta ~at:[ Html.At.charset "utf-8" ] ();
            Html.title [ Html.txt title ];
            Html.link
              ~at:
                [
                  Html.At.rel "stylesheet";
                  Html.At.href
                    "https://cdn.jsdelivr.net/npm/tailwindcss@2/dist/tailwind.min.css";
                ]
              ();
          ];
        Html.body
          [ Html.div ~tw:[ p (int 8); max_w (rem 56.0); mx auto ] content ];
      ]
  in
  let html = Html.to_string ~doctype:true page in
  let oc = open_out filename in
  output_string oc html;
  close_out oc;
  print_endline ("Generated " ^ filename)

(* Helper to create a button section *)
let button_section ~title ~buttons =
  Html.div
    [
      Html.h3 ~tw:[ text_lg; font_semibold; mb (int 2) ] [ Html.txt title ];
      Html.div ~tw:[ flex; gap (int 4) ] buttons;
    ]

let test_buttons () =
  let primary_buttons =
    [
      Button.render ~variant:Primary ~href:"#" "Primary Button";
      Button.render ~variant:Primary ~size:`Small ~href:"#" "Small Primary";
      Button.render ~variant:Primary ~size:`Large ~href:"#" "Large Primary";
    ]
  in
  let secondary_buttons =
    [
      Button.render ~variant:Secondary ~href:"#" "Secondary Button";
      Html.div
        ~tw:[ flex; items_center; gap (int 2) ]
        [ Icon.github; Button.render ~variant:Secondary ~href:"#" "With Icon" ];
    ]
  in
  let outline_buttons =
    [
      Button.render ~variant:Outline ~href:"#" "Outline Button";
      Button.render ~variant:Outline ~href:"https://example.com" "External Link";
    ]
  in

  let buttons =
    [
      Html.h2
        ~tw:[ text_xl; font_bold; mb (int 4) ]
        [ Html.txt "Button Variants" ];
      Html.div
        ~tw:[ flex; flex_col; gap (int 4) ]
        [
          button_section ~title:"Primary Buttons" ~buttons:primary_buttons;
          button_section ~title:"Secondary Buttons" ~buttons:secondary_buttons;
          button_section ~title:"Outline Buttons" ~buttons:outline_buttons;
        ];
    ]
  in

  generate_test_page ~title:"Button Component Test" ~filename:"test_button.html"
    buttons

let suite =
  [
    ( "Button visual test",
      [ Alcotest.test_case "generate button test page" `Quick test_buttons ] );
  ]
