(* Visual test for hero components *)

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
                    "https://cdn.jsdelivr.net/npm/tailwindcss@3/dist/tailwind.min.css";
                ]
              ();
          ];
        Html.body content;
      ]
  in
  let html = Html.to_string ~doctype:true page in
  let oc = open_out filename in
  output_string oc html;
  close_out oc;
  print_endline ("Generated " ^ filename)

let test () =
  let heroes =
    [
      Html.h2 ~tw:[ text_xl; font_bold; mb (int 4) ] [ Html.txt "Hero Styles" ];
      Html.div
        ~tw:[ flex; flex_col; gap (int 8) ]
        [
          Hero.render
            {
              style = Some Simple;
              title = "Simple Hero";
              description = "This is a simple hero with minimal styling";
              subtitle = None;
              palette = Colors.default_palette;
            };
          Hero.render
            {
              style = Some Gradient;
              title = "Gradient Hero";
              description = "This hero has a beautiful gradient background";
              subtitle = None;
              palette = Colors.default_palette;
            };
          Hero.render
            {
              style = Some Post;
              title = "Post Hero";
              description = "This hero style is used for blog posts with border";
              subtitle = None;
              palette = Colors.default_palette;
            };
        ];
    ]
  in

  generate_test_page ~title:"Hero Component Test" ~filename:"test_hero.html"
    heroes

let suite =
  [
    ( "Hero visual test",
      [ Alcotest.test_case "generate hero test page" `Quick test ] );
  ]
