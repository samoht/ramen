open Cmdliner

type t = { data_dir : string; output_dir : string; theme : string }
(** Common configuration options for all commands *)

(** Setup logging with colors *)
let setup_log ?style_renderer log_level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level log_level;
  Logs.set_reporter (Logs_fmt.reporter ~dst:Fmt.stderr ~app:Fmt.stdout ())

(** Default values *)
let default_data_dir = "./data"

let default_output_dir = "./_site"
let default_theme = "default"

(** Command-line term for data directory *)
let data_dir =
  let doc = "Path to the content directory" in
  let env = Cmd.Env.info "RAMEN_DATA_DIR" ~doc:"Content directory path" in
  Arg.(
    value
    & opt string default_data_dir
    & info [ "data-dir" ] ~env ~docv:"PATH" ~doc)

(** Command-line term for output directory *)
let output_dir =
  let doc = "Path to the output directory" in
  let env = Cmd.Env.info "RAMEN_OUTPUT_DIR" ~doc:"Output directory path" in
  Arg.(
    value
    & opt string default_output_dir
    & info [ "output-dir" ] ~env ~docv:"PATH" ~doc)

(** Command-line term for theme *)
let theme =
  let doc = "Name of the theme to use" in
  let env = Cmd.Env.info "RAMEN_THEME" ~doc:"Theme name" in
  Arg.(
    value & opt string default_theme & info [ "theme" ] ~env ~docv:"NAME" ~doc)

(** Create configuration from command-line arguments *)
let make data_dir output_dir theme = { data_dir; output_dir; theme }

(** Command-line term for log level *)
let log_level =
  let env = Cmd.Env.info "RAMEN_VERBOSE" in
  Logs_cli.level ~env ()

(** Combined term for common options *)
let term = Term.(const make $ data_dir $ output_dir $ theme)

(** Logging setup term *)
let logs_term =
  let setup style_renderer log_level =
    setup_log ?style_renderer log_level;
    ()
  in
  Term.(const setup $ Fmt_cli.style_renderer () $ log_level)

(** Log module for consistent styled output *)
module Log = struct
  let info fmt =
    Fmt.pr ("%a " ^^ fmt ^^ "@.") Fmt.(styled (`Fg `Cyan) string) "[INFO]"

  let success fmt =
    Fmt.pr ("%a " ^^ fmt ^^ "@.") Fmt.(styled (`Fg `Green) string) "[SUCCESS]"

  let error fmt =
    Fmt.epr ("%a " ^^ fmt ^^ "@.") Fmt.(styled (`Fg `Red) string) "[ERROR]"

  let warning fmt =
    Fmt.epr ("%a " ^^ fmt ^^ "@.") Fmt.(styled (`Fg `Yellow) string) "[WARNING]"

  let step fmt =
    Fmt.pr ("%a " ^^ fmt ^^ "@.") Fmt.(styled (`Fg `Blue) string) "=>"

  let file_op ~action ~path =
    Fmt.pr "%a %a %a@."
      Fmt.(styled (`Fg `Blue) string)
      "=>"
      Fmt.(styled `Bold string)
      action
      Fmt.(styled (`Fg `Green) string)
      path
end
