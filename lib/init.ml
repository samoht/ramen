(** Project initialization logic *)

open Bos

(* Error helpers *)
let err_directory_exists name =
  Error (`Msg (Fmt.str "Directory '%s' already exists" name))

let create_project ~project_name =
  let ( >>= ) = Result.bind in

  (* Validate project name *)
  if
    project_name = "" || project_name = "." || project_name = ".."
    || String.contains project_name '/'
  then Error (`Msg "Invalid project name")
  else
    let project_path = Fpath.v project_name in

    (* Check if project directory already exists *)
    OS.Dir.exists project_path >>= fun exists ->
    if exists then err_directory_exists project_name
    else
      (* Create project directory *)
      OS.Dir.create project_path >>= fun _ ->
      (* Copy example data directory *)
      let example_data = Fpath.(v "example" / "data") in
      let target_data = Fpath.(project_path / "data") in
      OS.Dir.create target_data >>= fun _ ->
      OS.Cmd.run
        Cmd.(v "cp" % "-r" % p example_data % p (Fpath.parent target_data))
      >>= fun () ->
      (* Initialize git repository *)
      OS.Dir.set_current project_path >>= fun () ->
      OS.Cmd.run Cmd.(v "git" % "init") >>= fun () ->
      OS.Dir.set_current (Fpath.v "..") >>= fun () -> Ok project_path
