(** File assets module *)

type path = [%import: Core.File.path] [@@deriving show]
type target = [%import: Core.File.target] [@@deriving show]
type t = [%import: Core.File.t] [@@deriving show]
type url = [%import: Core.File.url] [@@deriving show]

let load ~dir =
  (* Scan for files in images and css directories *)
  let images_dir = Filename.concat dir "images" in
  let css_dir = Filename.concat dir "css" in
  let files = ref [] in

  (* Helper to add files from a directory *)
  let add_files_from_dir dir prefix =
    try
      if Sys.file_exists dir && Sys.is_directory dir then
        let entries = Sys.readdir dir |> Array.to_list in
        List.iter
          (fun entry ->
            let full_path = Filename.concat dir entry in
            if not (Sys.is_directory full_path) then
              let origin = Filename.concat prefix entry in
              let url = "/" ^ origin in
              files := { Core.File.origin; target = File { url } } :: !files)
          entries
    with
    | Sys_error _ -> () (* File system errors - ignore *)
    | e -> raise e (* Re-raise unexpected exceptions *)
  in

  add_files_from_dir images_dir "images";
  add_files_from_dir css_dir "css";

  Ok !files

let pp = Fmt.of_to_string Core.File.pp
