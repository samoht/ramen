(* Visual test for button components *)

open Ui

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
          [ Html.div ~tw:[ Tw.p (Int 8); Tw.max_w_4xl; Tw.mx_auto ] content ];
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
      Html.h3
        ~tw:[ Tw.text_lg; Tw.font_semibold; Tw.mb (Int 2) ]
        [ Html.txt title ];
      Html.div ~tw:[ Tw.flex; Tw.gap (Int 4) ] buttons;
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
        ~tw:[ Tw.flex; Tw.items_center; Tw.gap (Int 2) ]
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
        ~tw:[ Tw.text_xl; Tw.font_bold; Tw.mb (Int 4) ]
        [ Html.txt "Button Variants" ];
      Html.div
        ~tw:[ Tw.space_y (Int 4) ]
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
