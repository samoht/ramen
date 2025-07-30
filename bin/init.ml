open Cmdliner

let run project_name =
  match Ramen.Init.create_project ~project_name with
  | Ok _project_path ->
      Common.Log.success "Created new Ramen project in %s/" project_name;
      Common.Log.info "Next steps:";
      Common.Log.step "cd %s" project_name;
      Common.Log.step "ramen serve";
      `Ok ()
  | Error (`Msg e) ->
      Common.Log.error "Creating project: %s" e;
      `Error (false, e)

(** Command-line term for project name *)
let project_name =
  let doc = "Name of the new project" in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"PROJECT_NAME" ~doc)

let cmd =
  let doc = "Create a new Ramen project from a template" in
  let info = Cmd.info "init" ~doc in
  Cmd.v info Term.(ret (const run $ project_name))
