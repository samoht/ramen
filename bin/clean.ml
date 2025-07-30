open Bos

(* Error helpers *)
let err_remove_failed dir msg =
  Error (`Msg (Fmt.str "Failed to remove %s: %s" dir msg))

let err_check_failed dir msg =
  Error (`Msg (Fmt.str "Error checking directory %s: %s" dir msg))

let remove_directory dir =
  let dir_path = Fpath.v dir in
  match OS.Dir.exists dir_path with
  | Ok true -> (
      Common.Log.file_op ~action:"Removing" ~path:dir;
      match OS.Dir.delete ~recurse:true dir_path with
      | Ok () -> Ok ()
      | Error (`Msg e) -> err_remove_failed dir e)
  | Ok false ->
      Common.Log.warning "Directory %s does not exist, skipping." dir;
      Ok ()
  | Error (`Msg e) -> err_check_failed dir e

let clean_artifacts config =
  Common.Log.info "Cleaning build artifacts...";

  let dirs_to_clean =
    [ config.Common.output_dir; ".ramen-cache" (* Future cache directory *) ]
  in

  List.fold_left
    (fun acc dir ->
      match acc with Error _ as e -> e | Ok () -> remove_directory dir)
    (Ok ()) dirs_to_clean

let run () common =
  match clean_artifacts common with
  | Ok () ->
      Common.Log.success "Build artifacts cleaned successfully!";
      `Ok ()
  | Error (`Msg e) ->
      Common.Log.error "Cleaning artifacts: %s" e;
      `Error (false, e)

open Cmdliner

let cmd =
  let doc = "Remove build artifacts and clean the project" in
  let man =
    [
      `S "DESCRIPTION";
      `P
        "The $(b,clean) command removes build artifacts including the output \
         directory and any cached files generated during the build process.";
      `P
        "This is useful for ensuring a clean slate before rebuilding or when \
         preparing to share the project.";
      `S "FILES REMOVED";
      `P "• Output directory (default: ./_site)";
      `P "• Cache directory (.ramen-cache)";
    ]
  in
  let info = Cmd.info "clean" ~doc ~man in
  Cmd.v info Term.(ret (const run $ Common.logs_term $ Common.term))
