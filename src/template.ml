let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

open Astring

module Ast = struct

  include Ast

  open Lexing

  let pp_position ppf lexbuf =
    let pos = lexbuf.lex_curr_p in
    Fmt.pf ppf "%s:%d:%d" pos.pos_fname
      pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

  let parse str =
    let lexbuf = Lexing.from_string str in
    try Parser.main Lexer.(token @@ v ()) lexbuf
    with
    | Lexer.Error msg ->
      Log.err (fun l -> l "%a: %s\n" pp_position lexbuf msg);
      failwith "syntax error"
    | Parsing.Parse_error ->
      Log.err (fun l -> l "%a: syntax error\n%!" pp_position lexbuf);
      failwith "parse error"

  (* FIXME: very dumb *)
  let normalize t =
    let t' = parse (Fmt.to_to_string pp t) in
    if t = t' then t else t'

end

let pp_file = Fmt.(styled `Underline string)
let pp_key = Fmt.(styled `Bold string)

(* ENTRIES *)

type value = Data of string | Collection of entries
and entries = value String.Map.t

type entry = { k: string; v: value }

let rec pp_value pp_data ppf = function
  | Data s       -> pp_data ppf s
  | Collection c ->
    Fmt.pf ppf "{%a}" Fmt.(vbox ~indent:2 (pp_entries pp_data)) c

and pp_entry pp_data ppf { k; v } =
  Fmt.pf ppf "@[%a => %a@]@," pp_key k (pp_value pp_data) v

and pp_entries pp_data ppf t =
  Fmt.vbox ~indent:0
    (String.Map.pp ~sep:(Fmt.unit "") (fun ppf (k, v) ->
         pp_entry pp_data ppf { k; v }
       )) ppf t

let data k v = { k; v = Data v }

let rec value_equal x y =
  x == y ||
  match x, y with
  | Data x      , Data y       -> String.equal x y
  | Collection x, Collection y -> entries_equal x y
  | _ -> false

and entries_equal x y = String.Map.equal value_equal x y

(* CONTEXT *)

module Context: sig
  type t
  val pp: t Fmt.t
  val dump: t Fmt.t
  val equal: t -> t -> bool
  val v: entry list -> t
  val (++): t -> t -> t
  val empty: t
  val is_empty: t -> bool
  val add: t -> entry -> t
  val mem: t -> string -> bool
  val find: t -> string -> entry option
  val values: t -> value String.Map.t
end = struct
  type t = entries
  let dump = pp_entries (fun ppf d -> Fmt.pf ppf "%S" d)
  let pp = pp_entries (fun ppf _ -> Fmt.string ppf ".")
  let equal = entries_equal
  let is_empty x = String.Map.is_empty x
  let empty = String.Map.empty
  let (++) = String.Map.union (fun _ x _ -> Some x)
  let add m e = String.Map.add e.k e.v m
  let values x = x

  let find m k =
    let return x m =
      match String.Map.find x m with
      | None   -> None
      | Some v -> Some { k; v }
    in
    let rec aux path m = function
      | []   -> None
      | [k]  -> return k m
      | h::t ->
        match String.Map.find h m with
        | None -> None
        | Some (Data _) ->
          Log.err (fun l ->
              l "%s is not a collection (longest valid prefix is: %a)"
                k Fmt.(list ~sep:(unit ".") string) (List.rev path) );
          None
        | Some (Collection m) -> aux (h :: path) m t
    in
    let path = String.cuts ~sep:"." k in
    aux [] m path

  let mem x k = match find x k with
    | None   -> false
    | Some _ -> true

  let v l =
    List.fold_left (fun acc { k; v } ->
        if String.Map.mem k acc then
          Log.info (fun l ->
              l "Entry %s is duplicated, picking the last one." k);
        String.Map.add k v acc
      ) String.Map.empty l
end

let collection k l = { k; v = Collection Context.(values @@ v l) }
let kollection k c = { k; v = Collection (Context.values c) }

type context = Context.t

(* ERRORS *)

type loc = { file: string; key: string }

type error =
  | Invalid_key of loc
  | Invalid_order of loc
  | Data_is_needed of loc
  | Collection_is_needed of loc

let err_invalid_key ~file key = Invalid_key { file; key }
let err_invalid_order ~file key = Invalid_order { file; key }
let err_data_is_needed ~file key = Data_is_needed { file; key }
let err_collection_is_needed ~file key = Collection_is_needed { file; key }

let pp_error ppf = function
  | Invalid_key { file; key } ->
    Fmt.pf ppf "cannot find the key %a in %a."
      pp_key key pp_file file
  | Invalid_order { file; key } ->
    Fmt.pf ppf "The key %a is not a valid sort order in %a."
      pp_key key pp_file file
  | Data_is_needed { file; key } ->
    Fmt.pf ppf "The key %a in %a should be of type 'data'."
      pp_key key pp_file file
  | Collection_is_needed { file; key } ->
    Fmt.pf ppf "They key %a in %a should be of type 'collection'."
      pp_key key pp_file file

let vars contents =
  let open Ast in
  let vars = ref String.Set.empty in
  let rec aux loops = function
    | Data _ -> ()
    | Var v  ->
      if String.Set.exists (fun k -> String.is_prefix ~affix:k v) loops then ()
      else vars := String.Set.add v !vars
    | If c   -> aux loops c.then_
    | For l  -> aux (String.Set.add l.var loops) l.body
    | Seq s  -> List.iter (aux loops) s
  in
  aux String.Set.empty contents;
  String.Set.elements !vars

let pp_vars = Fmt.(list ~sep:(unit ", ") string)

(* ENGINE *)

let subst ~file { k; v } contents =
  match v with
  | Collection _ -> Error (err_data_is_needed ~file k)
  | Data v       ->
    let open Ast in
    Log.debug (fun l -> l "replacing %a in %a" pp_key k pp_file file);
    let n = ref 0 in
    let rec aux f = function
      | Var var when var = k -> incr n; f (Data v)
      | Data _
      | Var _ as x -> f x
      | Seq s as x -> auxes (fun t -> if s == t then f x else (f (Seq t))) s
      | If c as x  ->
        aux (fun t ->
            if t == c.then_ then f x else f (If { c with then_=t })
          ) c.then_
      | For l as x ->
        aux (fun t ->
            if t == l.body then f x else f (For { l with body=t })
          ) l.body
    and auxes f = function
      | []        -> f []
      | h::t as x ->
        aux (fun h' ->
            auxes (fun t' ->
                if h == h' && t == t' then f x
                else f (h' :: t')
              ) t
          ) h
    in
    let s = aux (fun x -> x) contents in
    if !n = 0 then Error (err_invalid_key ~file k) else Ok s

module Error = struct

  let add errors e =
    if List.mem e errors then errors else List.sort compare (e :: errors)

  let union x y = List.fold_left add x y

  module R = struct
    let add errors e = errors := add !errors e
    let union x y = x := union !x y
  end

end

let replace ~file context contents =
  Log.debug (fun l -> l "replace %a %a" Context.pp context Ast.pp contents);
  let errors = ref [] in
  let aux acc =
    let vars = vars acc in
    Log.debug (fun l -> l "vars in %s: %a" file pp_vars vars);
    List.fold_left (fun acc key ->
        match Context.find context key with
        | None   -> Error.R.add errors (err_invalid_key ~file key); acc
        | Some e -> match subst ~file e acc with
          | Error e -> Error.R.add errors e; acc
          | Ok acc  -> acc

      ) acc vars
  in
  let max = 1000 in
  let rec loop acc = function
    | 0 -> acc
    | n ->
      let nacc = aux acc in
      if nacc = acc then (* fix point *) nacc else loop nacc (n-1)
  in
  let t = loop contents max in
  t, !errors

let custom_compare d x y =
  let ix = try Some (int_of_string x) with Failure _ -> None in
  let iy = try Some (int_of_string y) with Failure _ -> None in
  let r = match ix, iy with
    | Some x, Some y -> compare x y
    | _ -> String.compare x y
  in
  match d with
  | `Up   -> r
  | `Down -> -r

let sort ~file errors loop x y =
  let default = String.compare (fst x) (fst y) in
  let with_order (d, order) =
    match snd x, snd y with
    | Data _      , Data _       -> default
    | Collection x, Collection y ->
      (match String.Map.find order x, String.Map.find order y with
       | Some (Data x), Some (Data y) -> custom_compare d x y
       | None, _ | _, None  ->
         Error.R.add errors (err_invalid_order ~file order);
         default
       | Some (Collection _), _ | _, Some (Collection _) ->
         Error.R.add errors (err_data_is_needed ~file order);
         default
      )
    | _ -> default
  in
  match loop.Ast.order with
  | None       -> default
  | Some order -> with_order order

let unroll ~file context contents =
  let errors = ref [] in
  let empty = Ast.Data "" in
  let rec aux f = function
    | Ast.Data _ | Var _ as x -> f x
    | Seq l as s -> auxes (fun l' -> if l' == l then f s else f (Seq l')) l
    | If c       ->
      if not (Context.mem context c.test) then f empty
      else aux (fun t -> f t) c.then_
    | For loop   ->
      match Context.find context loop.map with
      | None ->
        Error.R.add errors (err_invalid_key ~file loop.map);
        f empty
      | Some { v = Data _; _ } ->
        Error.R.add errors (err_collection_is_needed ~file loop.map);
        f empty
      | Some { v = Collection c; _ } ->
        let entries = String.Map.bindings c in
        let sort = sort ~file errors loop in
        let entries = List.sort sort entries |> List.rev in
        List.fold_left (fun acc (k, v) ->
            Log.debug (fun l -> l "unrolling %s in %a" k Ast.dump loop.body);
            let context = Context.(add empty) { k = loop.var; v } in
            let z, es = replace ~file context loop.body in
            Log.debug (fun l -> l "unrolling is %a" Ast.dump z);
            Error.R.union errors es;
            (z :: acc)
          ) [] entries
        |> fun s -> f (Seq s)
  and auxes f = function
    | []        -> f []
    | h::t as x ->
      aux (fun h' ->
          auxes (fun t' ->
              if h == h' && t == t' then f x
              else f (h' :: t')
            ) t
        ) h
  in
  let r = aux (fun x -> x) contents in
  r, !errors

let eval ~file context contents =
  let rec aux (acc, errors) =
    Log.debug (fun l -> l "eval %a" Ast.dump acc);
    let nacc, es1 = replace ~file context acc in
    let nacc, es2 = unroll ~file context nacc in
    let nacc = Ast.normalize nacc in
    let nerrors = Error.(union errors (union es1 es2)) in
    if nacc == acc && nerrors = errors then (acc, errors)
    else aux (nacc, nerrors)
  in
  aux (contents, [])

let (/) = Filename.concat

let parse_headers str =
  let lines = String.cuts ~sep:"\n" str in
  let kv line = match String.cut ~sep:":" line with
    | None        -> None
    | Some (k, v) ->
      let k = String.trim k in
      let v = String.trim v in
      Some (data k v)
  in
  List.fold_left (fun acc line ->
      match kv line with
      | None   -> acc
      | Some e -> Context.add acc e
    ) Context.empty lines

let parse_yml ~file v =
  (* FIXME: we only support 1-level deep yaml files *)
  (* from foo.yml we create:
     - foo -> collection( (k1->data(v1), ..., kn->data(vn) ) *)
  let k = Filename.chop_extension file in
  kollection k (parse_headers v)

type page = {
  file   : string;
  context: context;
  body   : Ast.t;
  v      : string;
}

let parse_page ~file v =
  let return h v =
    let body = Ast.parse v in
    let context = parse_headers h in
    { file; context; body; v }
  in
  match String.cut ~sep:"---\n" v with
  | None         -> return "" v
  | Some (h, t)  ->
    let h, t =
      if h <> "" then h, t
      else match String.cut ~sep:"---\n" t with
        | None        -> "", t
        | Some (h, t) -> h , t
    in
    return h t

let entry_of_page page =
  let k = Filename.remove_extension page.file in
  if Context.is_empty page.context then
    data k page.v
  else
    let context = Context.add page.context (data "body" page.v) in
    kollection k context

let parse_md ~file v =
  let parse_md v = Omd.(to_html @@ of_string v) in
  let e = parse_page ~file v in
  let v = parse_md e.v in
  entry_of_page { e with v }

let parse_file ~file v =
  Log.debug (fun l -> l "parse_file %s" file);
  match Filename.extension file with
  | ".yml" -> parse_yml ~file v
  | ".md"  -> parse_md ~file v
  | _      -> entry_of_page (parse_page ~file v)

let read_files f dir =
  Log.debug (fun l -> l "read_files %s" dir);
  let files =
    Sys.readdir dir
    |> Array.to_list
    |> List.filter (fun x -> not (Sys.is_directory (dir / x)))
  in
  List.fold_left (fun acc file ->
      let ic = open_in (dir / file) in
      let v = really_input_string ic (in_channel_length ic) in
      close_in ic;
      f ~file v :: acc
    ) [] files

let read_data root =
  (* FIXME: tail recursion *)
  let rec aux dir =
    Log.debug (fun l -> l "read_data root=%s dir=%s" root dir);
    let files = read_files parse_file (root / dir) in
    let dirs =
      Sys.readdir (root / dir)
      |> Array.to_list
      |> List.map (fun x -> dir / x)
      |> List.filter (fun x -> Sys.is_directory (root / x))
    in
    let dirs = List.map (fun dir -> kollection dir (aux dir)) dirs in
    Context.v (files @ dirs)
  in
  aux ""

let read_pages ~dir = read_files parse_page dir
