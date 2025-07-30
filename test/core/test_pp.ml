(** Tests for the Pp module *)

open Alcotest
open Core

let test_field () =
  let field = Pp.field "name" "value" in
  check string "field format" "name = value;" field

let test_option () =
  let pp_string = Pp.string in
  check string "some value" "Some (test)" (Pp.option pp_string (Some "test"));
  check string "none value" "None" (Pp.option pp_string None)

let test_list () =
  let pp_int = Pp.int in
  check string "empty list" "[]" (Pp.list pp_int []);
  check string "single item" "[1]" (Pp.list pp_int [ 1 ]);
  check string "multiple items" "[1, 2, 3]" (Pp.list pp_int [ 1; 2; 3 ]);
  check string "custom separator" "[1, 2, 3]"
    (Pp.list ~sep:", " pp_int [ 1; 2; 3 ])

let test_record () =
  let fields = [ ("name", "test"); ("age", "42"); ("active", "true") ] in
  let result = Pp.record fields in
  check bool "contains opening brace" true
    (Astring.String.is_infix ~affix:"{" result);
  check bool "contains closing brace" true
    (Astring.String.is_infix ~affix:"}" result);
  check bool "contains fields" true
    (Astring.String.is_infix ~affix:"name = test" result)

let test_primitives () =
  check string "bool true" "true" (Pp.bool true);
  check string "bool false" "false" (Pp.bool false);
  check string "int" "42" (Pp.int 42);
  check string "float" "3.14" (Pp.float 3.14);
  check string "string" "hello" (Pp.string "hello")

let suite =
  [
    ( "pp",
      [
        test_case "field formatting" `Quick test_field;
        test_case "option formatting" `Quick test_option;
        test_case "list formatting" `Quick test_list;
        test_case "record formatting" `Quick test_record;
        test_case "primitive formatting" `Quick test_primitives;
      ] );
  ]
