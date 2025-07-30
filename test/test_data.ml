(** Tests for the Data module *)

open Alcotest

let test_dummy () = check bool "dummy test" true true
let suite = [ ("data", [ test_case "dummy" `Quick test_dummy ]) ]
