(** Tests for the Engine module *)

open Alcotest

let test_dummy () = check bool "dummy test" true true
let suite = [ ("engine", [ test_case "dummy" `Quick test_dummy ]) ]
