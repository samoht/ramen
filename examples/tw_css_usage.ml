(** Example: Using Tailwind CSS Generation in Ramen *)

open Ui

(* Example 1: Standard approach with class extraction *)
let standard_usage () =
  (* Use Tw utilities normally with to_classes *)
  let card =
    Html.(
      div
        ~tw:
          Tw.
            [
              bg white;
              shadow md;
              rounded lg;
              p (int 6);
              max_w md;
              mx auto;
              on_hover [ shadow lg ];
            ]
        [
          h2 ~tw:Tw.[ text_xl; font_bold; mb (int 4) ] [ txt "Standard Card" ];
          p
            ~tw:Tw.[ text ~shade:600 gray; leading_relaxed ]
            [
              txt
                "This card uses standard Tailwind classes that will be \
                 extracted.";
            ];
        ])
  in

  (* After rendering all HTML, extract classes and generate CSS *)
  let all_classes = Tw.extract_all_classes () in
  let css = Tw.generate_stylesheet all_classes in

  Printf.printf "Generated %d classes\n" (List.length all_classes);
  Printf.printf "CSS preview:\n%s\n"
    (String.sub css 0 (min 500 (String.length css)));

  (card, css)

(* Example 2: Inline styles for dynamic components *)
let inline_style_usage () =
  (* Dynamic values that change at runtime *)
  let progress_percent = 75 in
  let theme_color = Tw.green in

  (* Generate inline styles for dynamic values *)
  let progress_bar =
    Html.(
      div
        ~tw:Tw.[ bg ~shade:200 gray; rounded full; h (int 4); overflow_hidden ]
        [
          div
            ~at:
              [
                At.style
                  (Tw.to_inline_style
                     Tw.
                       [
                         bg ~shade:500 theme_color;
                         h full;
                         w (int (progress_percent * 4 / 10));
                         (* Convert to rem scale *)
                         transition_all;
                       ]);
              ]
            [];
        ])
  in

  progress_bar

(* Example 3: Hybrid approach - mix classes and inline styles *)
let hybrid_usage () =
  (* Base styles as classes *)
  let base_button_styles =
    Tw.
      [
        px (int 4);
        py (int 2);
        font_medium;
        rounded md;
        transition_colors;
        cursor_pointer;
      ]
  in

  (* Dynamic color based on state *)
  let create_button ~active label =
    let color_styles =
      if active then Tw.[ bg ~shade:500 blue; text white ]
      else Tw.[ bg ~shade:100 gray; text ~shade:700 gray ]
    in

    Html.(
      button
        ~tw:(base_button_styles @ color_styles)
        ~at:
          (if active then []
           else
             [
               (* Add inline hover styles for inactive state *)
               At.onmouseover (Tw.to_inline_style Tw.[ bg ~shade:200 gray ]);
               At.onmouseout (Tw.to_inline_style Tw.[ bg ~shade:100 gray ]);
             ])
        [ txt label ])
  in

  Html.div
    ~tw:Tw.[ flex; gap (int 2) ]
    [
      create_button ~active:true "Active";
      create_button ~active:false "Inactive";
    ]

(* Example 4: Server-side rendering with unique styles *)
let ssr_component_with_unique_styles ~id ~color_seed =
  (* Generate unique colors based on seed *)
  let hue = color_seed * 137 mod 360 in
  let unique_styles =
    Tw.to_inline_style
      Tw.
        [
          (* These would be hard to extract as classes since they're unique *)
          bg white;
          border `Default;
          p (int 4);
        ]
    ^ Printf.sprintf ";border-color:hsl(%d,70%%,60%%)" hue
  in

  Html.(
    div
      ~at:[ At.id id; At.style unique_styles ]
      [
        txt (Printf.sprintf "Component #%d with unique border color" color_seed);
      ])

(* Example 5: Responsive inline styles *)
let responsive_inline_example () =
  (* For truly dynamic responsive values, we might need inline styles *)
  let viewport_based_size =
    (* This would normally be calculated based on viewport *)
    42
  in

  Html.(
    div
      ~at:
        [
          At.style
            (Printf.sprintf "width:%dvw;height:%dvw;max-width:400px"
               viewport_based_size viewport_based_size);
          At.class_
            (Tw.to_classes
               Tw.
                 [
                   bg ~shade:100 blue;
                   rounded full;
                   mx auto;
                   flex;
                   items_center;
                   justify_center;
                 ]);
        ]
      [ txt "Viewport-based sizing" ])

(* Main example showing both approaches *)
let () =
  (* Standard usage *)
  let card, css = standard_usage () in

  (* Inline styles *)
  let progress = inline_style_usage () in

  (* Hybrid *)
  let buttons = hybrid_usage () in

  (* Complete page *)
  let page =
    Html.(
      html
        [
          head
            [
              title [ txt "Tailwind CSS Examples" ];
              style [ txt css ];
              (* Include generated CSS *)
            ];
          body
            ~tw:Tw.[ bg ~shade:50 gray; p (int 8) ]
            [
              div
                ~tw:Tw.[ max_w xl_4; mx auto; flex; flex_col; gap (int 8) ]
                [
                  card;
                  progress;
                  buttons;
                  ssr_component_with_unique_styles ~id:"unique-1" ~color_seed:42;
                  responsive_inline_example ();
                ];
            ];
        ])
  in

  print_endline "Example complete!"
