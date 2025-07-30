(** Tests for CSS generation *)

open Alcotest

let test_rule_to_string () =
  let rule =
    Ui.Css.rule ~selector:".test-class"
      [
        (Ui.Css.Background_color, "#ffffff");
        (Ui.Css.Color, "#000000");
        (Ui.Css.Padding, "1rem");
      ]
  in

  let css_str = Ui.Css.rule_to_string rule in
  check bool "contains selector" true
    (Astring.String.is_infix ~affix:".test-class" css_str);
  check bool "contains background-color" true
    (Astring.String.is_infix ~affix:"background-color" css_str);
  check bool "contains color" true
    (Astring.String.is_infix ~affix:"color" css_str);
  check bool "contains padding" true
    (Astring.String.is_infix ~affix:"padding" css_str)

let test_media_query_to_string () =
  let rule1 =
    Ui.Css.rule ~selector:".responsive"
      [ (Ui.Css.Display, "flex"); (Ui.Css.Width, "100%") ]
  in
  let rule2 =
    Ui.Css.rule ~selector:".container" [ (Ui.Css.Max_width, "1200px") ]
  in

  let media_query =
    Ui.Css.media ~condition:"(min-width: 768px)" [ rule1; rule2 ]
  in
  let css_str = Ui.Css.media_query_to_string media_query in

  check bool "contains media query" true
    (Astring.String.is_infix ~affix:"@media (min-width: 768px)" css_str);
  check bool "contains display flex" true
    (Astring.String.is_infix ~affix:"display" css_str);
  check bool "contains max-width" true
    (Astring.String.is_infix ~affix:"max-width" css_str)

let test_to_string () =
  let rules =
    [
      Ui.Css.rule ~selector:"body"
        [ (Ui.Css.Font_size, "16px"); (Ui.Css.Line_height, "1.5") ];
      Ui.Css.rule ~selector:".container"
        [ (Ui.Css.Max_width, "1200px"); (Ui.Css.Margin, "0 auto") ];
    ]
  in

  let media_queries =
    [
      Ui.Css.media ~condition:"(min-width: 768px)"
        [ Ui.Css.rule ~selector:".responsive" [ (Ui.Css.Display, "flex") ] ];
    ]
  in

  let stylesheet = Ui.Css.stylesheet ~media_queries rules in
  let css_str = Ui.Css.to_string stylesheet in

  check bool "contains body rule" true
    (Astring.String.is_infix ~affix:"body" css_str);
  check bool "contains container rule" true
    (Astring.String.is_infix ~affix:".container" css_str);
  check bool "contains media query" true
    (Astring.String.is_infix ~affix:"@media" css_str)

let test_merge_rules () =
  let rules =
    [
      Ui.Css.rule ~selector:".btn"
        [ (Ui.Css.Background_color, "blue"); (Ui.Css.Color, "white") ];
      Ui.Css.rule ~selector:".btn"
        [ (Ui.Css.Padding, "10px"); (Ui.Css.Border_radius, "5px") ];
      Ui.Css.rule ~selector:".card" [ (Ui.Css.Border_width, "1px") ];
    ]
  in

  let merged = Ui.Css.merge_rules rules in

  (* Should have 2 rules after merging .btn rules *)
  check int "number of rules after merge" 2 (List.length merged);

  (* Find the merged .btn rule *)
  let btn_rule = List.find (fun r -> r.Ui.Css.selector = ".btn") merged in
  check int "merged .btn properties count" 4 (List.length btn_rule.properties)

let suite =
  [
    ( "css",
      [
        test_case "rule to string" `Quick test_rule_to_string;
        test_case "media query to string" `Quick test_media_query_to_string;
        test_case "to string" `Quick test_to_string;
        test_case "merge rules" `Quick test_merge_rules;
      ] );
  ]
