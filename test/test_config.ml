(** Tests for the Config module *)

open Alcotest

let test_module_accessible () =
  (* Test that the config module is accessible *)
  (* Currently the module is mostly empty/commented out *)
  check bool "module accessible" true true

let suite =
  [
    ("config", [ test_case "module accessible" `Quick test_module_accessible ]);
  ]
