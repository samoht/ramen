(** Frontmatter parsing utilities *)

type t = { yaml : Yaml.value; body : string; body_start : int }
type error = Unclosed_delimiter | Yaml_parse_error of string

let pp t =
  Core.Pp.record
    [
      ( "yaml",
        match Yaml.to_string t.yaml with
        | Ok s -> s
        | Error _ -> "<invalid yaml>" );
      ( "body",
        if String.length t.body > 50 then String.sub t.body 0 50 ^ "..."
        else t.body );
      ("body_start", Core.Pp.int t.body_start);
    ]

let parse content =
  match String.split_on_char '\n' content with
  | "---" :: rest ->
      (* Find the closing --- *)
      let rec find_end acc line_num = function
        | [] -> Error Unclosed_delimiter
        | "---" :: rest_lines -> (
            let yaml_content = String.concat "\n" (List.rev acc) in
            (* Handle empty frontmatter *)
            if yaml_content = "" then
              let body = String.concat "\n" rest_lines in
              Ok (Some { yaml = `Null; body; body_start = line_num + 1 })
            else
              match Yaml.of_string yaml_content with
              | Ok yaml ->
                  let body_lines = rest_lines in
                  let body = String.concat "\n" body_lines in
                  Ok (Some { yaml; body; body_start = line_num + 1 })
              | Error (`Msg e) -> Error (Yaml_parse_error e))
        | line :: rest -> find_end (line :: acc) (line_num + 1) rest
      in
      find_end [] 1 rest
  | _ -> Ok None

let find_string key yaml =
  match yaml with
  | `O assoc -> (
      match List.assoc_opt key assoc with
      | Some (`String s) -> Some s
      | _ -> None)
  | _ -> None

let find_int key yaml =
  match yaml with
  | `O assoc -> (
      match List.assoc_opt key assoc with
      | Some (`Float f) -> Some (int_of_float f)
      | _ -> None)
  | _ -> None

let find_float key yaml =
  match yaml with
  | `O assoc -> (
      match List.assoc_opt key assoc with
      | Some (`Float f) -> Some f
      | _ -> None)
  | _ -> None

let find_bool key yaml =
  match yaml with
  | `O assoc -> (
      match List.assoc_opt key assoc with Some (`Bool b) -> Some b | _ -> None)
  | _ -> None

let find_list key yaml =
  match yaml with
  | `O assoc -> (
      match List.assoc_opt key assoc with
      | Some (`A lst) -> Some lst
      | _ -> None)
  | _ -> None

let find_string_list key yaml =
  match find_list key yaml with
  | Some lst ->
      let strings =
        List.filter_map (function `String s -> Some s | _ -> None) lst
      in
      if List.length strings = List.length lst then Some strings else None
  | None -> None
