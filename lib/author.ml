(** Authors module *)

type t = [%import: Core.Author.t] [@@deriving show, yaml]

let load ~dir =
  let file = Filename.concat dir "team/team.yml" in
  try
    if not (Sys.file_exists file) then Ok []
    else
      let content =
        match Bos.OS.File.read (Fpath.v file) with
        | Ok c -> c
        | Error _ -> failwith "read error"
      in
      match Yaml.of_string content with
      | Ok yaml -> (
          match yaml with
          | `O assoc ->
              let members =
                List.filter_map
                  (fun (name, member_yaml) ->
                    match of_yaml member_yaml with
                    | Ok member -> Some { member with name }
                    | Error _ -> None)
                  assoc
              in
              Ok members
          | `A members ->
              List.filter_map
                (fun member_yaml ->
                  match of_yaml member_yaml with
                  | Ok member -> Some member
                  | Error _ -> None)
                members
              |> fun x -> Ok x
          | _ -> Ok [])
      | Error _ -> Ok []
  with
  | Sys_error _ -> Ok [] (* File system errors *)
  | Failure _ -> Ok [] (* Parsing errors *)
  | e -> raise e (* Re-raise unexpected exceptions *)
