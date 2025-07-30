(** Blog posts module *)

(* To please ppx_import *)
module Core__ = struct
  module Author = Author
end

type name = [%import: Core.Blog.name] [@@deriving show, yaml]
type author = [%import: Core.Blog.author] [@@deriving show, yaml]
type t = [%import: Core.Blog.t] [@@deriving show, yaml]
type filter = [%import: Core.Blog.filter] [@@deriving show]
type index = [%import: Core.Blog.index] [@@deriving show]

(* Load a single blog post from file *)
let load_post blog_dir file =
  let path = Filename.concat blog_dir file in
  try
    let content =
      match Bos.OS.File.read (Fpath.v path) with
      | Ok c -> c
      | Error _ -> failwith "read error"
    in
    match Frontmatter.parse content with
    | Ok (Some fm) -> (
        match of_yaml fm.Frontmatter.yaml with
        | Ok post -> Some { post with path = file; body_html = fm.body }
        | Error _ -> None)
    | Ok None -> None
    | Error _ -> None
  with
  | Sys_error _ -> None (* File system errors *)
  | Failure _ -> None (* Parsing errors *)
  | _ -> None

let load ~dir =
  let blog_dir = Filename.concat dir "blog/content" in
  try
    if not (Sys.file_exists blog_dir) then Ok []
    else
      let files =
        Sys.readdir blog_dir |> Array.to_list
        |> List.filter (fun f -> Filename.check_suffix f ".md")
      in
      let posts = List.filter_map (load_post blog_dir) files in
      Ok posts
  with
  | Sys_error _ -> Ok [] (* File system errors *)
  | Failure _ -> Ok [] (* Parsing errors *)
  | e -> raise e (* Re-raise unexpected exceptions *)
