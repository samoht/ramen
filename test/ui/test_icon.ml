(** Tests for the Icon module *)

open Alcotest

let test_svg () =
  let github_icon = Ui.Icon.github in
  let html_str = Ui.Html.to_string github_icon in

  check bool "is svg element" true
    (Astring.String.is_prefix ~affix:"<svg" html_str);
  check bool "has viewBox" true
    (Astring.String.is_infix ~affix:"viewBox=" html_str);
  check bool "has path element" true
    (Astring.String.is_infix ~affix:"<path" html_str)

let test_social_icons () =
  let twitter = Ui.Icon.twitter in
  let github = Ui.Icon.github in
  let linkedin = Ui.Icon.linkedin in

  let t_str = Ui.Html.to_string twitter in
  let g_str = Ui.Html.to_string github in
  let l_str = Ui.Html.to_string linkedin in

  (* All should be SVGs *)
  check bool "twitter is svg" true
    (Astring.String.is_prefix ~affix:"<svg" t_str);
  check bool "github is svg" true (Astring.String.is_prefix ~affix:"<svg" g_str);
  check bool "linkedin is svg" true
    (Astring.String.is_prefix ~affix:"<svg" l_str);

  (* All should have different paths (different icons) *)
  check bool "icons are different" false
    (t_str = g_str || g_str = l_str || t_str = l_str)

let test_other_icons () =
  let bluesky = Ui.Icon.bluesky in
  let rss = Ui.Icon.rss in
  let external_link = Ui.Icon.external_link in

  (* Check they all render as SVGs *)
  let b_str = Ui.Html.to_string bluesky in
  let r_str = Ui.Html.to_string rss in
  let e_str = Ui.Html.to_string external_link in

  check bool "bluesky is svg" true
    (Astring.String.is_prefix ~affix:"<svg" b_str);
  check bool "rss is svg" true (Astring.String.is_prefix ~affix:"<svg" r_str);
  check bool "external is svg" true
    (Astring.String.is_prefix ~affix:"<svg" e_str)

let suite =
  [
    ( "icon",
      [
        test_case "icon svg structure" `Quick test_svg;
        test_case "social icons" `Quick test_social_icons;
        test_case "other icons" `Quick test_other_icons;
      ] );
  ]
