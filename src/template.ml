let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

open Astring

module Ast = struct

  include Ast

  let pp_position file ppf lexbuf =
    let p = Lexing.lexeme_start_p lexbuf in
    Fmt.pf ppf
      "File \"%s\", line %d, character %d"
      file p.Lexing.pos_lnum
      (p.Lexing.pos_cnum - p.Lexing.pos_bol)

  let parse ~file str =
    let lexbuf = Lexing.from_string str in
    try Parser.main Lexer.(token @@ v ()) lexbuf
    with
    | Lexer.Error msg ->
      Fmt.(pf stderr) "%a: %s\n%!" (pp_position file) lexbuf msg;
      exit 1
    | Parser.Error ->
      Fmt.(pf stderr) "%a: syntax error\n%!" (pp_position file) lexbuf;
      exit 1

  (* FIXME: very dumb *)
  let normalize ~file t =
    let t' = parse ~file (Fmt.to_to_string pp t) in
    if t = t' then t else t'

end

let pp_file = Fmt.(styled `Underline string)
let pp_key = Fmt.(styled `Bold string)

(* ENTRIES *)


type value = Data of string | Collection of entries

and entries = entry list
(* we use a list here to preserve collection orders. *)

and entry = { k: string; v: value }

let rec pp_entries pp_data ppf t =
  Fmt.hvbox ~indent:0 (Fmt.list ~sep:Fmt.cut (pp_entry pp_data)) ppf t

and pp_value pp_data ppf = function
  | Data s       -> pp_data ppf s
  | Collection c -> pp_entries pp_data ppf c

and pp_entry pp_data ppf { k; v } =
  Fmt.pf ppf "@[{%a => %a}@] " pp_key k (pp_value pp_data) v

let data k v = { k; v = Data v }

let rec equal_entry x y =
  x == y || (String.equal x.k y.k && equal_value x.v y.v)

and equal_entries x y =
  x == y ||
  List.length x = List.length y && List.for_all2 equal_entry x y

and equal_value x y =
  x == y ||
  match x, y with
  | Data x      , Data y       -> String.equal x y
  | Collection x, Collection y -> equal_entries x y
  | _ -> false

(* CONTEXT *)

module Context: sig
  type t
  val pp: t Fmt.t
  val empty: t
  val dump: t Fmt.t
  val equal: t -> t -> bool
  val v: entry list -> t
  val is_empty: t -> bool
  val add: t -> entry -> t
  val mem: t -> string -> bool
  val find: t -> string -> entry option
  val entries: t -> entry list
  val (++): t -> t -> t
end = struct
  type t = entries (* reverse order *)
  let dump ppf t = pp_entries (fun ppf d -> Fmt.pf ppf "%S" d) ppf (List.rev t)
  let pp ppf t = pp_entries (fun ppf _ -> Fmt.string ppf "...") ppf (List.rev t)
  let is_empty x = x = []
  let equal = equal_entries
  let entries x = List.rev x
  let empty = []
  let v x = (* FIXME: check for duplicates *) List.rev x

  let err_duplicated_key x =
    Fmt.kstrf failwith "duplicated key: %a" pp_key x.k

  let add m x =
    if not (List.exists (equal_entry x) m) then x :: m
    else err_duplicated_key x

  let (++) x y =
    List.iter (fun x ->
        if List.exists (equal_entry x) y then err_duplicated_key x)
      x;
    List.rev_append y (List.rev x)

  let find m k =
    let return x m =
      match List.find (fun e -> String.equal e.k x) m with
      | exception Not_found -> None
      | v                   -> Some { v with k }
    in
    let rec aux path m = function
      | []   -> None
      | [k]  -> return k m
      | h::t ->
        match List.find (fun { k; _ } -> String.equal k h) m with
        | exception Not_found     -> None
        | { v = Collection m; _ } -> aux (h :: path) m t
        | { v = Data _; _ }       -> None
    in
    let path = String.cuts ~sep:"." k in
    aux [] m path

  let mem x k = match find x k with
    | None   -> false
    | Some _ -> true

end

let collection k l = { k; v = Collection Context.(entries @@ v l) }
let kollection k c = { k; v = Collection (Context.entries c) }

let find m k =
  match List.find (fun x -> x.k = k) m with
  | exception Not_found -> None
  | e                   -> Some e.v

type context = Context.t

(* ERRORS *)

type loc = { file: string; key: string; context: context }

type error =
  | Invalid_key of loc
  | Invalid_order of loc
  | Var_not_fully_defined of loc
  | Data_is_needed of loc
  | Collection_is_needed of loc

let err_invalid_key ~file ~context key = Invalid_key { file; key; context }
let err_invalid_order ~file ~context key = Invalid_order { file; key; context }
let err_data_is_needed ~file ~context key = Data_is_needed { file; key; context }

let err_collection_is_needed ~file ~context key =
  Collection_is_needed { file; key; context }

let err_not_fully_defined ~file ~context v =
  Fmt.kstrf
    (fun key -> Var_not_fully_defined { file; key; context })
    "%a" Ast.pp_var v

let pp_error ppf = function
  | Invalid_key { file; key; context } ->
    Fmt.pf ppf "cannot find the key %a in %a. The current context is %a."
      pp_key key pp_file file Context.pp context
  | Invalid_order { file; key; context } ->
    Fmt.pf ppf "The key %a is not a valid sort order in %a. \
                The current context is %a."
      pp_key key pp_file file Context.pp context
  | Data_is_needed { file; key; context } ->
    Fmt.pf ppf "The key %a in %a should be of type 'data'.
                 The current context is %a."
      pp_key key pp_file file Context.pp context
  | Collection_is_needed { file; key; context } ->
    Fmt.pf ppf "They key %a in %a should be of type 'collection'.
                 The current context is %a."
      pp_key key pp_file file Context.pp context
  | Var_not_fully_defined { file; key; context } ->
    Fmt.pf ppf "The variable %a is not fully defined in %a.
                 The current context is %a."
      pp_key key pp_file file Context.pp context

let vars contents =
  let open Ast in
  let vars = ref String.Set.empty in
  let rec aux loops = function
    | Data _ -> ()
    | If c   -> aux loops c.then_
    | For l  -> aux (String.Set.add l.var loops) l.body
    | Seq s  -> List.iter (aux loops) s
    | Var v  -> aux_var loops v
  and aux_var loops v =
    match Ast.name v with
    | Some v ->
      if String.Set.exists (fun k -> String.is_prefix ~affix:k v) loops
      then ()
      else vars := String.Set.add v !vars
    | None   ->
      List.iter (function
          | Id _  -> ()
          | Get v -> aux_var loops v
        ) v
  in
  aux String.Set.empty contents;
  String.Set.elements !vars

let pp_vars = Fmt.(list ~sep:(unit ", ") string)

(* ENGINE *)

let subst ~file ~context { k; v } contents =
  match v with
  | Collection _ -> Error (err_data_is_needed ~context ~file k)
  | Data v       ->
    let open Ast in
    Log.debug (fun l -> l "replacing %a in %a" pp_key k pp_file file);
    let n = ref 0 in
    let rec aux (f: t -> t) = function
      | Var v as x  ->
        auxv (function
          | `Var v' -> if v == v' then f x else f (Var v')
          | `Data v -> f (Data v)
          ) v
      | Data _ as x -> f x
      | Seq s as x -> auxes (fun s' -> if s == s' then f x else (f (Seq s'))) s
      | If c as x  ->
        aux (fun t ->
            if t == c.then_ then f x else f (If { c with then_=t })
          ) c.then_
      | For l as x ->
        aux (fun t ->
            if t == l.body then f x else f (For { l with body=t })
          ) l.body
    and auxv f var = match Ast.name var with
      | Some s when s = k -> incr n; f (`Data v)
      | _                 -> auxids (fun x -> f (`Var x)) var
    and auxids f = function
      | []                   -> f []
      | Id _ as x :: t as l  ->
        auxids (fun t' -> if t == t' then f l else f (x :: t')) t
      | Get g :: t as l      ->
        auxv (fun g' ->
            auxids (fun t' ->
                match g' with
                | `Var g' when g' == g ->
                  if t == t' then f l else f (Get g' :: t')
                | `Data v -> f (Id v :: t')
                | `Var g' -> f (Get g' :: t')
              ) t
          ) g
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
    if !n = 0 then Error (err_invalid_key ~file ~context k) else Ok s

module Error = struct

  let add errors e =
    if List.mem e errors then errors else List.sort compare (e :: errors)

  let union x y = List.fold_left add x y

  module R = struct
    let add errors e = errors := add !errors e
    let union x y = x := union !x y
  end

end

let replace ~file ~context contents =
  Log.debug (fun l -> l "replace %a %a" Context.pp context Ast.pp contents);
  let errors = ref [] in
  let aux acc =
    let vars = vars acc in
    Log.debug (fun l -> l "vars in %s: %a" file pp_vars vars);
    List.fold_left (fun acc key ->
        match Context.find context key with
        | None   -> Error.R.add errors (err_invalid_key ~file ~context key); acc
        | Some e -> match subst ~file ~context e acc with
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

let sort ~file ~context ~errors loop x y =
  let default = String.compare x.k y.k in
  let with_order (d, order) =
    match x.v, y.v with
    | Data _      , Data _       -> default
    | Collection x, Collection y ->
      (match find x order, find y order with
       | Some (Data x), Some (Data y) -> custom_compare d x y
       | None, _ | _, None  ->
         Error.R.add errors (err_invalid_order ~file ~context order);
         default
       | Some (Collection _), _ | _, Some (Collection _) ->
         Error.R.add errors (err_data_is_needed ~file ~context order);
         default
      )
    | _ -> default
  in
  match loop.Ast.order with
  | None       -> default
  | Some order -> with_order order

let eval_test ~file ~context ~errors test =
  Log.debug (fun l -> l "eval_test %a" Ast.pp_test test);
  let err x =
    Error.R.add errors (err_not_fully_defined ~file ~context x);
    false
  in
  let rec aux k = function
    | Ast.Ndef t     -> aux (fun x -> k (not x)) Ast.(Def t)
    | Ast.Neq (x, y) -> aux (fun x -> k (not x)) Ast.(Eq (x, y))
    | Ast.Def t      ->
      (match Ast.name t with
       | None   -> k (err t)
       | Some v -> k (Context.mem context v))
    | Ast.Eq (x, y) ->
      Ast.equal_var x y ||
      match Ast.name x, Ast.name y with
      | Some nx, Some ny ->
        (match Context.find context nx, Context.find context ny with
         | Some x, Some y -> k (equal_value x.v y.v)
         | None  , None   -> k (err x && err y)
         | None  , _      -> k (err x)
         | _     , None   -> k (err y))
      | None, None -> k (err x && err y)
      | None, _    -> k (err x)
      | _   , None -> k (err y)
  in
  aux (fun x -> x) test

let unroll ~file ~context contents =
  let errors = ref [] in
  let empty = Ast.Data "" in
  let rec aux f = function
    | Ast.Data _ | Var _ as x -> f x
    | Seq l as s -> auxes (fun l' -> if l' == l then f s else f (Seq l')) l
    | If c       ->
      if List.for_all (eval_test ~file ~context ~errors) c.test
      then aux (fun t -> f t) c.then_
      else auxelif (fun t -> f t) c.else_
    | For loop   ->
      match Ast.name loop.map with
      | None   -> f empty (* FIXME: errors *)
      | Some v ->
        match Context.find context v with
        | None ->
          Error.R.add errors (err_invalid_key ~file ~context v);
          f empty
        | Some { v = Data _; _ } ->
          Error.R.add errors (err_collection_is_needed ~file ~context v);
          f empty
        | Some { v = Collection c; _ } ->
          let entries = match loop.order with
            | None   -> List.rev c
            | Some _ ->
              let sort = sort ~file ~context ~errors loop in
              List.sort sort c |> List.rev
          in
          List.fold_left (fun acc { k; v } ->
              Log.debug (fun l -> l "unrolling %s in %a" k Ast.dump loop.body);
              let context = Context.add context { k = loop.var; v } in
              let z, es = replace ~file ~context loop.body in
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
  and auxelif f = function
    | None   -> f empty
    | Some c -> aux (fun t -> f t) (If c)
  in
  let r = aux (fun x -> x) contents in
  r, !errors

let eval ~file ~context contents =
  let rec aux (acc, errors) =
    Log.debug (fun l -> l "eval %a" Ast.dump acc);
    let nacc, es1 = replace ~file ~context acc in
    let nacc, es2 = unroll ~file ~context nacc in
    let nacc = Ast.normalize ~file nacc in
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
      | Some e -> e :: acc
    ) [] lines
  |> List.rev
  |> Context.v

let parse_yml ~file v =
  (* FIXME: we only support 1-level deep yaml files *)
  (* from foo.yml we create:
     - foo -> collection( (k1->data(v1), ..., kn->data(vn) ) *)
  let k = Filename.(remove_extension @@ basename file) in
  kollection k (parse_headers v)

let parse_json ~file v =
  let d = Ezjsonm.from_string v in
  let string = function
    | `Bool b   -> string_of_bool b
    | `String s -> s
    | `Float f  -> Fmt.to_to_string Fmt.float f
    | `Null     -> ""
  in
  let rec value k f = function
    | `O o  -> obj [] (fun v -> f (kollection k v)) o
    | `A a  -> arr [] (fun v -> f (kollection k v)) a
    | `Null | `Bool _ | `String _ | `Float _ as v -> f (data k (string v))
  and obj acc f = function
    | []       -> f (Context.v @@ List.rev acc)
    | (k,v)::t -> value k (fun v -> obj (v :: acc) f t) v
  and arr acc f = function
    | []   -> f (Context.v @@ List.rev acc)
    | h::t ->
      let k = string_of_int (List.length acc) in
      value k (fun v -> arr (v :: acc) f t) h
  in
  let k = Filename.(remove_extension @@ basename file) in
  value k (fun x -> x) d

type page = {
  file   : string;
  context: context;
  body   : Ast.t;
  v      : string;
}

let parse_page ~file v =
  let return h v =
    let body = Ast.parse ~file v in
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
  let k = Filename.(remove_extension @@ basename page.file) in
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
  Log.info (fun l -> l "Parsing %s" file);
  match Filename.extension file with
  | ".yml"  -> parse_yml ~file v
  | ".json" -> parse_json ~file v
  | ".md"   -> parse_md ~file v
  | _       -> entry_of_page (parse_page ~file v)

let read_files f dir =
  Log.debug (fun l -> l "read_files %s" dir);
  let files =
    Sys.readdir dir
    |> Array.to_list
    |> List.filter (fun x -> not (String.is_suffix ~affix:"~" x))
    |> List.filter (fun x -> not (Sys.is_directory (dir / x)))
  in
  List.fold_left (fun acc file ->
      let ic = open_in (dir / file) in
      let v = really_input_string ic (in_channel_length ic) in
      close_in ic;
      f ~file:(dir / file) v :: acc
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
    let all = files @ dirs in
    let all = List.sort (fun x y -> String.compare x.k y.k) all in
    Context.v all
  in
  aux ""

let read_pages ~dir = read_files parse_page dir
