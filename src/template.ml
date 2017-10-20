let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

open Astring

let save_to_temp_file ~file str =
  let file = Filename.concat "/tmp/ramen" file in
  let dir  = Filename.dirname file in
  let _ = Sys.command ("mkdir -p " ^ dir) in
  let oc = open_out_bin file in
  output_string oc str;
  close_out oc;
  file

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
    let err msg =
      let f = save_to_temp_file ~file str in
      Fmt.(pf stderr) "%a: %s\n.%!" (pp_position f) lexbuf msg;
      exit 1
    in
    try Parser.main Lexer.(token @@ v ()) lexbuf
    with
    | Lexer.Error msg -> err msg
    | Parser.Error -> err "syntax error"
    | Lexer.Unclosed_tag -> Data str

  (* FIXME: very dumb *)
  let normalize ~file t =
    let t' = parse ~file (Fmt.to_to_string pp t) in
    if t = t' then t else t'

end

let pp_file = Fmt.(styled `Underline string)
let pp_key = Fmt.(styled `Bold string)
let pp_var = Fmt.(styled `Bold Ast.pp_var)

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

end

let collection k l = { k; v = Collection Context.(entries @@ v l) }
let kollection k c = { k; v = Collection (Context.entries c) }

let find m k =
  match List.find (fun x -> x.k = k) m with
  | exception Not_found -> None
  | e                   -> Some e.v

type context = Context.t

(* ERRORS *)

type loc = {
  file: string;
  context: context;
  ast: Ast.t;
}

let loc ~file ~context ast = { file; context; ast }

type error =
  | Invalid_key of (string * loc)
  | Invalid_order of (string * loc)
  | Var_not_fully_defined of (Ast.var * loc)
  | Data_is_needed of (string * loc)
  | Collection_is_needed of (string * loc)

let loc_of_error = function
  | Invalid_key (_, x) | Invalid_order (_, x) | Var_not_fully_defined (_, x)
  | Data_is_needed (_, x) | Collection_is_needed (_, x) -> x

let err_invalid_key key loc = Invalid_key (key, loc)
let err_invalid_order key loc = Invalid_order (key, loc)
let err_data_is_needed key loc = Data_is_needed (key, loc)
let err_collection_is_needed key loc = Collection_is_needed (key, loc)
let err_not_fully_defined var loc = Var_not_fully_defined (var, loc)

let pp_error ppf e =
  let loc = loc_of_error e in
  let n = ref 0 in
  let file =
    incr n;
    let str = Fmt.strf "%a\n---\n%a" Context.dump loc.context Ast.pp loc.ast in
    save_to_temp_file ~file:(Fmt.strf "%s.%d" loc.file !n) str
  in
  match e with
  | Invalid_key (key, _) ->
    Fmt.pf ppf "Cannot find the key %a in %a." pp_key key pp_file file
  | Invalid_order (key, _) ->
    Fmt.pf ppf "The key %a is not a valid sort order in %a."
      pp_key key pp_file file
  | Data_is_needed (key, _) ->
    Fmt.pf ppf "The key %a in %a should be of type 'data'."
      pp_key key pp_file file
  | Collection_is_needed (key, _) ->
    Fmt.pf ppf "They key %a in %a should be of type 'collection'."
      pp_key key pp_file file
  | Var_not_fully_defined (var, _) ->
    Fmt.pf ppf "The variable %a is not fully defined in %a."
      pp_var var pp_file file

let equal_error x y =
  match x, y with
  | Invalid_key x          , Invalid_key y           -> x = y
  | Invalid_order x        , Invalid_order y         -> x = y
  | Data_is_needed x       , Data_is_needed y        -> x = y
  | Collection_is_needed x , Collection_is_needed y  -> x = y
  | Var_not_fully_defined x, Var_not_fully_defined y -> x = y
  | _ -> false

(* ENGINE *)

module Acc = struct

  let rec list f k = function
    | [] as x   -> k x
    | h::t as x ->
      f (fun h' ->
          list f (fun t' ->
              if h == h' && t == t' then k x
              else k (h' :: t')
            ) t
        ) h

end

module Error = struct

  let add errors e =
    if List.exists (equal_error e) errors then errors
    else List.sort compare (e :: errors)

  module R = struct
    let add errors e = errors := add !errors e
  end

end

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
  let loc = loc ~file ~context (For loop) in
  let with_order (d, order) =
    match x.v, y.v with
    | Data _      , Data _       -> default
    | Collection x, Collection y ->
      (match find x order, find y order with
       | Some (Data x), Some (Data y) -> custom_compare d x y
       | None, _ | _, None  ->
         Error.R.add errors (err_invalid_order order loc);
         default
       | Some (Collection _), _ | _, Some (Collection _) ->
         Error.R.add errors (err_data_is_needed order loc);
         default
      )
    | _ -> default
  in
  match loop.Ast.order with
  | None       -> default
  | Some order -> with_order order

let empty = Ast.Data ""

let eval_test ~file ~context ~errors t =
  Log.debug (fun l -> l "eval test: %a" Ast.pp_test t);
  let open Ast in
  let loc = loc ~file ~context (If { test=[t]; then_=empty; else_= None }) in
  let find ~err = function
    | `Data d -> Some (data "" d).v
    | `Var x  ->  match Ast.name x with
      | None    ->
        if err then Error.R.add errors (err_not_fully_defined x loc);
        None
      | Some nx ->
        match Context.find context nx with
        | Some x -> Some x.v
        | None   ->
          if err then Error.R.add errors (err_invalid_key nx loc);
          None
  in
  let id k = function
    | Id x  -> k (Some (Id x))
    | Get v ->
      match find ~err:true (`Var v) with
      | Some (Data v) -> k (Some (Id v))
      | None | Some _ -> k None
  in
  let rec var k = function
    | []   -> k (Some [])
    | h::t ->
      id (function
          | None   -> k None
          | Some h ->
            var (function
                | None   -> k None
                | Some t -> k (Some (h::t))
              ) t
        ) h
  in
  let var_is_defined v =
    var (function
        | None   -> false
        | Some v ->
          match find ~err:false (`Var v) with
          | None   -> false
          | Some _ -> true
      ) v
  in
  let rec aux k x =
    match x with
    | Ndef t     -> aux (fun x -> k (not x)) Ast.(Def t)
    | Neq (x, y) -> aux (fun x -> k (not x)) Ast.(Eq (x, y))
    | Def x      -> k (var_is_defined x)
    | Eq (x , y) ->
      let vx = find ~err:true x and vy = find ~err:true y in
      match vx, vy with
      | None  , _      -> k false
      | _     , None   -> k false
      | Some x, Some y -> k (equal_value x y)
  in
  aux (fun x -> x) t

let eval ~file ~context contents =
  let open Ast in
  let errors = ref [] in
  let err ~context e t x =
    let loc = loc ~file ~context t in
    Error.R.add errors (e x loc)
  in
  let normalize = Ast.normalize ~file in

  let rec t ctx k = function
    | Data _ as x -> k x
    | Var v as x  ->
      var ctx (function
          | `Var v' -> if v == v' then k x else t ctx k (normalize @@ Var v')
          | `Data v -> t ctx k (normalize @@ Data v)
        ) v
    | Seq l as s ->
      Acc.list (t ctx) (fun l' ->
          if l == l' then k s else t ctx k (normalize @@ Seq l')
        ) l
    | If c  -> cond ctx k c
    | For l -> loop ctx k l

  and loop ctx k l =
    match Ast.name l.map with
    | None   ->
      Fmt.kstrf (err ~context:ctx err_invalid_key (For l)) "%a" Ast.pp_var l.map;
      k empty
    | Some v ->
      match Context.find ctx v with
      | None ->
        err err_invalid_key ~context:ctx (For l) v;
        k empty
      | Some { v = Data _; _ } ->
        err err_collection_is_needed ~context:ctx (For l) v;
        k empty
      | Some { v = Collection c; _ } ->
        let entries = match l.order with
          | None   -> c
          | Some _ ->
            let sort = sort ~file ~context:ctx ~errors l in
            List.sort sort c
        in
        let bodies =
          List.map (fun { k; v } ->
              Log.debug (fun d -> d "unrolling %s in %a" k Ast.dump l.body);
              let ctx = Context.add ctx { k = l.var; v } in
              ctx, l.body
            ) entries
        in
        Acc.list (fun l (ctx, body) ->
            t ctx (fun body -> l (ctx, body))  body
          ) (fun x ->
            let bodies = List.map snd x in
            k (Seq bodies)
          ) bodies

  and cond ctx k c =
    if List.for_all (eval_test ~file ~context:ctx ~errors) c.test
    then t ctx (fun x -> k x) c.then_
    else match c.else_ with
      | None   -> k empty
      | Some c -> cond ctx k c

  and id ctx k = function
    | Id _ as x  -> k x
    | Get v as x ->
      var ctx (function
          | `Var v' -> if v == v' then k x else k (Get v')
          | `Data v -> k (Id v)
        ) v

  and var ctx k v = match Ast.name v with
    | None   -> Acc.list (id ctx) (fun x -> k (`Var x)) v
    | Some n ->
      match Context.find ctx n with
      | Some { v = Data v; _ } ->
        Log.info (fun l -> l "Replacing %a in %a." pp_key n pp_file file);
        k (`Data v)
      | Some _  ->
        err err_data_is_needed ~context:ctx (Var v) n;
        k (`Var v)
      | None     ->
        err err_invalid_key ~context:ctx (Var v) n;
        k (`Var v)

  in
  let r = t context (fun x -> x) contents in
  r, !errors

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

let context_of_page page =
  let body = data "body" page.v in
  Context.add page.context body

let parse_md ~file v =
  let k = Filename.remove_extension @@ Filename.basename file in
  let parse_md v = Omd.(to_html @@ of_string v) in
  let page = parse_page ~file v in
  let page = { page with v = parse_md page.v } in
  kollection k (context_of_page page)

let parse_file ~file v =
  Log.info (fun l -> l "Parsing %s" file);
  match Filename.extension file with
  | ".yml"  -> parse_yml ~file v
  | ".json" -> parse_json ~file v
  | ".md"   -> parse_md ~file v
  | _       ->
    let k = Filename.(remove_extension @@ basename file) in
    data k v

let read_dir f dir =
  Log.debug (fun l -> l "Reading directory %s" dir);
  let files =
    Sys.readdir dir
    |> Array.to_list
    |> List.filter (fun x -> not (String.is_suffix ~affix:"~" x))
    |> List.filter (fun x -> not (Sys.is_directory (dir / x)))
    |> List.sort String.compare
  in
  List.fold_left (fun acc file ->
      let ic = open_in (dir / file) in
      let v = really_input_string ic (in_channel_length ic) in
      close_in ic;
      f ~file:(dir / file) v :: acc
    ) [] files
  |> List.rev


let read_data root =
  (* FIXME: tail recursion *)
  let rec aux dir =
    Log.debug (fun l -> l "read_data root=%s dir=%s" root dir);
    let files = read_dir parse_file (root / dir) in
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

let read_pages ~dir = read_dir parse_page dir
