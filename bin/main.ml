open Cmdliner

let version = "0.1.0"

let cmd =
  let doc = "A type-safe static site generator" in
  let info =
    Cmd.info "ramen" ~version ~doc
      ~man:
        [
          `S "DESCRIPTION";
          `P
            "Ramen is a static site generator that leverages OCaml's type \
             system to catch content errors at compile time.";
          `S "COMMANDS";
          `P "$(b,init)     Create a new Ramen project from a template.";
          `P "$(b,build)    Build the static site from the source directory.";
          `P "$(b,clean)    Remove build artifacts and clean the project.";
          `P "$(b,serve)    Serve the site locally with live-reloading.";
          `P "$(b,crunch)   Generate static OCaml module with pre-loaded data.";
          `S "GLOBAL OPTIONS";
          `P
            "$(b,--data-dir) <PATH>    Path to the content directory (default: \
             ./data).";
          `P
            "$(b,--output-dir) <PATH>  Path to the output directory (default: \
             ./_site).";
          `P
            "$(b,--theme) <NAME>       Name of the theme to use (default: \
             default).";
        ]
  in
  Cmd.group info [ Init.cmd; Build.cmd; Clean.cmd; Serve.cmd; Crunch.cmd ]

let () = exit (Cmd.eval cmd)
