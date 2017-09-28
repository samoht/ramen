let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

(*
open Soup

let replace ?(all=false) ~k ~v soup =
  let found = ref 0 in
  with_stop (fun stop ->
      soup
      |> descendants
      |> filter no_children
      |> iter (fun elt ->
          if trimmed_texts elt = [k] then (
            incr found;
            replace elt v;
            if not all then (
              Log.debug (fun l -> l "%s: found" k);
              stop.throw ()
            )
          ));
      match !found with
      | 0 -> Log.debug (fun l -> l "%s: not found" k)
      | 1 -> Log.debug (fun l -> l "%s: found" k)
      | n -> Log.debug (fun l -> l "%s: %d occurences found" k n)
    )

*)

open Astring

type rule = { k: string; v: string }
let rule ~k ~v = { k; v }
let k r = r.k
let v r = r.v

let replace ?(all=false) { k; v } soup =
  let re = Re.(compile @@ str k) in
  Re.replace_string ~all re ~by:v soup

let eval rules soup =
  let max = 100 in
  let rec aux acc = function
    | 0 -> soup
    | n ->
      Log.debug (fun l -> l "replaces: new iteration (%d/%d)" (max - n + 1) max);
      let nacc = List.fold_left (fun acc rule ->
          replace ~all:true rule acc
        ) acc rules
      in
      if nacc = acc then (* fix point *) nacc else aux nacc (n-1)
  in
  aux soup max

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
