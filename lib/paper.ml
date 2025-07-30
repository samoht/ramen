(** Papers module *)

type file = [%import: Core.Paper.file] [@@deriving show]
type author = [%import: Core.Paper.author] [@@deriving show]
type t = [%import: Core.Paper.t] [@@deriving show]

let load ~dir =
  let file = Filename.concat dir "papers.json" in
  try
    if not (Sys.file_exists file) then Ok []
    else
      let content =
        match Bos.OS.File.read (Fpath.v file) with
        | Ok c -> c
        | Error _ -> failwith "read error"
      in
      match Yojson.Safe.from_string content with
      | `List papers ->
          let parsed =
            List.filter_map
              (fun json ->
                try
                  let open Yojson.Safe.Util in
                  let title = json |> member "title" |> to_string in
                  let authors =
                    json |> member "authors" |> to_list
                    |> List.map (fun a ->
                           ({
                              name = a |> member "name" |> to_string;
                              url = a |> member "url" |> to_string_option;
                            }
                             : Core.Paper.author))
                  in
                  let where = json |> member "where" |> to_string in
                  let year = json |> member "year" |> to_string in
                  let abstract =
                    json |> member "abstract" |> to_string_option
                  in
                  let files =
                    json |> member "files" |> to_list
                    |> List.map (fun f ->
                           ({
                              name = f |> member "name" |> to_string;
                              url = f |> member "url" |> to_string;
                            }
                             : Core.Paper.file))
                  in
                  Some
                    { Core.Paper.title; authors; where; year; abstract; files }
                with
                | Yojson.Safe.Util.Type_error _ ->
                    None (* JSON parsing errors *)
                | _ -> None)
              papers
          in
          Ok parsed
      | _ -> Ok []
  with
  | Sys_error _ -> Ok [] (* File system errors *)
  | Yojson.Json_error _ -> Ok [] (* JSON parsing errors *)
  | Failure _ -> Ok [] (* Other parsing errors *)
  | e -> raise e (* Re-raise unexpected exceptions *)

let pp = Fmt.of_to_string Core.Paper.pp
