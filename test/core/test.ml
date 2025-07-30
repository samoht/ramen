(* Core module test runner *)

let () =
  let open Alcotest in
  run "Core module tests"
    (Test_core.suite @ Test_pp.suite @ Test_author.suite @ Test_blog.suite
   @ Test_file.suite @ Test_page.suite @ Test_paper.suite @ Test_site.suite
   @ Test_date.suite @ Test_static.suite)
