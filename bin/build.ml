open Cmdliner

let generate_site config minify =
  Common.Log.info "Building site from %s to %s..." config.Common.data_dir
    config.output_dir;
  Common.Log.info "Minification: %s" (if minify then "enabled" else "disabled");

  (* Use the data-driven site builder *)
  Ramen.Build.run ~data_dir:config.data_dir ~output_dir:config.output_dir
    ~theme:config.theme

let run common minify =
  match generate_site common minify with
  | Ok () ->
      Common.Log.success "Site generated successfully!";
      Common.Log.info "Output directory: %s" common.Common.output_dir;
      `Ok ()
  | Error (`Msg e) ->
      Common.Log.error "Building site: %s" e;
      `Error (false, e)

(** Command-line term for minify option *)
let minify =
  let doc = "Minify generated assets like CSS and JS" in
  Arg.(value & flag & info [ "minify" ] ~doc)

let cmd =
  let doc = "Build the static site from the source directory" in
  let info = Cmd.info "build" ~doc in
  Cmd.v info Term.(ret (const run $ Common.term $ minify))
