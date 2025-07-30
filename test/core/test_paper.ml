(** Tests for the Paper module *)

open Alcotest

let paper_testable = testable (Fmt.of_to_string Core.Paper.pp) ( = )

let test_creation () =
  let paper =
    {
      Core.Paper.title = "OCaml for Scientific Computing";
      authors =
        [
          { name = "Jane Doe"; url = Some "https://janedoe.com" };
          { name = "John Smith"; url = None };
        ];
      where = "ICFP 2024";
      year = "2024";
      abstract =
        Some "This paper explores the use of OCaml in scientific computing...";
      files =
        [
          { name = "PDF"; url = "/papers/ocaml-scientific.pdf" };
          { name = "Slides"; url = "/papers/ocaml-scientific-slides.pdf" };
        ];
    }
  in

  check string "paper title" "OCaml for Scientific Computing" paper.title;
  check string "paper venue" "ICFP 2024" paper.where;
  check string "paper year" "2024" paper.year;
  check int "author count" 2 (List.length paper.authors);
  check int "file count" 2 (List.length paper.files)

let test_author () =
  let author1 = { Core.Paper.name = "Alice"; url = Some "https://alice.com" } in
  let author2 = { Core.Paper.name = "Bob"; url = None } in

  check string "author name" "Alice" author1.name;
  check (option string) "author url" (Some "https://alice.com") author1.url;
  check (option string) "no author url" None author2.url

let test_file () =
  let file : Core.Paper.file =
    { name = "Preprint"; url = "/papers/preprint.pdf" }
  in

  check string "file name" "Preprint" file.name;
  check string "file url" "/papers/preprint.pdf" file.url

let test_pp () =
  let paper =
    {
      Core.Paper.title = "Test Paper";
      authors = [ { name = "Test Author"; url = None } ];
      where = "Test Conference";
      year = "2023";
      abstract = None;
      files = [];
    }
  in

  let pp_output = Core.Paper.pp paper in
  check bool "pp contains title" true
    (Astring.String.is_infix ~affix:"Test Paper" pp_output);
  check bool "pp contains venue" true
    (Astring.String.is_infix ~affix:"Test Conference" pp_output);
  check bool "pp contains year" true
    (Astring.String.is_infix ~affix:"2023" pp_output)

let test_equality () =
  let paper1 =
    {
      Core.Paper.title = "Paper 1";
      authors = [];
      where = "Venue";
      year = "2024";
      abstract = None;
      files = [];
    }
  in
  let paper2 = { paper1 with title = "Paper 2" } in

  check paper_testable "same paper" paper1 paper1;
  check bool "different papers" false (paper1 = paper2)

let suite =
  [
    ( "paper",
      [
        test_case "creation" `Quick test_creation;
        test_case "author" `Quick test_author;
        test_case "file" `Quick test_file;
        test_case "pretty printing" `Quick test_pp;
        test_case "equality" `Quick test_equality;
      ] );
  ]
