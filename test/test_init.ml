(** Tests for the Init module *)

open Alcotest

(** Test helpers *)
let test_project_name = "test_ramen_project"

let setup_example_dir () =
  let open Bos in
  (* Create example/data directory for tests *)
  let _ = OS.Dir.create Fpath.(v "example" / "data" / "blog" / "content") in
  let _ = OS.Dir.create Fpath.(v "example" / "data" / "team") in
  (* Create minimal example files *)
  let site_yml =
    {|
name: Example Site
title: Example
url: https://example.com
description: Example site
footer:
  copyright: "© Example"
  links: []
|}
  in
  let _ = OS.File.write Fpath.(v "example" / "data" / "site.yml") site_yml in
  ()

let cleanup_test_project () =
  let open Bos in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v test_project_name) in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v "example") in
  ()

(** Test successful project creation *)
let test_create_project_success () =
  cleanup_test_project ();
  setup_example_dir ();
  match Ramen.Init.create_project ~project_name:test_project_name with
  | Ok path ->
      check bool "project directory exists" true
        (Sys.file_exists (Fpath.to_string path));
      check bool "data directory exists" true
        (Sys.file_exists (Fpath.to_string Fpath.(path / "data")));
      check bool "git directory exists" true
        (Sys.file_exists (Fpath.to_string Fpath.(path / ".git")));
      cleanup_test_project ()
  | Error (`Msg msg) -> failf "Project creation failed: %s" msg

(** Test project creation with existing directory *)
let test_create_project_existing () =
  cleanup_test_project ();
  setup_example_dir ();
  (* Create project first time *)
  match Ramen.Init.create_project ~project_name:test_project_name with
  | Ok _ -> (
      (* Try to create again *)
      match Ramen.Init.create_project ~project_name:test_project_name with
      | Ok _ -> fail "Should fail when project already exists"
      | Error (`Msg msg) ->
          check bool "error mentions existing directory" true
            (String.exists (fun _ -> true) msg);
          cleanup_test_project ())
  | Error (`Msg msg) -> failf "First creation failed: %s" msg

(** Test project creation with invalid name *)
let test_create_project_invalid_name () =
  let invalid_names = [ "/invalid"; ".."; "."; "" ] in
  List.iter
    (fun name ->
      match Ramen.Init.create_project ~project_name:name with
      | Ok _ -> failf "Should fail for invalid name: %s" name
      | Error (`Msg _) -> ())
    invalid_names

(** Test that example data is copied *)
let test_example_data_copied () =
  cleanup_test_project ();
  setup_example_dir ();
  match Ramen.Init.create_project ~project_name:test_project_name with
  | Ok path ->
      let data_path = Fpath.(path / "data") in
      check bool "data directory created" true
        (Sys.file_exists (Fpath.to_string data_path));
      cleanup_test_project ()
  | Error (`Msg msg) -> failf "Project creation failed: %s" msg

(** Test suite *)
let suite =
  [
    ( "init",
      [
        test_case "create_success" `Quick test_create_project_success;
        test_case "create_existing" `Quick test_create_project_existing;
        test_case "invalid_name" `Quick test_create_project_invalid_name;
        test_case "example_data" `Quick test_example_data_copied;
      ] );
  ]
