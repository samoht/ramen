(** Development server logic *)

open Bos

let start_server ~output_dir ~port ~no_watch ~data_dir:_ =
  (* Use Python's built-in server for now *)
  let ( >>= ) = Result.bind in
  OS.Dir.set_current (Fpath.v output_dir) >>= fun () ->
  let server_cmd =
    Cmd.(v "python3" % "-m" % "http.server" % string_of_int port)
  in

  if no_watch then OS.Cmd.run server_cmd
  else
    (* TODO: Implement file watching and live reload *)
    OS.Cmd.run server_cmd

let run ~data_dir ~output_dir ~theme ~port ~no_watch =
  (* First build the site *)
  match Build.run ~data_dir ~output_dir ~theme with
  | Error e -> Error e
  | Ok () -> start_server ~output_dir ~port ~no_watch ~data_dir
