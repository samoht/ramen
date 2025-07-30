(* Page test runner *)

let () =
  let open Alcotest in
  run "Page tests"
    (Test_blog.suite @ Test_feed.suite @ Test_index.suite @ Test_not_found.suite
   @ Test_papers.suite @ Test_post.suite @ Test_robots.suite
   @ Test_sitemap.suite)
