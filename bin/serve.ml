open Cmdliner

let start_server common port no_watch =
  Common.Log.info "Starting development server on http://localhost:%d" port;
  Common.Log.info "Serving files from: %s" common.Common.output_dir;
  if not no_watch then
    Common.Log.info "Watching for changes in: %s" common.data_dir;

  if not no_watch then (
    Common.Log.warning "File watching and live reload not yet implemented.";
    Common.Log.info "Use Ctrl+C to stop the server.");

  Ramen.Serve.run ~data_dir:common.Common.data_dir ~output_dir:common.output_dir
    ~theme:common.theme ~port ~no_watch

let run common port no_watch =
  match start_server common port no_watch with
  | Ok () -> `Ok ()
  | Error (`Msg e) ->
      Common.Log.error "Starting server: %s" e;
      `Error (false, e)

(** Command-line term for port *)
let port =
  let doc = "The port for the local web server" in
  Arg.(value & opt int 8080 & info [ "port" ] ~docv:"PORT" ~doc)

(** Command-line term for no-watch flag *)
let no_watch =
  let doc = "Disable file watching and live-reloading" in
  Arg.(value & flag & info [ "no-watch" ] ~doc)

let cmd =
  let doc = "Serve the site locally with live-reloading" in
  let info = Cmd.info "serve" ~doc in
  Cmd.v info Term.(ret (const run $ Common.term $ port $ no_watch))
