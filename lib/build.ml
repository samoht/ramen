(** Build command implementation *)

open Bos

(* Error helpers *)
let err_load_failed msg =
  Error (`Msg (Fmt.str "Failed to load site data: %s" msg))

let err_validation_failed e =
  Error (`Msg (Fmt.str "Validation error: %a" Validation.pp_error e))

(** Build the site by loading data structures in memory *)
let run ~data_dir ~output_dir ~theme:_ =
  let ( >>= ) = Result.bind in

  (* Load and validate all data using the core library *)
  Fmt.pr "Loading site data from %s...\n%!" data_dir;
  match Data.load_site ~data_dir with
  | Error (`Load msg) -> err_load_failed msg
  | Error (`Validation e) -> err_validation_failed e
  | Ok data -> (
      (* Create output directory *)
      Fmt.pr "Loaded %d blog posts\n%!" (List.length data.blog_posts);
      let output = Fpath.v output_dir in
      OS.Dir.create output >>= fun _ ->
      (* Use the engine directly with the loaded data *)
      try
        Engine.generate ~data_dir ~output_dir ~data;
        Ok ()
      with
      | Failure msg -> Error (`Msg msg)
      | exn -> Error (`Msg (Printexc.to_string exn)))
