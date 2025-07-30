(* Visual test for card components *)

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
        Html.body ~tw:[ Tw.bg_gray_50 ]
          [ Html.div ~tw:[ Tw.p (Int 8); Tw.max_w_6xl; Tw.mx_auto ] content ];
      ]
  in
  let html = Html.to_string ~doctype:true page in
  let oc = open_out filename in
  output_string oc html;
  close_out oc;
  print_endline ("Generated " ^ filename)

(* Helper to create sample card content *)
let sample_content () =
  [
    Html.h3 ~tw:[ Tw.text_lg; Tw.font_semibold ] [ Html.txt "Card Title" ];
    Html.p
      ~tw:[ Tw.text_gray_600; Tw.mt (Int 2); Tw.mb (Int 4) ]
      [
        Html.txt
          "This is some sample content inside the card. Cards are useful for \
           grouping related content.";
      ];
    Html.div
      ~tw:[ Tw.mt (Int 4) ]
      [ Button.render ~variant:Primary ~size:`Small ~href:"#" "Learn More" ];
  ]

(* Helper to create a card demo *)
let card_demo ~title ~variant =
  Html.div
    [
      Html.h3
        ~tw:[ Tw.text_lg; Tw.font_semibold; Tw.mb (Int 2) ]
        [ Html.txt title ];
      Card.render ~variant (sample_content ());
    ]

let test_cards () =
  let cards =
    [
      Html.h2
        ~tw:[ Tw.text_xl; Tw.font_bold; Tw.mb (Int 4) ]
        [ Html.txt "Card Variants" ];
      Html.div
        ~tw:[ Tw.grid; Tw.grid_cols 1; Tw.md (Tw.grid_cols 2); Tw.gap (Int 6) ]
        [
          card_demo ~title:"Default Card" ~variant:Default;
          card_demo ~title:"Outlined Card" ~variant:Outlined;
          card_demo ~title:"Elevated Card" ~variant:Elevated;
        ];
    ]
  in

  generate_test_page ~title:"Card Component Test" ~filename:"test_card.html"
    cards

let suite =
  [
    ( "Card visual test",
      [ Alcotest.test_case "generate card test page" `Quick test_cards ] );
  ]
