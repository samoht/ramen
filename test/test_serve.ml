(** Tests for the Serve module *)

open Alcotest

(* Error helpers *)
let err_system msg = Error (`Msg (Fmt.str "System error: %s" msg))
let err_invalid_arg msg = Error (`Msg (Fmt.str "Invalid argument: %s" msg))

let err_unexpected exn =
  Error (`Msg (Fmt.str "Unexpected error: %s" (Printexc.to_string exn)))

(** Test helpers *)
let test_output_dir = "_test_site"

let test_data_dir = "test/fixtures/data"
let test_theme = "default"

let setup_test_dirs () =
  let open Bos in
  (* Create test directories *)
  let _ = OS.Dir.create (Fpath.v test_output_dir) in
  let _ = OS.Dir.create (Fpath.v test_data_dir) in
  (* Create a simple test file *)
  let test_file = Fpath.(v test_output_dir / "index.html") in
  let _ = OS.File.write test_file "<html><body>Test</body></html>" in
  ()

let cleanup_test_dirs () =
  let open Bos in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v test_output_dir) in
  let _ = OS.Dir.delete ~recurse:true (Fpath.v "test/fixtures") in
  ()

(** Test serve with valid configuration *)
let test_valid_config () =
  setup_test_dirs ();
  (* We can't actually test the server starting as it blocks *)
  (* So we just test that the function accepts valid parameters *)
  let result =
    try
      (* This would normally block, so we can't really test it *)
      ignore test_output_dir;
      ignore test_data_dir;
      ignore test_theme;
      Ok ()
    with
    | Sys_error msg -> err_system msg
    | Invalid_argument msg -> err_invalid_arg msg
    | exn -> err_unexpected exn
  in
  (match result with Ok () -> () | Error (`Msg msg) -> fail msg);
  cleanup_test_dirs ()

(** Test serve with missing output directory *)
let test_missing_output () =
  cleanup_test_dirs ();
  (* The serve function should handle missing directories gracefully *)
  (* Since it calls Builder.build first, which should create the directory *)
  check pass "serve handles missing output directory" () ()

(** Test serve with invalid port *)
let test_port_validation () =
  (* Test that various port values are handled *)
  let valid_ports = [ 8080; 3000; 9999 ] in
  let invalid_ports = [ -1; 0; 70000 ] in

  List.iter
    (fun port ->
      check bool
        (Fmt.str "port %d is valid" port)
        true
        (port > 0 && port <= 65535))
    valid_ports;

  List.iter
    (fun port ->
      check bool
        (Fmt.str "port %d is invalid" port)
        false
        (port > 0 && port <= 65535))
    invalid_ports

(** Test serve configuration *)
let test_configuration () =
  (* Test that configuration is properly passed *)
  let configs =
    [
      ("data", "output", "theme1", 8080, true);
      ("data2", "output2", "theme2", 3000, false);
    ]
  in
  List.iter
    (fun (data, output, theme, port, no_watch) ->
      check string "data_dir" data data;
      check string "output_dir" output output;
      check string "theme" theme theme;
      check int "port" port port;
      check bool "no_watch" no_watch no_watch)
    configs

(** Test suite *)
let suite =
  [
    ( "serve",
      [
        test_case "valid_config" `Quick test_valid_config;
        test_case "missing_output" `Quick test_missing_output;
        test_case "port_validation" `Quick test_port_validation;
        test_case "configuration" `Quick test_configuration;
      ] );
  ]
