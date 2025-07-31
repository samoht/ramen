(** Tests for the Papers page module *)

open Alcotest
open Views
open Core

let test_paper ~title ~where ~year ~files =
  {
    Paper.title;
    authors =
      [
        { name = "Test Author"; url = None };
        { name = "Co Author"; url = Some "https://coauthor.com" };
      ];
    where;
    year;
    abstract = Some "This is the abstract of the paper.";
    files;
  }

let test_render_papers_list () =
  let site =
    {
      Site.name = "Research Site";
      url = "https://research.com";
      title = "Research Papers";
      tagline = "Academic publications";
      description = "List of research papers";
      author = "Research Author";
      author_email = "research@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Research"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let papers =
    [
      test_paper ~title:"First Paper" ~where:"ICFP 2024" ~year:"2024"
        ~files:[ { Paper.name = "PDF"; url = "/papers/first.pdf" } ];
      test_paper ~title:"Second Paper" ~where:"POPL 2023" ~year:"2023"
        ~files:[ { Paper.name = "PDF"; url = "/papers/second.pdf" } ];
      test_paper ~title:"Third Paper" ~where:"PLDI 2023" ~year:"2023" ~files:[];
    ]
  in

  let layout = Papers.render ~site ~papers in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "contains papers page title" true
    (Astring.String.is_infix ~affix:"Papers" html
    || Astring.String.is_infix ~affix:"Publications" html);
  check bool "contains first paper" true
    (Astring.String.is_infix ~affix:"First Paper" html);
  check bool "contains venue" true (Astring.String.is_infix ~affix:"ICFP" html);
  check bool "has PDF link" true
    (Astring.String.is_infix ~affix:"first.pdf" html)

let test_render_empty_papers () =
  let site =
    {
      Site.name = "No Papers Site";
      url = "https://nopapers.com";
      title = "No Papers";
      tagline = "No publications yet";
      description = "Site with no papers";
      author = "New Researcher";
      author_email = "new@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© New"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let layout = Papers.render ~site ~papers:[] in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "has papers page structure" true
    (Astring.String.is_infix ~affix:"Papers" html
    || Astring.String.is_infix ~affix:"Publications" html)

let test_render_papers_by_year () =
  let site =
    {
      Site.name = "Papers by Year";
      url = "https://yearly.com";
      title = "Yearly Papers";
      tagline = "Organized by year";
      description = "Papers organized by year";
      author = "Yearly Author";
      author_email = "yearly@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Yearly"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let papers =
    [
      test_paper ~title:"2024 Paper A" ~where:"Conf A" ~year:"2024" ~files:[];
      test_paper ~title:"2024 Paper B" ~where:"Conf B" ~year:"2024" ~files:[];
      test_paper ~title:"2023 Paper" ~where:"Conf C" ~year:"2023" ~files:[];
      test_paper ~title:"2022 Paper" ~where:"Conf D" ~year:"2022" ~files:[];
    ]
  in

  let layout = Papers.render ~site ~papers in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  (* Papers should be grouped or ordered by year *)
  check bool "contains 2024" true (Astring.String.is_infix ~affix:"2024" html);
  check bool "contains 2023" true (Astring.String.is_infix ~affix:"2023" html);
  check bool "contains 2022" true (Astring.String.is_infix ~affix:"2022" html)

let suite =
  [
    ( "papers",
      [
        test_case "render papers list" `Quick test_render_papers_list;
        test_case "render empty papers" `Quick test_render_empty_papers;
        test_case "render papers by year" `Quick test_render_papers_by_year;
      ] );
  ]
