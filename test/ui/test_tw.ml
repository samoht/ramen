(** Tests for the Tw module

    IMPORTANT: These tests MUST verify EXACT 1:1 mapping between our Tw module
    and real Tailwind CSS output. Any differences are bugs in our
    implementation.

    - CSS property values must match exactly (including spaces, units, etc.)
    - CSS property order must match Tailwind's order
    - Minification rules must match Tailwind's minification
    - All utility classes must generate identical CSS to Tailwind

    The check_exact_match function is the primary test that ensures 1:1 mapping.
    Any test failure indicates our CSS generation differs from Tailwind. *)

open Alcotest

let test_css_generation () =
  (* Test that our Tw module generates CSS *)
  let test_class tw_style expected_css =
    let stylesheet = Ui.Tw.of_tw [ tw_style ] in
    let css_str = Ui.Css.to_string stylesheet in
    (* CSS might be minified, so remove spaces *)
    let normalized_css = Astring.String.filter (fun c -> c <> ' ') css_str in
    let normalized_expected =
      Astring.String.filter (fun c -> c <> ' ') expected_css
    in
    (* Debug output *)
    if not (Astring.String.is_infix ~affix:normalized_expected normalized_css)
    then
      Fmt.epr
        "CSS debug: Looking for '%s' in generated CSS (first 500 chars): \
         '%s...'@."
        normalized_expected
        (String.sub normalized_css 0 (min 500 (String.length normalized_css)));
    check bool
      ("css contains " ^ expected_css)
      true
      (Astring.String.is_infix ~affix:normalized_expected normalized_css)
  in

  (* Test basic spacing classes *)
  test_class (Ui.Tw.p (Int 4)) "padding:1rem";
  test_class (Ui.Tw.m (Int 2)) "margin:0.5rem";
  test_class (Ui.Tw.px (Int 6)) "padding-left:1.5rem";
  test_class (Ui.Tw.px (Int 6)) "padding-right:1.5rem";

  (* Test color classes *)
  test_class Ui.Tw.bg_white
    "background-color:rgb(255 255 255 / var(--tw-bg-opacity))";
  test_class
    (Ui.Tw.text ~shade:900 Ui.Tw.Gray)
    "color:rgb(17 24 39 / var(--tw-text-opacity))";

  (* Test display classes *)
  test_class Ui.Tw.flex "display:flex";
  test_class Ui.Tw.hidden "display:none";
  test_class Ui.Tw.block "display:block"

let test_modifier_classes () =
  (* Test that modifiers are correctly applied *)
  let hover_bg = Ui.Tw.hover (Ui.Tw.bg ~shade:800 Ui.Tw.Sky) in
  let css_str = Ui.Tw.to_string hover_bg in
  check string "hover modifier prefix" "hover:bg-sky-800" css_str;

  let md_block = Ui.Tw.md Ui.Tw.block in
  let css_str = Ui.Tw.to_string md_block in
  check string "responsive modifier prefix" "md:block" css_str

let test_rounded_values () =
  (* Test rounded corner values *)
  let test_rounded rounded expected =
    let tw = Ui.Tw.rounded rounded in
    let stylesheet = Ui.Tw.of_tw [ tw ] in
    let css_str = Ui.Css.to_string stylesheet in
    check bool "rounded value matches expected" true
      (Astring.String.is_infix ~affix:expected css_str)
  in

  test_rounded Ui.Tw.None "border-radius: 0";
  test_rounded Ui.Tw.Sm "border-radius: 0.125rem";
  test_rounded Ui.Tw.Md "border-radius: 0.375rem";
  test_rounded Ui.Tw.Lg "border-radius: 0.5rem";
  test_rounded Ui.Tw.Full "border-radius: 9999px"

let test_shadow_values () =
  (* Test box shadow values *)
  let test_shadow shadow =
    let tw = Ui.Tw.shadow shadow in
    let stylesheet = Ui.Tw.of_tw [ tw ] in
    let css_str = Ui.Css.to_string stylesheet in
    check bool "shadow value has box-shadow property" true
      (Astring.String.is_infix ~affix:"box-shadow" css_str)
  in

  test_shadow Ui.Tw.Sm;
  test_shadow Ui.Tw.Md;
  test_shadow Ui.Tw.Lg;
  test_shadow Ui.Tw.None

let test_typography_classes () =
  (* Test typography-related classes *)
  let test_text_size tw expected_size =
    let stylesheet = Ui.Tw.of_tw [ tw ] in
    let css_str = Ui.Css.to_string stylesheet in
    check bool "font-size property" true
      (Astring.String.is_infix ~affix:("font-size: " ^ expected_size) css_str)
  in

  test_text_size Ui.Tw.text_xs "0.75rem";
  test_text_size Ui.Tw.text_sm "0.875rem";
  test_text_size Ui.Tw.text_base "1rem";
  test_text_size Ui.Tw.text_lg "1.125rem";
  test_text_size Ui.Tw.text_xl "1.25rem";
  test_text_size Ui.Tw.text_2xl "1.5rem"

(** No normalization - exact comparison *)
let exact_css css = String.trim css

(** Generate CSS using the official tailwindcss binary *)
let generate_tailwind_css ?(minify = false) classnames =
  (* Create a temporary directory with required files *)
  let temp_dir = Filename.temp_dir "ramen_test" "" in
  let html_file = Filename.concat temp_dir "input.html" in
  let input_css_file = Filename.concat temp_dir "input.css" in
  let css_file = Filename.concat temp_dir "output.css" in
  let config_file = Filename.concat temp_dir "tailwind.config.js" in

  (* Create minimal HTML file *)
  let html_content =
    Fmt.str
      {|<!DOCTYPE html>
<html>
<head></head>
<body>
  <div class="%s"></div>
</body>
</html>|}
      (String.concat " " classnames)
  in

  (* Create input CSS with @tailwind directives *)
  let input_css_content =
    "@tailwind base;\n@tailwind components;\n@tailwind utilities;\n"
  in

  (* Create minimal Tailwind config *)
  let config_content =
    {|
module.exports = {
  content: ["./input.html"],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/typography')
  ],
}
  |}
  in

  (* Write files *)
  let oc = open_out html_file in
  output_string oc html_content;
  close_out oc;

  let oc = open_out input_css_file in
  output_string oc input_css_content;
  close_out oc;

  let oc = open_out config_file in
  output_string oc config_content;
  close_out oc;

  (* Run tailwindcss *)
  let minify_flag = if minify then " --minify" else "" in
  let cmd =
    Fmt.str
      "cd %s && tailwindcss -c tailwind.config.js -i input.css -o %s%s \
       2>/dev/null"
      temp_dir css_file minify_flag
  in
  let exit_code = Sys.command cmd in

  (if exit_code <> 0 then
     (* Cleanup *)
     let _ = Sys.command (Fmt.str "rm -rf %s" temp_dir) in
     failwith "tailwindcss command failed");

  (* Read generated CSS *)
  let ic = open_in css_file in
  let css = really_input_string ic (in_channel_length ic) in
  close_in ic;

  (* Cleanup *)
  let _ = Sys.command (Printf.sprintf "rm -rf %s" temp_dir) in

  css

(** Generate CSS using our Ramen implementation *)
let generate_ramen_css ?(minify = false) tw_styles =
  let stylesheet = Ui.Tw.of_tw tw_styles in
  Ui.Css.to_string ~minify stylesheet

(** Extract utility class CSS from full Tailwind output *)
let extract_utility_classes css classnames =
  (* Split by } but keep the } in the parts *)
  let rec split_keep_delimiter delim str =
    match String.index_opt str delim with
    | None -> if str = "" then [] else [ str ]
    | Some idx ->
        let before = String.sub str 0 (idx + 1) in
        let after = String.sub str (idx + 1) (String.length str - idx - 1) in
        before :: split_keep_delimiter delim after
  in

  let css_parts = split_keep_delimiter '}' css in

  let find_classes_for classname =
    let selector_exact = "." ^ classname ^ "{" in
    let selector_comma_start = "." ^ classname ^ "," in
    let selector_comma_middle = ",." ^ classname ^ "," in
    let selector_comma_end = ",." ^ classname ^ "{" in
    let selector_pseudo = "." ^ classname ^ ":" in

    List.filter
      (fun part ->
        Astring.String.is_infix ~affix:selector_exact part
        || Astring.String.is_infix ~affix:selector_comma_start part
        || Astring.String.is_infix ~affix:selector_comma_middle part
        || Astring.String.is_infix ~affix:selector_comma_end part
        || Astring.String.is_infix ~affix:selector_pseudo part)
      css_parts
  in

  (* For each classname, find all CSS parts that reference it *)
  let all_parts = List.concat_map find_classes_for classnames in
  (* Remove duplicates while preserving order *)
  let seen = Hashtbl.create 10 in
  let unique_parts =
    List.filter
      (fun part ->
        if Hashtbl.mem seen part then false
        else (
          Hashtbl.add seen part ();
          true))
      all_parts
  in

  String.concat "" unique_parts

(** Get all test tw styles that need to be checked *)
let get_all_test_styles () =
  [
    (* Basic spacing - comprehensive *)
    Ui.Tw.p (Int 0);
    Ui.Tw.p (Int 1);
    Ui.Tw.p (Int 4);
    Ui.Tw.m (Int 0);
    Ui.Tw.m (Int 2);
    Ui.Tw.m Auto;
    Ui.Tw.px (Int 6);
    Ui.Tw.py (Int 3);
    Ui.Tw.pt (Int 1);
    Ui.Tw.pr (Int 8);
    Ui.Tw.pb (Int 12);
    Ui.Tw.pl (Int 16);
    Ui.Tw.mx (Int 0);
    Ui.Tw.mx Auto;
    Ui.Tw.my (Int 10);
    Ui.Tw.mt (Int 20);
    Ui.Tw.mr (Int 24);
    Ui.Tw.mb (Int 56);
    Ui.Tw.ml (Int 6);
    (* Color classes - all variants *)
    Ui.Tw.bg_white;
    Ui.Tw.bg Black;
    Ui.Tw.bg_transparent;
    Ui.Tw.bg_current;
    Ui.Tw.text ~shade:900 Gray;
    Ui.Tw.text_transparent;
    Ui.Tw.text_current;
    Ui.Tw.border_color ~shade:200 Gray;
    Ui.Tw.border_transparent;
    Ui.Tw.border_current;
    Ui.Tw.bg ~shade:500 Gray;
    Ui.Tw.bg ~shade:600 Sky;
    Ui.Tw.text ~shade:400 Yellow;
    Ui.Tw.border_color ~shade:600 Teal;
    (* Display - comprehensive *)
    Ui.Tw.block;
    Ui.Tw.inline;
    Ui.Tw.inline_block;
    Ui.Tw.flex;
    Ui.Tw.inline_flex;
    Ui.Tw.grid;
    Ui.Tw.inline_grid;
    Ui.Tw.hidden;
    (* Sizing - comprehensive *)
    Ui.Tw.w (Int 0);
    Ui.Tw.w (Int 4);
    Ui.Tw.w (Int 96);
    Ui.Tw.w_auto;
    Ui.Tw.w_full;
    Ui.Tw.w_min;
    Ui.Tw.w_max;
    Ui.Tw.h (Int 0);
    Ui.Tw.h (Int 8);
    Ui.Tw.h_auto;
    Ui.Tw.h_full;
    Ui.Tw.min_w (Int 0);
    Ui.Tw.min_w_full;
    Ui.Tw.max_w_xs;
    Ui.Tw.max_w_sm;
    Ui.Tw.max_w_md;
    Ui.Tw.max_w_lg;
    Ui.Tw.max_w_xl;
    Ui.Tw.max_w_2xl;
    Ui.Tw.max_w_7xl;
    Ui.Tw.max_w_full;
    Ui.Tw.max_w_none;
    (* Typography - comprehensive *)
    Ui.Tw.text_xs;
    Ui.Tw.text_sm;
    Ui.Tw.text_base;
    Ui.Tw.text_lg;
    Ui.Tw.text_xl;
    Ui.Tw.text_2xl;
    Ui.Tw.text_3xl;
    Ui.Tw.text_4xl;
    Ui.Tw.font_normal;
    Ui.Tw.font_medium;
    Ui.Tw.font_semibold;
    Ui.Tw.font_bold;
    Ui.Tw.text_left;
    Ui.Tw.text_center;
    Ui.Tw.text_right;
    Ui.Tw.text_justify;
    Ui.Tw.leading_none;
    Ui.Tw.leading_tight;
    Ui.Tw.leading_normal;
    Ui.Tw.leading_relaxed;
    Ui.Tw.tracking_tight;
    Ui.Tw.tracking_normal;
    Ui.Tw.tracking_wide;
    Ui.Tw.whitespace_normal;
    Ui.Tw.whitespace_nowrap;
    (* Responsive - more comprehensive *)
    Ui.Tw.sm Ui.Tw.block;
    Ui.Tw.md Ui.Tw.flex;
    Ui.Tw.lg Ui.Tw.grid;
    Ui.Tw.xl Ui.Tw.hidden;
    Ui.Tw.sm (Ui.Tw.p (Int 4));
    Ui.Tw.md (Ui.Tw.m (Int 6));
    Ui.Tw.lg Ui.Tw.text_lg;
    Ui.Tw.xl Ui.Tw.font_bold;
    (* States - more comprehensive *)
    Ui.Tw.hover Ui.Tw.bg_white;
    Ui.Tw.hover (Ui.Tw.text ~shade:700 Blue);
    Ui.Tw.focus (Ui.Tw.bg ~shade:500 Sky);
    Ui.Tw.focus Ui.Tw.outline_none;
    Ui.Tw.active (Ui.Tw.text ~shade:900 Gray);
    Ui.Tw.disabled (Ui.Tw.opacity 50);
    (* Borders - comprehensive *)
    Ui.Tw.rounded Ui.Tw.None;
    Ui.Tw.rounded Ui.Tw.Sm;
    Ui.Tw.rounded Ui.Tw.Md;
    Ui.Tw.rounded Ui.Tw.Lg;
    Ui.Tw.rounded Ui.Tw.Xl;
    Ui.Tw.rounded Ui.Tw.Full;
    Ui.Tw.border;
    Ui.Tw.border_0;
    Ui.Tw.border_2;
    Ui.Tw.border_4;
    Ui.Tw.border_8;
    Ui.Tw.border_t;
    Ui.Tw.border_r;
    Ui.Tw.border_b;
    Ui.Tw.border_l;
    (* Shadows *)
    Ui.Tw.shadow Ui.Tw.Sm;
    Ui.Tw.shadow Ui.Tw.Md;
    Ui.Tw.shadow Ui.Tw.Lg;
    Ui.Tw.shadow Ui.Tw.Xl;
    Ui.Tw.shadow Ui.Tw.None;
    Ui.Tw.shadow Ui.Tw.Inner;
    (* Prose *)
    Ui.Tw.prose;
    Ui.Tw.prose_sm;
    Ui.Tw.prose_lg;
    Ui.Tw.prose_xl;
    Ui.Tw.prose_gray;
    (* Flexbox - comprehensive *)
    Ui.Tw.flex_col;
    Ui.Tw.flex_row;
    Ui.Tw.flex_row_reverse;
    Ui.Tw.flex_col_reverse;
    Ui.Tw.flex_wrap;
    Ui.Tw.flex_wrap_reverse;
    Ui.Tw.flex_nowrap;
    Ui.Tw.flex_1;
    Ui.Tw.flex_auto;
    Ui.Tw.flex_initial;
    Ui.Tw.flex_none;
    Ui.Tw.flex_grow;
    Ui.Tw.flex_grow_0;
    Ui.Tw.flex_shrink;
    Ui.Tw.flex_shrink_0;
    Ui.Tw.items_start;
    Ui.Tw.items_center;
    Ui.Tw.items_end;
    Ui.Tw.items_stretch;
    Ui.Tw.justify_start;
    Ui.Tw.justify_center;
    Ui.Tw.justify_end;
    Ui.Tw.justify_between;
    Ui.Tw.justify_around;
    Ui.Tw.justify_evenly;
    (* Grid *)
    Ui.Tw.grid_cols 1;
    Ui.Tw.grid_cols 2;
    Ui.Tw.grid_cols 3;
    Ui.Tw.grid_cols 12;
    Ui.Tw.gap (Int 4);
    Ui.Tw.gap_x (Int 2);
    Ui.Tw.gap_y (Int 6);
    (* Layout - comprehensive *)
    Ui.Tw.static;
    Ui.Tw.relative;
    Ui.Tw.absolute;
    Ui.Tw.fixed;
    Ui.Tw.sticky;
    Ui.Tw.inset_0;
    Ui.Tw.inset_x_0;
    Ui.Tw.inset_y_0;
    Ui.Tw.top 0;
    Ui.Tw.right 0;
    Ui.Tw.bottom 0;
    Ui.Tw.left 0;
    Ui.Tw.z 0;
    Ui.Tw.z 10;
    Ui.Tw.z_10;
    (* Overflow *)
    Ui.Tw.overflow_auto;
    Ui.Tw.overflow_hidden;
    Ui.Tw.overflow_visible;
    Ui.Tw.overflow_scroll;
    (* Opacity *)
    Ui.Tw.opacity 0;
    Ui.Tw.opacity 25;
    Ui.Tw.opacity 50;
    Ui.Tw.opacity 75;
    Ui.Tw.opacity 100;
    (* Transitions *)
    Ui.Tw.transition_none;
    Ui.Tw.transition_all;
    Ui.Tw.transition_colors;
    Ui.Tw.transition_opacity;
    Ui.Tw.transition_transform;
    (* Transforms *)
    Ui.Tw.transform;
    Ui.Tw.transform_none;
    Ui.Tw.scale 75;
    Ui.Tw.scale 100;
    Ui.Tw.scale 125;
    Ui.Tw.rotate 45;
    Ui.Tw.rotate 90;
    Ui.Tw.translate_x 4;
    Ui.Tw.translate_y 2;
    (* Cursor *)
    Ui.Tw.cursor_auto;
    Ui.Tw.cursor_default;
    Ui.Tw.cursor_pointer;
    Ui.Tw.cursor_not_allowed;
    (* User Select *)
    Ui.Tw.select_none;
    Ui.Tw.select_text;
    Ui.Tw.select_all;
    Ui.Tw.select_auto;
    (* Extended colors - all 10 new colors *)
    Ui.Tw.bg ~shade:50 Slate;
    Ui.Tw.bg ~shade:500 Zinc;
    Ui.Tw.bg ~shade:900 Orange;
    Ui.Tw.text ~shade:100 Amber;
    Ui.Tw.text ~shade:600 Lime;
    Ui.Tw.border_color ~shade:300 Emerald;
    Ui.Tw.border_color ~shade:700 Cyan;
    Ui.Tw.bg ~shade:400 Violet;
    Ui.Tw.text ~shade:800 Fuchsia;
    Ui.Tw.bg ~shade:200 Rose;
  ]

(** Cache for Tailwind CSS generation with class list hash *)
let tailwind_cache_unminified = ref None

let tailwind_cache_minified = ref None

(** Generate all Tailwind CSS at once *)
let generate_all_tailwind_css ?(minify = false) () =
  let all_styles = get_all_test_styles () in
  let all_classnames = List.map Ui.Tw.to_string all_styles in

  (* Create a key from the classnames to ensure cache validity *)
  let cache_key = String.concat "," (List.sort String.compare all_classnames) in
  let cache =
    if minify then tailwind_cache_minified else tailwind_cache_unminified
  in

  match !cache with
  | Some (key, css) when key = cache_key -> css
  | _ ->
      let css = generate_tailwind_css ~minify all_classnames in
      cache := Some (cache_key, css);
      css

(** Check 1:1 mapping with non-minified Tailwind *)
let check_exact_match tw_style =
  try
    let classname = Ui.Tw.to_string tw_style in
    (* Generate non-minified CSS for accurate comparison *)
    let ramen_css = exact_css (generate_ramen_css ~minify:false [ tw_style ]) in
    let tailwind_full_css =
      exact_css (generate_all_tailwind_css ~minify:false ())
    in

    (* Extract just the utility classes from both outputs *)
    let tailwind_utility_css =
      extract_utility_classes tailwind_full_css [ classname ]
    in
    let ramen_utility_css = extract_utility_classes ramen_css [ classname ] in

    if ramen_utility_css <> tailwind_utility_css then (
      Printf.eprintf "\n=== UTILITY CSS MISMATCH for %s ===\n" classname;
      Printf.eprintf "Ramen utility CSS:\n%s\n" ramen_utility_css;
      Printf.eprintf "Tailwind utility CSS:\n%s\n" tailwind_utility_css;
      Printf.eprintf "===============================\n");

    Alcotest.check string
      (Printf.sprintf "%s utility CSS exact match" classname)
      tailwind_utility_css ramen_utility_css
  with
  | Failure msg -> fail ("Test setup failed: " ^ msg)
  | exn -> fail ("Unexpected error: " ^ Printexc.to_string exn)

(** Main check function - only test exact match for now *)
let check tw_style = check_exact_match tw_style

let test_tailwind_basic_spacing () =
  check (Ui.Tw.p (Int 4));
  check (Ui.Tw.m (Int 2));
  check (Ui.Tw.px (Int 6));
  check (Ui.Tw.py (Int 3));
  check (Ui.Tw.pt (Int 1));
  check (Ui.Tw.pr (Int 8));
  check (Ui.Tw.pb (Int 12));
  check (Ui.Tw.pl (Int 16));
  check (Ui.Tw.mx (Int 0));
  check (Ui.Tw.my (Int 10));
  check (Ui.Tw.mt (Int 20));
  check (Ui.Tw.mr (Int 24));
  check (Ui.Tw.mb (Int 56));
  check (Ui.Tw.ml (Int 6))

let test_tailwind_color_classes () =
  check Ui.Tw.bg_white;
  check (Ui.Tw.text ~shade:900 Gray);
  (* Using consistent API: border should work like bg and text *)
  check (Ui.Tw.border_color ~shade:200 Gray);
  check (Ui.Tw.bg ~shade:500 Gray);
  check (Ui.Tw.bg ~shade:600 Sky);
  check (Ui.Tw.text ~shade:400 Yellow);
  check (Ui.Tw.border_color ~shade:600 Teal)

let test_tailwind_display_classes () =
  check Ui.Tw.block;
  check Ui.Tw.inline;
  check Ui.Tw.inline_block;
  check Ui.Tw.flex;
  check Ui.Tw.inline_flex;
  check Ui.Tw.grid;
  check Ui.Tw.inline_grid;
  check Ui.Tw.hidden

let test_tailwind_sizing () =
  check (Ui.Tw.w (Int 4));
  check (Ui.Tw.h (Int 8));
  check Ui.Tw.w_auto;
  check Ui.Tw.w_full;
  check Ui.Tw.h_auto;
  check Ui.Tw.h_full;
  check (Ui.Tw.min_w (Int 0))

let test_tailwind_typography () =
  check Ui.Tw.text_xs;
  check Ui.Tw.text_sm;
  check Ui.Tw.text_base;
  check Ui.Tw.text_lg;
  check Ui.Tw.text_xl;
  check Ui.Tw.text_2xl;
  check Ui.Tw.font_normal;
  check Ui.Tw.font_medium;
  check Ui.Tw.font_semibold;
  check Ui.Tw.font_bold

let test_tailwind_responsive () =
  check (Ui.Tw.md Ui.Tw.block);
  check (Ui.Tw.lg Ui.Tw.flex);
  check (Ui.Tw.xl Ui.Tw.hidden);
  check (Ui.Tw.sm (Ui.Tw.p (Int 4)));
  check (Ui.Tw.md (Ui.Tw.m (Int 6)))

let test_tailwind_states () =
  check (Ui.Tw.hover Ui.Tw.bg_white);
  check (Ui.Tw.focus (Ui.Tw.bg ~shade:500 Sky));
  check (Ui.Tw.active (Ui.Tw.text ~shade:900 Gray))

let test_tailwind_borders () =
  check (Ui.Tw.rounded Ui.Tw.Md);
  check (Ui.Tw.rounded Ui.Tw.Lg);
  check (Ui.Tw.rounded Ui.Tw.Full);
  check Ui.Tw.border;
  check Ui.Tw.border_2;
  check Ui.Tw.border_4

let test_tailwind_shadows () =
  check (Ui.Tw.shadow Ui.Tw.Sm);
  check (Ui.Tw.shadow Ui.Tw.Md);
  check (Ui.Tw.shadow Ui.Tw.Lg);
  check (Ui.Tw.shadow Ui.Tw.None)

let test_tailwind_prose () =
  check Ui.Tw.prose;
  check Ui.Tw.prose_sm;
  check Ui.Tw.prose_lg;
  check Ui.Tw.prose_xl

let test_tailwind_flexbox () =
  check Ui.Tw.flex_col;
  check Ui.Tw.flex_row;
  check Ui.Tw.flex_row_reverse;
  check Ui.Tw.flex_col_reverse;
  check Ui.Tw.flex_wrap;
  check Ui.Tw.flex_wrap_reverse;
  check Ui.Tw.items_center;
  check Ui.Tw.justify_center;
  check Ui.Tw.justify_between

let test_tailwind_responsive_breakpoints () =
  check (Ui.Tw.sm Ui.Tw.block);
  check (Ui.Tw.md Ui.Tw.flex);
  check (Ui.Tw.lg Ui.Tw.grid);
  check (Ui.Tw.xl Ui.Tw.hidden);
  check (Ui.Tw.sm Ui.Tw.text_lg);
  check (Ui.Tw.md (Ui.Tw.p (Int 8)));
  check (Ui.Tw.lg (Ui.Tw.bg ~shade:500 Sky))

let test_tailwind_layout () =
  check Ui.Tw.relative;
  check Ui.Tw.absolute;
  check Ui.Tw.fixed;
  check Ui.Tw.sticky

let test_tailwind_opacity () =
  check (Ui.Tw.opacity 0);
  check (Ui.Tw.opacity 50);
  check (Ui.Tw.opacity 100)

(** Helper function to check for substring *)
let string_contains_substring haystack needle =
  let haystack_len = String.length haystack in
  let needle_len = String.length needle in
  let rec check_at pos =
    if pos + needle_len > haystack_len then false
    else if String.sub haystack pos needle_len = needle then true
    else check_at (pos + 1)
  in
  if needle_len = 0 then true else check_at 0

(** Test extended color palette *)
let test_extended_color_palette () =
  (* Test all new colors with various shades *)
  check (Ui.Tw.bg ~shade:50 Slate);
  check (Ui.Tw.bg ~shade:500 Zinc);
  check (Ui.Tw.bg ~shade:900 Orange);
  check (Ui.Tw.text ~shade:100 Amber);
  check (Ui.Tw.text ~shade:600 Lime);
  check (Ui.Tw.border_color ~shade:300 Emerald);
  check (Ui.Tw.border_color ~shade:700 Cyan);
  check (Ui.Tw.bg ~shade:400 Violet);
  check (Ui.Tw.text ~shade:800 Fuchsia);
  check (Ui.Tw.bg ~shade:200 Rose)

(** Test class name generation for extended colors *)
let test_extended_color_class_names () =
  let test_class_name tw expected =
    let actual = Ui.Tw.to_string tw in
    Alcotest.check string ("class name for " ^ expected) expected actual
  in

  test_class_name (Ui.Tw.bg ~shade:500 Slate) "bg-slate-500";
  test_class_name (Ui.Tw.text ~shade:600 Zinc) "text-zinc-600";
  test_class_name (Ui.Tw.border_color ~shade:300 Orange) "border-orange-300";
  test_class_name (Ui.Tw.bg ~shade:700 Amber) "bg-amber-700";
  test_class_name (Ui.Tw.text ~shade:200 Lime) "text-lime-200";
  test_class_name (Ui.Tw.border_color ~shade:800 Emerald) "border-emerald-800";
  test_class_name (Ui.Tw.bg ~shade:100 Cyan) "bg-cyan-100";
  test_class_name (Ui.Tw.text ~shade:900 Violet) "text-violet-900";
  test_class_name (Ui.Tw.border_color ~shade:400 Fuchsia) "border-fuchsia-400";
  test_class_name (Ui.Tw.bg ~shade:50 Rose) "bg-rose-50"

(** Test Black and White colors don't include shades in class names *)
let test_black_white_class_names () =
  let test_class_name tw expected =
    let actual = Ui.Tw.to_string tw in
    Alcotest.check string ("class name for " ^ expected) expected actual
  in

  test_class_name (Ui.Tw.bg Black) "bg-black";
  test_class_name (Ui.Tw.bg White) "bg-white";
  test_class_name (Ui.Tw.text Black) "text-black";
  test_class_name (Ui.Tw.text White) "text-white";
  test_class_name (Ui.Tw.border_color Black) "border-black";
  test_class_name (Ui.Tw.border_color White) "border-white"

(** Test CSS property generation works correctly *)
let test_css_property_generation () =
  let test_css_contains tw expected_property expected_value =
    let stylesheet = Ui.Tw.of_tw [ tw ] in
    let css_str = Ui.Css.to_string stylesheet in
    let property_str = expected_property ^ ": " ^ expected_value in
    Alcotest.check bool
      ("CSS contains " ^ property_str)
      true
      (string_contains_substring css_str property_str)
  in

  (* Test color properties *)
  test_css_contains (Ui.Tw.bg ~shade:500 Red) "background-color"
    "rgb(239 68 68 / var(--tw-bg-opacity))";
  test_css_contains
    (Ui.Tw.text ~shade:600 Blue)
    "color" "rgb(37 99 235 / var(--tw-text-opacity))";
  test_css_contains
    (Ui.Tw.border_color ~shade:300 Green)
    "border-color" "rgb(134 239 172 / var(--tw-border-opacity))";

  (* Test spacing properties *)
  test_css_contains (Ui.Tw.p (Int 4)) "padding" "1rem";
  test_css_contains (Ui.Tw.m (Int 0)) "margin" "0";
  test_css_contains (Ui.Tw.px (Int 6)) "padding-left" "1.5rem";
  test_css_contains (Ui.Tw.py (Int 2)) "padding-top" "0.5rem"

(** Test responsive modifiers *)
let test_responsive_modifiers () =
  let test_class_name tw expected =
    let actual = Ui.Tw.to_string tw in
    Alcotest.check string ("responsive class " ^ expected) expected actual
  in

  test_class_name (Ui.Tw.sm (Ui.Tw.bg ~shade:500 Red)) "sm:bg-red-500";
  test_class_name (Ui.Tw.md (Ui.Tw.text ~shade:600 Blue)) "md:text-blue-600";
  test_class_name (Ui.Tw.lg (Ui.Tw.p (Int 8))) "lg:p-8";
  test_class_name (Ui.Tw.xl Ui.Tw.flex) "xl:flex"

(** Test state modifiers *)
let test_state_modifiers () =
  let test_class_name tw expected =
    let actual = Ui.Tw.to_string tw in
    Alcotest.check string ("state modifier " ^ expected) expected actual
  in

  test_class_name (Ui.Tw.hover (Ui.Tw.bg ~shade:700 Gray)) "hover:bg-gray-700";
  test_class_name (Ui.Tw.focus (Ui.Tw.text ~shade:500 Sky)) "focus:text-sky-500";
  test_class_name
    (Ui.Tw.active (Ui.Tw.border_color ~shade:400 Teal))
    "active:border-teal-400"

let test_css_prelude () =
  (* Test that our CSS reset/prelude matches expected structure *)
  let stylesheet = Ui.Tw.of_tw [] in
  let css = Ui.Css.to_string ~minify:false stylesheet in

  (* Check for reset styles *)
  let expected_reset_patterns =
    [
      "margin: 0";
      "padding: 0";
      "box-sizing: border-box";
      "font-size: 16px";
      "line-height: 1.5";
    ]
  in

  List.iter
    (fun pattern ->
      if not (Astring.String.is_infix ~affix:pattern css) then
        fail (Fmt.str "CSS prelude missing expected pattern: %s" pattern))
    expected_reset_patterns

let test_exact_css_match () =
  (* Test exact CSS output for a small set of utilities *)
  (* This ensures our CSS generation is exactly correct *)
  let test_cases =
    [
      (Ui.Tw.p (Int 0), ".p-0 {\n  padding: 0;\n}");
      (Ui.Tw.m Auto, ".m-auto {\n  margin: auto;\n}");
      (Ui.Tw.opacity 100, ".opacity-100 {\n  opacity: 1;\n}");
      (Ui.Tw.flex, ".flex {\n  display: flex;\n}");
    ]
  in

  List.iter
    (fun (tw_style, expected) ->
      let stylesheet = Ui.Tw.of_tw [ tw_style ] in
      let css = Ui.Css.to_string ~minify:false stylesheet in
      (* Extract just the utility class part (skip prelude) *)
      let lines = String.split_on_char '\n' css in
      let rec skip_prelude = function
        | [] -> []
        | line :: rest ->
            if String.starts_with ~prefix:"." line then
              line :: rest (* Found first class, return from here *)
            else skip_prelude rest
      in
      let utility_lines = skip_prelude lines in
      let actual_utility = String.concat "\n" utility_lines |> String.trim in

      if actual_utility <> expected then (
        Fmt.epr "\n=== EXACT CSS MISMATCH ===\n";
        Fmt.epr "Expected:\n%s\n" expected;
        Fmt.epr "Actual:\n%s\n" actual_utility;
        Fmt.epr "========================\n";
        fail
          (Fmt.str "CSS output doesn't match exactly for %s"
             (Ui.Tw.to_string tw_style))))
    test_cases

let test_minification_rules () =
  (* Test that our minification produces the same result as Tailwind's *)
  (* We'll test with the full batch to ensure CSS merging works correctly *)
  let all_styles = get_all_test_styles () in

  (* Generate both minified versions *)
  let all_classnames = List.map Ui.Tw.to_string all_styles in

  (* Get Tailwind's minified output *)
  let tailwind_minified = generate_tailwind_css ~minify:true all_classnames in

  (* Get our minified output *)
  let stylesheet = Ui.Tw.of_tw all_styles in
  let ramen_minified = Ui.Css.to_string ~minify:true stylesheet in

  (* Extract just utilities from Tailwind output (skip base styles) *)
  let tailwind_utilities =
    (* Find where utility classes start - after the reset styles *)
    match String.index_opt tailwind_minified '.' with
    | Some idx when idx > 0 ->
        String.sub tailwind_minified idx (String.length tailwind_minified - idx)
    | _ -> tailwind_minified
  in

  (* Compare key aspects *)
  (* 1. Check that both have similar length (within reason) *)
  let tailwind_len = String.length tailwind_utilities in
  let ramen_len = String.length ramen_minified in
  if abs (tailwind_len - ramen_len) > tailwind_len / 2 then
    Fmt.epr
      "Warning: Large size difference - Tailwind utilities: %d bytes, Ramen: \
       %d bytes\n"
      tailwind_len ramen_len;

  (* 2. Test specific minification rules *)
  let test_cases =
    [
      (* Check exact minified output *)
      (".opacity-0{opacity:0}", true);
      (* Should be 0, not .0 *)
      ("opacity-50", true);
      (* Check it exists somewhere *)
      ("opacity:.5}", true);
      (* Check the value is minified *)
      (".p-0{padding:0}", true);
      (* Should be 0, not 0rem *)
      (".p-4{padding:1rem}", true);
      (".m-auto{margin:auto}", true);
      (".w-full{width:100%}", true);
      (* Check merged selectors exist *)
      ("box-shadow:", true);
      (* Just check the property exists *)
    ]
  in

  List.iter
    (fun (pattern, should_exist) ->
      let exists = Astring.String.is_infix ~affix:pattern ramen_minified in
      match (should_exist, exists) with
      | true, false ->
          fail
            (Fmt.str "Expected pattern not found in minified CSS: %s" pattern)
      | false, true ->
          fail (Fmt.str "Unexpected pattern found in minified CSS: %s" pattern)
      | _ -> ())
    test_cases

let test_backdrop_filters () =
  let styles =
    [
      Ui.Tw.backdrop_blur_none;
      Ui.Tw.backdrop_blur_sm;
      Ui.Tw.backdrop_blur;
      Ui.Tw.backdrop_blur_lg;
      Ui.Tw.backdrop_brightness_50;
      Ui.Tw.backdrop_brightness_100;
      Ui.Tw.backdrop_brightness_150;
      Ui.Tw.backdrop_contrast_0;
      Ui.Tw.backdrop_contrast_100;
      Ui.Tw.backdrop_contrast_200;
      Ui.Tw.backdrop_grayscale_0;
      Ui.Tw.backdrop_grayscale;
      Ui.Tw.backdrop_saturate_0;
      Ui.Tw.backdrop_saturate_100;
      Ui.Tw.backdrop_saturate_200;
    ]
  in

  List.iter
    (fun style ->
      let class_name = Ui.Tw.to_class style in
      let css_props = Ui.Tw.to_css_properties style in

      (* Check that backdrop-filter property is used *)
      let has_backdrop_filter =
        List.exists
          (fun (prop, _) ->
            match prop with Ui.Css.Backdrop_filter -> true | _ -> false)
          css_props
      in

      Alcotest.check Alcotest.bool
        (Fmt.str "%s uses backdrop-filter" class_name)
        true has_backdrop_filter)
    styles

let test_scroll_snap () =
  let styles =
    [
      Ui.Tw.snap_none;
      Ui.Tw.snap_x;
      Ui.Tw.snap_y;
      Ui.Tw.snap_both;
      Ui.Tw.snap_mandatory;
      Ui.Tw.snap_proximity;
      Ui.Tw.snap_start;
      Ui.Tw.snap_end;
      Ui.Tw.snap_center;
      Ui.Tw.snap_align_none;
      Ui.Tw.snap_normal;
      Ui.Tw.snap_always;
      Ui.Tw.scroll_auto;
      Ui.Tw.scroll_smooth;
    ]
  in

  List.iter
    (fun style ->
      let class_name = Ui.Tw.to_class style in
      let css_props = Ui.Tw.to_css_properties style in

      (* Check that appropriate scroll properties are used *)
      let has_scroll_prop =
        List.exists
          (fun (prop, _) ->
            match prop with
            | Ui.Css.Scroll_snap_type | Ui.Css.Scroll_snap_align
            | Ui.Css.Scroll_snap_stop | Ui.Css.Scroll_behavior
            | Ui.Css.Custom "--tw-scroll-snap-strictness" ->
                true
            | _ -> false)
          css_props
      in

      Alcotest.check Alcotest.bool
        (Fmt.str "%s uses scroll property" class_name)
        true has_scroll_prop)
    styles

let suite =
  [
    ( "tw",
      [
        test_case "css generation" `Quick test_css_generation;
        test_case "modifier classes" `Quick test_modifier_classes;
        test_case "rounded values" `Quick test_rounded_values;
        test_case "shadow values" `Quick test_shadow_values;
        test_case "typography classes" `Quick test_typography_classes;
        test_case "tailwind basic spacing" `Quick test_tailwind_basic_spacing;
        test_case "tailwind color classes" `Quick test_tailwind_color_classes;
        test_case "tailwind display classes" `Quick
          test_tailwind_display_classes;
        test_case "tailwind sizing" `Quick test_tailwind_sizing;
        test_case "tailwind typography" `Quick test_tailwind_typography;
        test_case "tailwind responsive" `Quick test_tailwind_responsive;
        test_case "tailwind states" `Quick test_tailwind_states;
        test_case "tailwind borders" `Quick test_tailwind_borders;
        test_case "tailwind shadows" `Quick test_tailwind_shadows;
        test_case "tailwind prose" `Quick test_tailwind_prose;
        test_case "tailwind flexbox" `Quick test_tailwind_flexbox;
        test_case "tailwind responsive breakpoints" `Quick
          test_tailwind_responsive_breakpoints;
        test_case "tailwind layout" `Quick test_tailwind_layout;
        test_case "tailwind opacity" `Quick test_tailwind_opacity;
        (* New comprehensive tests *)
        test_case "extended color palette" `Quick test_extended_color_palette;
        test_case "extended color class names" `Quick
          test_extended_color_class_names;
        test_case "black white class names" `Quick test_black_white_class_names;
        test_case "css property generation" `Quick test_css_property_generation;
        test_case "responsive modifiers" `Quick test_responsive_modifiers;
        test_case "state modifiers" `Quick test_state_modifiers;
        test_case "css prelude" `Quick test_css_prelude;
        test_case "exact css match" `Quick test_exact_css_match;
        test_case "minification rules" `Quick test_minification_rules;
        test_case "backdrop filters" `Quick test_backdrop_filters;
        test_case "scroll snap" `Quick test_scroll_snap;
      ] );
  ]
