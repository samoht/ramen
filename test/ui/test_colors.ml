(* Visual test for color palette *)

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
          [ Html.div ~tw:[ p (int 8); max_w (rem 72.0); mx auto ] content ];
      ]
  in
  let html = Html.to_string ~doctype:true page in
  let oc = open_out filename in
  output_string oc html;
  close_out oc;
  print_endline ("Generated " ^ filename)

(* Helper to create a color swatch display *)
let color_swatch name tw_color description ~is_text_color =
  (* Convert text colors to background colors for display *)
  let display_color =
    if is_text_color then
      match tw_color with
      | _ -> tw_color (* Apply as text color on a sample text *)
    else tw_color (* Apply as is for backgrounds and borders *)
  in
  let swatch_content =
    if is_text_color then
      [
        Html.div
          ~tw:[ tw_color; Tw.font_semibold; Tw.text_center ]
          [ Html.txt "Aa" ];
      ]
    else []
  in
  Html.div
    ~tw:[ flex; items_center; gap (int 4) ]
    [
      Html.div
        ~tw:
          ([
             w (int 20);
             h (int 20);
             Tw.rounded lg;
             Tw.border `Default;
             border_color ~shade:200 gray;
             Tw.flex;
             Tw.items_center;
             Tw.justify_center;
           ]
          @ if not is_text_color then [ display_color ] else [])
        swatch_content;
      Html.div
        [
          Html.p ~tw:[ Tw.font_semibold ] [ Html.txt name ];
          Html.p ~tw:[ text_sm; text ~shade:600 gray ] [ Html.txt description ];
        ];
    ]

(* Generate text color samples *)
let text_colors_section palette =
  Html.div
    [
      Html.h3
        ~tw:[ text_lg; font_semibold; mb (int 4) ]
        [ Html.txt "Text Colors" ];
      Html.div
        ~tw:[ grid; grid_cols 1; on_md [ grid_cols 2 ]; gap (int 4) ]
        [
          color_swatch "text_primary"
            (Colors.text_primary palette)
            "Primary text (gray-900)" ~is_text_color:true;
          color_swatch "text_secondary"
            (Colors.text_secondary palette)
            "Secondary text (gray-700)" ~is_text_color:true;
          color_swatch "text_muted"
            (Colors.text_muted palette)
            "Muted text (gray-600)" ~is_text_color:true;
        ];
    ]

(* Generate background color samples *)
let background_colors_section palette =
  Html.div
    [
      Html.h3
        ~tw:[ text_lg; font_semibold; mb (int 4) ]
        [ Html.txt "Background Colors" ];
      Html.div
        ~tw:[ grid; grid_cols 1; on_md [ grid_cols 2 ]; gap (int 4) ]
        [
          color_swatch "bg_primary"
            (Colors.bg_primary palette)
            "Primary background (white)" ~is_text_color:false;
          color_swatch "bg_secondary"
            (Colors.bg_secondary palette)
            "Secondary background (gray-50)" ~is_text_color:false;
        ];
    ]

(* Generate border color samples *)
let border_colors_section palette =
  Html.div
    [
      Html.h3
        ~tw:[ text_lg; font_semibold; mb (int 4) ]
        [ Html.txt "Border Colors" ];
      Html.div
        ~tw:[ grid; grid_cols 1; on_md [ grid_cols 2 ]; gap (int 4) ]
        [
          Html.div
            ~tw:
              [
                p (int 4);
                Tw.border `Sm;
                Colors.border_muted palette;
                Tw.rounded none;
              ]
            [ Html.txt "Muted border (gray-200)" ];
          Html.div
            ~tw:
              [
                p (int 4);
                Tw.border `Sm;
                Colors.border_accent palette;
                Tw.rounded none;
              ]
            [ Html.txt "Accent border (accent-600)" ];
        ];
    ]

let test () =
  let palette = Colors.default_palette in
  let colors =
    [
      Html.h2
        ~tw:[ text_xl; font_bold; mb (int 4) ]
        [ Html.txt "Color Palette" ];
      Html.div
        ~tw:[ flex; flex_col; gap (int 8) ]
        [
          text_colors_section palette;
          background_colors_section palette;
          border_colors_section palette;
        ];
    ]
  in

  generate_test_page ~title:"Color Palette Test" ~filename:"test_colors.html"
    colors

let suite =
  [
    ( "Colors visual test",
      [ Alcotest.test_case "generate colors test page" `Quick test ] );
  ]
