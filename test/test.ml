(** Main test runner that aggregates all test suites *)

let () =
  Alcotest.run "Ramen tests"
    (Test_init.suite @ Test_serve.suite @ Test_build.suite @ Test_config.suite
   @ Test_data.suite @ Test_engine.suite @ Test_validation.suite
   @ Test_frontmatter.suite)
