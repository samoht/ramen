(** Tests for the Tw module *)

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
  test_class Ui.Tw.bg_white "background-color:#ffffff";
  test_class (Ui.Tw.text ~shade:900 Ui.Tw.Gray) "color:#111827";

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

let suite =
  [
    ( "tw",
      [
        test_case "css generation" `Quick test_css_generation;
        test_case "modifier classes" `Quick test_modifier_classes;
        test_case "rounded values" `Quick test_rounded_values;
        test_case "shadow values" `Quick test_shadow_values;
        test_case "typography classes" `Quick test_typography_classes;
      ] );
  ]
