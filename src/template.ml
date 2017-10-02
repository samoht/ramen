let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

open Astring

type rule = { k: string; v: string }
let rule ~k ~v = { k; v }
let k r = r.k
let v r = r.v

type error = { file: string; key: string } (* not found *)
let err_not_found ~file key = { file; key }

let pp_error ppf { file; key } =
  Fmt.pf ppf "cannot find %a in %a."
    Fmt.(styled `Underline string) key
    Fmt.(styled `Bold string) file

let context contents =
  let re = Re.(compile @@ alt [
      non_greedy @@ seq [str "{{ "; rep any; str " }}"];
      non_greedy @@ seq [str "{% "; rep any; str " %}"];
    ]) in
  Re.matches re contents

let replace ~file ?(all=false) { k; v } contents =
  Log.debug (fun l -> l "replacing %s by %S in %s" k v file);
  let n = ref 0 in
  let re = Re.(compile @@ str k) in
  let f _ = incr n; v in
  let s = Re.replace ~all re ~f contents in
  if !n = 0 then Error (err_not_found ~file k) else Ok s

let add_error e errors =
  if List.mem e errors then errors else List.sort compare (e :: errors)

let eval ~file rules soup =
  let max = 100 in
  let rec aux acc = function
    | 0 -> acc
    | n ->
      let context = context (fst acc) in
      Log.info (fun l -> l "%s: context is %a" file Fmt.(list string) context);
      let nacc = List.fold_left (fun (acc, errors) key ->
          match List.find (fun r -> r.k = key) rules with
          | exception Not_found -> acc, add_error (err_not_found ~file key) errors
          | { k; v} -> match replace ~file ~all:true (rule ~k ~v) acc with
            | Ok acc  -> acc, errors
            | Error e -> acc, add_error e errors
        ) acc context
      in
      if nacc = acc then (* fix point *) nacc else aux nacc (n-1)
  in
  aux (soup, []) max

let (/) = Filename.concat

let read_dir dir =
  let files =
    Sys.readdir dir
    |> Array.to_list
    |> List.filter (fun x -> not (Sys.is_directory (dir / x)))
  in
  List.map (fun f ->
      let ic = open_in (dir / f) in
      let s = really_input_string ic (in_channel_length ic) in
      close_in ic;
      f, s
    ) files

let read_data dir =
  read_dir dir
  |> List.map (fun (f, v) ->
      let v = match Filename.extension f with
        | ".md" -> Omd.(to_html @@ of_string v)
        | _     -> v
      in
      rule ~k:(Fmt.strf "{%% include %s %%}" f) ~v
    )

let parse_headers str =
  let lines = String.cuts ~sep:"\n" str in
  let kv line = match String.cut ~sep:":" line with
    | None        -> None
    | Some (k, v) ->
      let k = Fmt.strf "{{ %s }}" (String.trim k) in
      let v = String.trim v in
      Some (rule ~k ~v)
  in
  List.fold_left (fun acc line ->
      match kv line with None -> acc | Some x -> x :: acc
    ) [] lines

let parse_page str =
  match String.cut ~sep:"---\n" str with
  | None         -> [], str
  | Some (h, t)  ->
    let h, t =
      if h <> "" then h, t
      else match String.cut ~sep:"---\n" t with
        | None        -> "", t
        | Some (h, t) -> h , t
    in
    parse_headers h, t

let read_pages dir =
  read_dir dir
  |> List.map (fun (f, x) -> let y, z = parse_page x in f, y, z)
