(* UI component test runner *)

let () =
  let open Alcotest in
  run "UI component tests"
    (Test_tw.suite @ Test_avatar.suite @ Test_css.suite @ Test_footer.suite
   @ Test_header.suite @ Test_html.suite @ Test_icon.suite @ Test_layout.suite
   @ Test_socials.suite @ Test_author_card.suite @ Test_heading.suite
   @ Test_link.suite @ Test_prose.suite @ Test_section.suite @ Test_colors.suite
   @ Test_button.suite @ Test_hero.suite @ Test_card.suite)
