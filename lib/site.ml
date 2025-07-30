(** Site configuration module *)

type link = [%import: Core.Site.link] [@@deriving show, yaml]
type footer = [%import: Core.Site.footer] [@@deriving show, yaml]
type social = [%import: Core.Site.social] [@@deriving show, yaml]
type analytics = [%import: Core.Site.analytics] [@@deriving show, yaml]
type t = [%import: Core.Site.t] [@@deriving show, yaml]

(* Error helper functions for consistent error handling *)
let err_parse_error file msg =
  let error_msg = "Parse error in " ^ file ^ ": " ^ msg in
  Error error_msg

let err_yaml_error file msg =
  let error_msg = "YAML error in " ^ file ^ ": " ^ msg in
  Error error_msg

let err_loading_error file exn =
  let error_msg = "Error loading " ^ file ^ ": " ^ Printexc.to_string exn in
  Error error_msg

let of_file ~dir =
  let file = Filename.concat dir "site.yml" in
  try
    let content =
      match Bos.OS.File.read (Fpath.v file) with
      | Ok c -> c
      | Error _ -> failwith ("Could not read " ^ file)
    in
    match Yaml.of_string content with
    | Ok yaml -> (
        match of_yaml yaml with
        | Ok site -> Ok site
        | Error (`Msg msg) -> err_parse_error file msg)
    | Error (`Msg msg) -> err_yaml_error file msg
  with exn -> err_loading_error file exn

let pp = Fmt.of_to_string Core.Site.pp
