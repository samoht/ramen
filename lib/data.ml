(** Runtime data storage for the site generator *)

(* Import the Core.t type with deriving show *)
type t = [%import: Core.t] [@@deriving show]

(* Capture top-level modules before they get shadowed *)
let site_of_file = Site.of_file
let blog_load = Blog.load
let author_load = Author.load
let paper_load = Paper.load
let file_load = File.load
let static_load = Static.load

(** Data loading functionality *)

type load_error = [ `Load of string | `Validation of Validation.error ]

(** Load all data files from a directory *)
let load ~data_dir =
  let ( let* ) = Result.bind in
  (* Use the captured functions to avoid shadowing *)
  let* site =
    match site_of_file ~dir:data_dir with
    | Ok v -> Ok v
    | Error e -> Error (`Load e)
  in
  let* blog_posts =
    match blog_load ~dir:data_dir with
    | Ok v -> Ok v
    | Error e -> Error (`Load e)
  in
  let* team =
    match author_load ~dir:data_dir with
    | Ok v -> Ok v
    | Error e -> Error (`Load e)
  in
  let* static_pages = static_load ~dir:data_dir in
  let* papers =
    match paper_load ~dir:data_dir with
    | Ok v -> Ok v
    | Error e -> Error (`Load e)
  in
  let* files =
    match file_load ~dir:data_dir with
    | Ok v -> Ok v
    | Error e -> Error (`Load e)
  in
  Ok { Core.site; blog_posts; authors = team; static_pages; papers; files }

(** Load and validate all site data *)
let load_site ~data_dir =
  match load ~data_dir with
  | Error (`Load msg) -> Error (`Load msg)
  | Ok data -> (
      match Validation.validate_all data with
      | Ok () -> Ok data
      | Error e -> Error (`Validation e))
  | exception exn -> Error (`Load (Printexc.to_string exn))
