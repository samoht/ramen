(** Static page loading functionality *)

open Bos

(* Error helpers *)
let err_yaml_parse msg = Error (Fmt.str "YAML parse error: %s" msg)

type t = [%import: Core.Static.t] [@@deriving show]

(** Parse a static page from markdown content *)
let of_string ~path content =
  match Frontmatter.parse content with
  | Error Frontmatter.Unclosed_delimiter ->
      Error "Unclosed frontmatter delimiter"
  | Error (Frontmatter.Yaml_parse_error e) -> err_yaml_parse e
  | Ok fm ->
      let yaml, body =
        match fm with
        | Some f -> (f.Frontmatter.yaml, f.body)
        | None -> (`Null, content)
      in

      (* Extract metadata *)
      let title =
        match Frontmatter.string "title" yaml with
        | Some t -> t
        | None -> Filename.basename path |> Filename.remove_extension
      in

      let description = Frontmatter.string "description" yaml in
      let nav_order = Frontmatter.int "nav_order" yaml in
      let in_nav =
        Option.value ~default:true (Frontmatter.bool "in_nav" yaml)
      in

      (* Render body HTML *)
      let body_doc = Cmarkit.Doc.of_string body in
      let body_html = Cmarkit_html.of_doc ~safe:false body_doc in

      let name =
        path |> Filename.basename |> Filename.remove_extension
        |> String.lowercase_ascii
      in

      Ok
        {
          Core.Static.title;
          description;
          layout = "default";
          name;
          body_html;
          in_nav;
          nav_order;
        }

(** Load static pages from the pages directory *)
let load ~dir =
  let pages_dir = Fpath.(v dir / "pages") in
  match OS.Dir.exists pages_dir with
  | Ok false -> Ok []
  | Ok true -> (
      match OS.Dir.contents pages_dir with
      | Error (`Msg e) -> Error (`Load e)
      | Ok paths ->
          let md_files =
            List.filter
              (fun p -> Fpath.has_ext ".md" p || Fpath.has_ext ".markdown" p)
              paths
          in
          let load_page path =
            match OS.File.read path with
            | Error (`Msg e) ->
                Error (`Load (Fmt.str "Failed to read %a: %s" Fpath.pp path e))
            | Ok content -> (
                match of_string ~path:(Fpath.to_string path) content with
                | Error e -> Error (`Load e)
                | Ok page -> Ok page)
          in
          let rec load_all acc = function
            | [] -> Ok (List.rev acc)
            | path :: rest -> (
                match load_page path with
                | Error e -> Error e
                | Ok page -> load_all (page :: acc) rest)
          in
          load_all [] md_files)
  | Error (`Msg e) -> Error (`Load e)
