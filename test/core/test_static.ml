(** Tests for the Static module *)

open Alcotest

let test_type () =
  (* Test basic Static.t record type functionality *)
  let static_page =
    {
      Core.Static.title = "About";
      description = Some "About this site";
      layout = "default";
      name = "about";
      body_html = "<p>This is the about page</p>";
      in_nav = true;
      nav_order = Some 1;
    }
  in
  check string "title" "About" static_page.title;
  check (option string) "description" (Some "About this site")
    static_page.description;
  check string "layout" "default" static_page.layout;
  check string "name" "about" static_page.name;
  check bool "in_nav" true static_page.in_nav;
  check (option int) "nav_order" (Some 1) static_page.nav_order

let test_pp () =
  (* Test pretty printing *)
  let static_page =
    {
      Core.Static.title = "Contact";
      description = None;
      layout = "minimal";
      name = "contact";
      body_html = "<p>Contact us</p>";
      in_nav = false;
      nav_order = None;
    }
  in
  let output = Core.Static.pp static_page in
  check bool "pp output contains title" true
    (Astring.String.is_infix ~affix:"Contact" output)

let suite =
  [
    ( "static",
      [
        test_case "static type" `Quick test_type;
        test_case "static pp" `Quick test_pp;
      ] );
  ]
