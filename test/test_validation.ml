(** Tests for the Validation module *)

open Alcotest

let test_dummy () = check bool "dummy test" true true
let suite = [ ("validation", [ test_case "dummy" `Quick test_dummy ]) ]
