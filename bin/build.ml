open Cmdliner

let generate_site config minify =
  Logs.info (fun m ->
      m "Building site from %s to %s..." config.Common.data_dir
        config.output_dir);
  Logs.info (fun m ->
      m "Minification: %s" (if minify then "enabled" else "disabled"));

  (* Use the data-driven site builder *)
  Ramen.Build.run ~data_dir:config.data_dir ~output_dir:config.output_dir
    ~theme:config.theme ~minify ()

let run () common minify =
  match generate_site common minify with
  | Ok () ->
      Logs.app (fun m ->
          m "%a Site generated successfully!"
            Fmt.(styled (`Fg `Green) string)
            "[SUCCESS]");
      Logs.info (fun m -> m "Output directory: %s" common.Common.output_dir);
      `Ok ()
  | Error (`Msg e) ->
      Logs.err (fun m ->
          m "%a Building site: %s" Fmt.(styled (`Fg `Red) string) "[ERROR]" e);
      `Error (false, e)

(** Command-line term for minify option *)
let minify =
  let doc = "Minify generated assets like CSS and JS" in
  Arg.(value & flag & info [ "minify" ] ~doc)

let cmd =
  let doc = "Build the static site from the source directory" in
  let info = Cmd.info "build" ~doc in
  Cmd.v info Term.(ret (const run $ Common.logs_term $ Common.term $ minify))
