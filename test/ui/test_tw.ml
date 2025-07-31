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
open Ui.Tw

(** No normalization - exact comparison *)
let exact_css css = String.trim css

let write_file path content =
  let oc = open_out path in
  output_string oc content;
  close_out oc

let create_tailwind_files temp_dir classnames =
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
  
  let input_css_content =
    "@tailwind base;\n@tailwind components;\n@tailwind utilities;\n"
  in
  
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
  
  write_file (Filename.concat temp_dir "input.html") html_content;
  write_file (Filename.concat temp_dir "input.css") input_css_content;
  write_file (Filename.concat temp_dir "tailwind.config.js") config_content

(** Generate CSS using the official tailwindcss binary *)
let generate_tailwind_css ?(minify = false) classnames =
  let temp_dir = Filename.temp_dir "ramen_test" "" in
  let css_file = Filename.concat temp_dir "output.css" in
  
  create_tailwind_files temp_dir classnames;
  
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
     let _ = Sys.command (Fmt.str "rm -rf %s" temp_dir) in
     failwith "tailwindcss command failed");
  
  (* Read generated CSS *)
  let ic = open_in css_file in
  let css = really_input_string ic (in_channel_length ic) in
  close_in ic;
  
  (* Cleanup *)
  let _ = Sys.command (Fmt.str "rm -rf %s" temp_dir) in
  css

(** Generate CSS using our Ramen implementation *)
let generate_ramen_css ?(minify = false) tw_styles =
  let stylesheet = to_css tw_styles in
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
let spacing_test_styles = [
  (* Basic spacing - comprehensive *)
  p (int 0);
  p (int 1);
  p (int 4);
  m (int 0);
  m (int 2);
  m auto;
  px (int 6);
  py (int 3);
  pt (int 1);
  pr (int 8);
  pb (int 12);
  pl (int 16);
  mx (int 0);
  mx auto;
  my (int 10);
  mt (int 20);
  mr (int 24);
  mb (int 56);
  ml (int 6);
]

let color_test_styles = [
  (* Color classes - all variants *)
  bg white;
  bg black;
  bg_transparent;
  bg_current;
  text ~shade:900 gray;
  text_transparent;
  text_current;
  border_color ~shade:200 gray;
  border_transparent;
  border_current;
  bg ~shade:500 gray;
  bg ~shade:600 sky;
  text ~shade:400 yellow;
  border_color ~shade:600 teal;
]

let display_test_styles = [
  (* Display - comprehensive *)
  block;
  inline;
  inline_block;
  flex;
  inline_flex;
  grid;
  inline_grid;
  hidden;
]

let sizing_test_styles = [
  (* Sizing - comprehensive *)
  w (int 0);
  w (int 4);
  w (int 96);
  w fit;
  w full;
  min_w min;
  min_w max;
  h (int 0);
  h (int 8);
  h fit;
  h full;
  min_w (int 0);
  min_w full;
  max_w xs;
  max_w sm;
  max_w md;
  max_w lg;
  max_w xl;
  max_w xl_2;
  max_w xl_7;
  max_w full;
  max_w none;
]

let typography_test_styles = [
  (* Typography - comprehensive *)
  text_xs;
  text_sm;
  text_base;
  text_lg;
  text_xl;
  text_2xl;
  text_3xl;
  text_4xl;
  font_normal;
  font_medium;
  font_semibold;
  font_bold;
  text_left;
  text_center;
  text_right;
  text_justify;
  leading_none;
  leading_tight;
  leading_normal;
  leading_relaxed;
  tracking_tight;
  tracking_normal;
  tracking_wide;
  whitespace_normal;
  whitespace_nowrap;
]

let responsive_test_styles = [
  (* Responsive - more comprehensive *)
  on_sm [ block ];
  on_md [ flex ];
  on_lg [ grid ];
  on_xl [ hidden ];
  on_sm [ p (int 4) ];
  on_md [ m (int 6) ];
  on_lg [ text_lg ];
  on_xl [ font_bold ];
]

let states_test_styles = [
  (* States - more comprehensive *)
  on_hover [ bg white ];
  on_hover [ text ~shade:700 blue ];
  on_focus [ bg ~shade:500 sky ];
  on_focus [ outline_none ];
  on_active [ text ~shade:900 gray ];
  on_disabled [ opacity 50 ];
]

let borders_test_styles = [
  (* Borders - comprehensive *)
  rounded none;
  rounded sm;
  rounded md;
  rounded lg;
  rounded xl;
  rounded full;
  border `Default;
  border `None;
  border `Sm;
  border `Lg;
  border `Xl;
  border_t;
  border_r;
  border_b;
  border_l;
]

let shadows_test_styles = [
  (* Shadows *)
  shadow sm;
  shadow md;
  shadow lg;
  shadow xl;
  shadow none;
  shadow inner;
]

let prose_test_styles = [
  (* Prose *)
  prose;
  prose_sm;
  prose_lg;
  prose_xl;
  prose_gray;
]

let flexbox_test_styles = [
  (* Flexbox - comprehensive *)
  flex_col;
  flex_row;
  flex_row_reverse;
  flex_col_reverse;
  flex_wrap;
  flex_wrap_reverse;
  flex_nowrap;
  flex_1;
  flex_auto;
  flex_initial;
  flex_none;
  flex_grow;
  flex_grow_0;
  flex_shrink;
  flex_shrink_0;
  items_start;
  items_center;
  items_end;
  items_stretch;
  justify_start;
  justify_center;
  justify_end;
  justify_between;
  justify_around;
  justify_evenly;
]

let grid_test_styles = [
  (* Grid *)
  grid_cols 1;
  grid_cols 2;
  grid_cols 3;
  grid_cols 12;
  gap (int 4);
  gap_x (int 2);
  gap_y (int 6);
]

let layout_test_styles = [
  (* Layout - comprehensive *)
  static;
  relative;
  absolute;
  fixed;
  sticky;
  inset_0;
  inset_x_0;
  inset_y_0;
  top 0;
  right 0;
  bottom 0;
  left 0;
  z 0;
  z 10;
  z 10;
  (* Overflow *)
  overflow_auto;
  overflow_hidden;
  overflow_visible;
  overflow_scroll;
]

let misc_test_styles = [
  (* Opacity *)
  opacity 0;
  opacity 25;
  opacity 50;
  opacity 75;
  opacity 100;
  (* Transitions *)
  transition_none;
  transition_all;
  transition_colors;
  transition_opacity;
  transition_transform;
  (* Transforms *)
  transform;
  transform_none;
  scale 75;
  scale 100;
  scale 125;
  rotate 45;
  rotate 90;
  translate_x 4;
  translate_y 2;
  (* Cursor *)
  cursor_auto;
  cursor_default;
  cursor_pointer;
  cursor_not_allowed;
  (* User Select *)
  select_none;
  select_text;
  select_all;
  select_auto;
]

let extended_colors_test_styles = [
  (* Extended colors - all 10 new colors *)
  bg ~shade:50 slate;
  bg ~shade:500 zinc;
  bg ~shade:900 orange;
  text ~shade:100 amber;
  text ~shade:600 lime;
  border_color ~shade:300 emerald;
  border_color ~shade:700 cyan;
  bg ~shade:400 violet;
  text ~shade:800 fuchsia;
  bg ~shade:200 rose;
]

let get_all_test_styles () =
  spacing_test_styles @
  color_test_styles @
  display_test_styles @
  sizing_test_styles @
  typography_test_styles @
  responsive_test_styles @
  states_test_styles @
  borders_test_styles @
  shadows_test_styles @
  prose_test_styles @
  flexbox_test_styles @
  grid_test_styles @
  layout_test_styles @
  misc_test_styles @
  extended_colors_test_styles

(** Cache for Tailwind CSS generation with class list hash *)
let tailwind_cache_unminified = ref None

let tailwind_cache_minified = ref None

(** Generate all Tailwind CSS at once *)
let generate_all_tailwind_css ?(minify = false) () =
  let all_styles = get_all_test_styles () in
  let all_classnames = List.map to_string all_styles in

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
    let classname = to_string tw_style in
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
      Fmt.epr "\n=== UTILITY CSS MISMATCH for %s ===\n" classname;
      Fmt.epr "Ramen utility CSS:\n%s\n" ramen_utility_css;
      Fmt.epr "Tailwind utility CSS:\n%s\n" tailwind_utility_css;
      Fmt.epr "===============================\n");

    Alcotest.check string
      (Fmt.str "%s utility CSS exact match" classname)
      tailwind_utility_css ramen_utility_css
  with
  | Failure msg -> fail ("Test setup failed: " ^ msg)
  | exn -> fail ("Unexpected error: " ^ Printexc.to_string exn)

(** Main check function - only test exact match for now *)
let check tw_style = check_exact_match tw_style

let test_tailwind_basic_spacing () =
  check (p (int 4));
  check (m (int 2));
  check (px (int 6));
  check (py (int 3));
  check (pt (int 1));
  check (pr (int 8));
  check (pb (int 12));
  check (pl (int 16));
  check (mx (int 0));
  check (my (int 10));
  check (mt (int 20));
  check (mr (int 24));
  check (mb (int 56));
  check (ml (int 6))

let test_tailwind_color_classes () =
  check (bg white);
  check (text ~shade:900 gray);
  (* Using consistent API: border should work like bg and text *)
  check (border_color ~shade:200 gray);
  check (bg ~shade:500 gray);
  check (bg ~shade:600 sky);
  check (text ~shade:400 yellow);
  check (border_color ~shade:600 teal)

let test_tailwind_display_classes () =
  check block;
  check inline;
  check inline_block;
  check flex;
  check inline_flex;
  check grid;
  check inline_grid;
  check hidden

let test_tailwind_sizing () =
  check (w (int 4));
  check (h (int 8));
  check (w fit);
  check (w full);
  check (h fit);
  check (h full);
  check (min_w (int 0))

let test_tailwind_typography () =
  check text_xs;
  check text_sm;
  check text_base;
  check text_lg;
  check text_xl;
  check text_2xl;
  check font_normal;
  check font_medium;
  check font_semibold;
  check font_bold

let test_tailwind_responsive () =
  check (on_md [ block ]);
  check (on_lg [ flex ]);
  check (on_xl [ hidden ]);
  check (on_sm [ p (int 4) ]);
  check (on_md [ m (int 6) ])

let test_tailwind_states () =
  check (on_hover [ bg white ]);
  check (on_focus [ bg ~shade:500 sky ]);
  check (on_active [ text ~shade:900 gray ])

let test_tailwind_borders () =
  check (rounded md);
  check (rounded lg);
  check (rounded full);
  check (border `Default);
  check (border `Sm);
  check (border `Lg)

let test_tailwind_shadows () =
  check (shadow sm);
  check (shadow md);
  check (shadow lg);
  check (shadow none)

let test_tailwind_prose () =
  check prose;
  check prose_sm;
  check prose_lg;
  check prose_xl

let test_tailwind_flexbox () =
  check flex_col;
  check flex_row;
  check flex_row_reverse;
  check flex_col_reverse;
  check flex_wrap;
  check flex_wrap_reverse;
  check items_center;
  check justify_center;
  check justify_between

let test_tailwind_responsive_breakpoints () =
  check (on_sm [ block ]);
  check (on_md [ flex ]);
  check (on_lg [ grid ]);
  check (on_xl [ hidden ]);
  check (on_sm [ text_lg ]);
  check (on_md [ p (int 8) ]);
  check (on_lg [ bg ~shade:500 sky ])

let test_tailwind_layout () =
  check relative;
  check absolute;
  check fixed;
  check sticky

let test_tailwind_opacity () =
  check (opacity 0);
  check (opacity 50);
  check (opacity 100)

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
  check (bg ~shade:50 slate);
  check (bg ~shade:500 zinc);
  check (bg ~shade:900 orange);
  check (text ~shade:100 amber);
  check (text ~shade:600 lime);
  check (border_color ~shade:300 emerald);
  check (border_color ~shade:700 cyan);
  check (bg ~shade:400 violet);
  check (text ~shade:800 fuchsia);
  check (bg ~shade:200 rose)

(** Test class name generation for extended colors *)
let test_extended_color_class_names () =
  let test_class_name tw expected =
    let actual = to_string tw in
    Alcotest.check string ("class name for " ^ expected) expected actual
  in

  test_class_name (bg ~shade:500 slate) "bg-slate-500";
  test_class_name (text ~shade:600 zinc) "text-zinc-600";
  test_class_name (border_color ~shade:300 orange) "border-orange-300";
  test_class_name (bg ~shade:700 amber) "bg-amber-700";
  test_class_name (text ~shade:200 lime) "text-lime-200";
  test_class_name (border_color ~shade:800 emerald) "border-emerald-800";
  test_class_name (bg ~shade:100 cyan) "bg-cyan-100";
  test_class_name (text ~shade:900 violet) "text-violet-900";
  test_class_name (border_color ~shade:400 fuchsia) "border-fuchsia-400";
  test_class_name (bg ~shade:50 rose) "bg-rose-50"

(** Test Black and White colors don't include shades in class names *)
let test_black_white_class_names () =
  let test_class_name tw expected =
    let actual = to_string tw in
    Alcotest.check string ("class name for " ^ expected) expected actual
  in

  test_class_name (bg black) "bg-black";
  test_class_name (bg white) "bg-white";
  test_class_name (text black) "text-black";
  test_class_name (text white) "text-white";
  test_class_name (border_color black) "border-black";
  test_class_name (border_color white) "border-white"

(** Test CSS property generation works correctly *)
let test_css_property_generation () =
  let test_css_contains tw expected_property expected_value =
    let stylesheet = to_css [ tw ] in
    let css_str = Ui.Css.to_string stylesheet in
    let property_str = expected_property ^ ": " ^ expected_value in
    Alcotest.check bool
      ("CSS contains " ^ property_str)
      true
      (string_contains_substring css_str property_str)
  in

  (* Test color properties *)
  test_css_contains (bg ~shade:500 red) "background-color"
    "rgb(239 68 68 / var(--tw-bg-opacity))";
  test_css_contains (text ~shade:600 blue) "color"
    "rgb(37 99 235 / var(--tw-text-opacity))";
  test_css_contains
    (border_color ~shade:300 green)
    "border-color" "rgb(134 239 172 / var(--tw-border-opacity))";

  (* Test spacing properties *)
  test_css_contains (p (int 4)) "padding" "1rem";
  test_css_contains (m (int 0)) "margin" "0";
  test_css_contains (px (int 6)) "padding-left" "1.5rem";
  test_css_contains (py (int 2)) "padding-top" "0.5rem"

(** Test responsive modifiers *)
let test_responsive_modifiers () =
  let test_class_name tw expected =
    let actual = to_string tw in
    Alcotest.check string ("responsive class " ^ expected) expected actual
  in

  test_class_name (on_sm [ bg ~shade:500 red ]) "sm:bg-red-500";
  test_class_name (on_md [ text ~shade:600 blue ]) "md:text-blue-600";
  test_class_name (on_lg [ p (int 8) ]) "lg:p-8";
  test_class_name (on_xl [ flex ]) "xl:flex"

(** Test state modifiers *)
let test_state_modifiers () =
  let test_class_name tw expected =
    let actual = to_string tw in
    Alcotest.check string ("state modifier " ^ expected) expected actual
  in

  test_class_name (on_hover [ bg ~shade:700 gray ]) "hover:bg-gray-700";
  test_class_name (on_focus [ text ~shade:500 sky ]) "focus:text-sky-500";
  test_class_name
    (on_active [ border_color ~shade:400 teal ])
    "active:border-teal-400"

let test_css_prelude () =
  (* Test that our CSS reset/prelude matches expected structure *)
  let stylesheet = to_css [] in
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
      (p (int 0), ".p-0 {\n  padding: 0;\n}");
      (m auto, ".m-auto {\n  margin: auto;\n}");
      (opacity 100, ".opacity-100 {\n  opacity: 1;\n}");
      (flex, ".flex {\n  display: flex;\n}");
    ]
  in

  List.iter
    (fun (tw_style, expected) ->
      let stylesheet = to_css [ tw_style ] in
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
             (to_string tw_style))))
    test_cases

let check_minification_pattern ramen_minified (pattern, should_exist) =
  let exists = Astring.String.is_infix ~affix:pattern ramen_minified in
  match (should_exist, exists) with
  | true, false ->
      fail (Fmt.str "Expected pattern not found in minified CSS: %s" pattern)
  | false, true ->
      fail (Fmt.str "Unexpected pattern found in minified CSS: %s" pattern)
  | _ -> ()

let extract_utilities_from_tailwind tailwind_minified =
  match String.index_opt tailwind_minified '.' with
  | Some idx when idx > 0 ->
      String.sub tailwind_minified idx (String.length tailwind_minified - idx)
  | _ -> tailwind_minified

let test_minification_rules () =
  let all_styles = get_all_test_styles () in
  let all_classnames = List.map to_string all_styles in
  
  (* Get Tailwind's minified output *)
  let tailwind_minified = generate_tailwind_css ~minify:true all_classnames in
  let tailwind_utilities = extract_utilities_from_tailwind tailwind_minified in
  
  (* Get our minified output *)
  let stylesheet = to_css all_styles in
  let ramen_minified = Ui.Css.to_string ~minify:true stylesheet in
  
  (* Check size difference *)
  let tailwind_len = String.length tailwind_utilities in
  let ramen_len = String.length ramen_minified in
  if abs (tailwind_len - ramen_len) > tailwind_len / 2 then
    Fmt.epr
      "Warning: Large size difference - Tailwind utilities: %d bytes, Ramen: %d bytes\n"
      tailwind_len ramen_len;
  
  (* Test specific minification rules *)
  let test_cases = [
    (".opacity-0{opacity:0}", true);
    ("opacity-50", true);
    ("opacity:.5}", true);
    (".p-0{padding:0}", true);
    (".p-4{padding:1rem}", true);
    (".m-auto{margin:auto}", true);
    (".w-full{width:100%}", true);
    ("box-shadow:", true);
  ] in
  
  List.iter (check_minification_pattern ramen_minified) test_cases

let test_scroll_snap () =
  let styles =
    [
      snap_none;
      snap_x;
      snap_y;
      snap_both;
      snap_mandatory;
      snap_proximity;
      snap_start;
      snap_end;
      snap_center;
      snap_align_none;
      snap_normal;
      snap_always;
      scroll_auto;
      scroll_smooth;
    ]
  in

  List.iter
    (fun style ->
      let class_name = to_class style in
      let css_props = to_css_properties style in

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

let test_data_attributes () =
  (* Test that data attribute variants generate correct selectors *)
  let test_cases =
    [
      ( data_state "open" block,
        ".block[data-state=\"open\"] {\n  display: block;\n}" );
      ( data_variant "primary" (bg white),
        ".bg-white[data-variant=\"primary\"] {\n\
        \  --tw-bg-opacity: 1;\n\
        \  background-color: rgb(255 255 255 / var(--tw-bg-opacity));\n\
         }" );
      ( on_data_active [ text white ],
        ".text-white[data-active] {\n\
        \  --tw-text-opacity: 1;\n\
        \  color: rgb(255 255 255 / var(--tw-text-opacity));\n\
         }" );
      ( on_data_inactive [ hidden ],
        ".hidden[data-inactive] {\n  display: none;\n}" );
      ( data_custom "theme" "dark" flex,
        ".flex[data-theme=\"dark\"] {\n  display: flex;\n}" );
    ]
  in

  List.iter
    (fun (tw_style, expected) ->
      let stylesheet = to_css [ tw_style ] in
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
        Fmt.epr "\n=== DATA ATTRIBUTE CSS MISMATCH ===\n";
        Fmt.epr "Expected:\n%s\n" expected;
        Fmt.epr "Actual:\n%s\n" actual_utility;
        Fmt.epr "====================================\n";
        fail
          (Fmt.str "CSS output doesn't match exactly for data attribute variant")))
    test_cases

(* CSS Generation tests *)
let test_inline_styles () =
  let styles = [ bg blue; text white; p (int 4); m (int 2); rounded md ] in
  let inline = to_inline_style styles in
  (* Check that inline styles are generated *)
  Alcotest.check bool "has background-color" true
    (Astring.String.is_infix ~affix:"background-color" inline);
  Alcotest.check bool "has color" true
    (Astring.String.is_infix ~affix:"color" inline);
  Alcotest.check bool "has padding" true
    (Astring.String.is_infix ~affix:"padding" inline);
  Alcotest.check bool "has margin" true
    (Astring.String.is_infix ~affix:"margin" inline);
  Alcotest.check bool "has border-radius" true
    (Astring.String.is_infix ~affix:"border-radius" inline)

let test_dynamic_inline_styles () =
  (* Test dynamic style generation *)
  let dynamic_width = 42 in
  let styles = [ w (int dynamic_width); bg ~shade:300 gray; p (int 2) ] in
  let inline = to_inline_style styles in

  (* Check that dynamic value is included *)
  Alcotest.check bool "has dynamic width" true
    (Astring.String.is_infix
       ~affix:(string_of_float (float_of_int dynamic_width *. 0.25) ^ "rem")
       inline)

let suite =
  [
    ( "tw",
      [
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
        test_case "scroll snap" `Quick test_scroll_snap;
        test_case "data attributes" `Quick test_data_attributes;
        (* CSS generation tests *)
        test_case "inline styles" `Quick test_inline_styles;
        test_case "dynamic inline styles" `Quick test_dynamic_inline_styles;
      ] );
  ]
