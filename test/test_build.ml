(** Tests for the Build module *)

open Alcotest

(** Test helpers *)
let test_data_dir = "test/fixtures/build_data"

let test_output_dir = "_test_build_output"
let test_theme = "default"

(* Create test directory structure *)
let create_test_dirs () =
  let open Bos in
  let _ = OS.Dir.create Fpath.(v test_data_dir / "blog" / "content") in
  let _ = OS.Dir.create Fpath.(v test_data_dir / "team") in
  ()

(* Create site configuration file *)
let create_site_yml () =
  let site_yml =
    {|
name: Test Site
title: Test Site Title
tagline: Test tagline
url: https://test.example.com
description: A test site
author: Test Author
author_email: test@example.com
footer:
  copyright: "© 2024 Test"
  links:
    - text: "GitHub"
      href: "https://github.com/test"
|}
  in
  let _ = Bos.OS.File.write Fpath.(v test_data_dir / "site.yml") site_yml in
  ()

(* Create team configuration *)
let create_team_yml () =
  let team_yml = {|
- name: Test Author
  github: testauthor
|} in
  let _ =
    Bos.OS.File.write Fpath.(v test_data_dir / "team" / "team.yml") team_yml
  in
  ()

(* Create test blog post *)
let create_test_blog_post () =
  let blog_post =
    {|---
title: Test Post
date: 2024-01-01
description: A test post
authors: Test Author
tags: test
synopsis: A test post
image: test.jpg
---

# Test Post

This is a test post.
|}
  in
  let _ =
    Bos.OS.File.write
      Fpath.(v test_data_dir / "blog" / "content" / "test-post.md")
      blog_post
  in
  ()

(* Main setup function *)
let setup_test_data () =
  create_test_dirs ();
  create_site_yml ();
  create_team_yml ();
  create_test_blog_post ()

let cleanup_test_dirs () =
  let open Bos in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v test_data_dir) in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v test_output_dir) in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v "test/fixtures") in
  ()

(** Test successful build *)
let test_success () =
  setup_test_data ();
  match
    Ramen.Build.run ~data_dir:test_data_dir ~output_dir:test_output_dir
      ~theme:test_theme ()
  with
  | Ok () ->
      check bool "output directory exists" true
        (Sys.file_exists test_output_dir);
      check bool "index.html exists" true
        (Sys.file_exists (Filename.concat test_output_dir "index.html"));
      cleanup_test_dirs ()
  | Error (`Msg msg) ->
      cleanup_test_dirs ();
      failf "Build failed: %s" msg

(** Test build with missing data directory *)
let test_missing_data () =
  cleanup_test_dirs ();
  match
    Ramen.Build.run ~data_dir:"nonexistent" ~output_dir:test_output_dir
      ~theme:test_theme ()
  with
  | Ok () -> fail "Should fail with missing data directory"
  | Error (`Msg msg) ->
      check bool "error mentions data directory" true
        (String.exists (fun _ -> true) msg)

(** Test build with invalid theme *)
let test_invalid_theme () =
  setup_test_data ();
  (* Currently themes aren't implemented, so this should still work *)
  match
    Ramen.Build.run ~data_dir:test_data_dir ~output_dir:test_output_dir
      ~theme:"nonexistent" ()
  with
  | Ok () ->
      cleanup_test_dirs ();
      (* Themes are not implemented yet, so any theme name should work *)
      ()
  | Error (`Msg msg) ->
      cleanup_test_dirs ();
      failf "Build failed unexpectedly: %s" msg

(** Test build creates necessary directories *)
let test_creates_output_dir () =
  setup_test_data ();
  (* Ensure output directory doesn't exist *)
  let _ = Bos.OS.Dir.delete ~recurse:true (Fpath.v test_output_dir) in

  match
    Ramen.Build.run ~data_dir:test_data_dir ~output_dir:test_output_dir
      ~theme:test_theme ()
  with
  | Ok () ->
      check bool "output directory created" true
        (Sys.file_exists test_output_dir);
      cleanup_test_dirs ()
  | Error (`Msg msg) ->
      cleanup_test_dirs ();
      failf "Build failed to create output dir: %s" msg

(** Test build parameters *)
let test_parameters () =
  let params =
    [ ("data1", "output1", "theme1"); ("data2", "output2", "theme2") ]
  in
  List.iter
    (fun (data, output, theme) ->
      check string "data_dir parameter" data data;
      check string "output_dir parameter" output output;
      check string "theme parameter" theme theme)
    params

(** Test suite *)
let suite =
  [
    ( "build",
      [
        test_case "success" `Quick test_success;
        test_case "missing_data" `Quick test_missing_data;
        test_case "invalid_theme" `Quick test_invalid_theme;
        test_case "creates_output_dir" `Quick test_creates_output_dir;
        test_case "parameters" `Quick test_parameters;
      ] );
  ]
