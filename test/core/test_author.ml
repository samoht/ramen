(** Tests for the Author module *)

open Alcotest

(* Use the testable value from test_core.ml *)
let author_testable = testable (Fmt.of_to_string Core.Author.pp) ( = )

let test_creation () =
  let author =
    {
      Core.Author.name = "John Doe";
      title = Some "Software Engineer";
      hidden = false;
      avatar = Some "/images/john.jpg";
      slug = "john-doe";
      aliases = [ "jdoe"; "john" ];
      homepage = Some "https://johndoe.com";
    }
  in

  check string "author name" "John Doe" author.name;
  check string "author slug" "john-doe" author.slug;
  check (option string) "author title" (Some "Software Engineer") author.title;
  check bool "author not hidden" false author.hidden

let test_equality () =
  let author1 =
    {
      Core.Author.name = "Jane Smith";
      title = None;
      hidden = true;
      avatar = None;
      slug = "jane-smith";
      aliases = [];
      homepage = None;
    }
  in
  let author2 = { author1 with name = "Jane Doe" } in

  check author_testable "same author" author1 author1;
  check bool "different authors" false (author1 = author2)

let test_pp () =
  let author =
    {
      Core.Author.name = "Test Author";
      title = Some "Tester";
      hidden = false;
      avatar = None;
      slug = "test-author";
      aliases = [ "test"; "tester" ];
      homepage = Some "https://test.com";
    }
  in

  let pp_output = Core.Author.pp author in
  check bool "pp contains name" true
    (Astring.String.is_infix ~affix:"Test Author" pp_output);
  check bool "pp contains slug" true
    (Astring.String.is_infix ~affix:"test-author" pp_output);
  check bool "pp contains aliases" true
    (Astring.String.is_infix ~affix:"test" pp_output)

let test_by_name () =
  let authors =
    [
      {
        Core.Author.name = "John Doe";
        title = Some "Developer";
        hidden = false;
        avatar = None;
        slug = "john-doe";
        aliases = [ "john"; "jdoe" ];
        homepage = None;
      };
      {
        Core.Author.name = "Jane Smith";
        title = None;
        hidden = false;
        avatar = None;
        slug = "jane-smith";
        aliases = [ "jane" ];
        homepage = None;
      };
    ]
  in

  (* Test finding by exact name *)
  let found1 = Core.Author.by_name authors "John Doe" in
  check bool "found by name" true (found1 <> None);

  (* Test finding by alias *)
  let found2 = Core.Author.by_name authors "jane" in
  check bool "found by alias" true (found2 <> None);

  (* Test not found *)
  let not_found = Core.Author.by_name authors "Unknown" in
  check bool "not found" true (not_found = None)

let suite =
  [
    ( "author",
      [
        test_case "creation" `Quick test_creation;
        test_case "equality" `Quick test_equality;
        test_case "pretty printing" `Quick test_pp;
        test_case "find by name" `Quick test_by_name;
      ] );
  ]
