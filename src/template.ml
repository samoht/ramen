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
      let msg = Fmt.strf "%a: %s\n.%!" (pp_position f) lexbuf msg in
      Log.err (fun l -> l "%s" msg);
      Ast.(Seq [Text "error: "; Text msg])
    in
    try Parser.main Lexer.(token @@ v ()) lexbuf
    with
    | Lexer.Error msg -> err msg
    | Parser.Error -> err "syntax error"
    | Lexer.Unclosed_tag -> Text str

  (* FIXME: very dumb *)
  let normalize ~file t =
    let t' = parse ~file (Fmt.to_to_string pp t) in
    if t = t' then t else t'

end

let pp_file = Fmt.(styled `Underline string)
let pp_key = Fmt.(styled `Bold string)
let string_of_var = Fmt.to_to_string Ast.pp_var
let pp_ids = Fmt.(styled `Bold @@ list ~sep:(unit ".") string)

(* ENTRIES *)


type value = Data of string | Collection of (string option * entries)

and entries = entry list
(* we use a list here to preserve collection orders. *)

and entry = { k: string; mutable v: value }

module Tbl = Hashtbl.Make(struct
    type t = value
    let equal = (==)
    let hash = Hashtbl.hash
  end)

let default_values () = Tbl.create 17

let rec pp_entries ?(values=default_values ()) pp_data ppf t =
  Fmt.hvbox ~indent:0 (Fmt.list ~sep:Fmt.cut (pp_entry ~values pp_data)) ppf t

and pp_value ?(values=default_values ()) pp_data ppf = function
  | Data s                 -> pp_data ppf s
  | Collection (d, c) as x ->
    if Tbl.mem values x then Fmt.string ppf "..."
    else (
      Tbl.add values x ();
      Fmt.pf ppf "%a%a" Fmt.(option pp_data) d (pp_entries ~values pp_data) c;
    )

and pp_entry ?(values=default_values ()) pp_data ppf { k; v } =
  Fmt.pf ppf "@[{%a => %a}@] " pp_key k (pp_value ~values pp_data) v

let data k v = { k; v = Data v }

module Tbl2 = Hashtbl.Make(struct
    type t = entry list * entry list
    let equal (a, b) (c, d) = a == c && b == d
    let hash = Hashtbl.hash
  end)

let default_values2 () = Tbl2.create 17

let special_fields = [
  "prev";
  "next";
  "last";
  "first";
]

let rec equal_entry ?(values=default_values2 ()) x y =
  x == y || (String.equal x.k y.k && equal_value ~values x.v y.v)

and equal_entries ?(values=default_values2 ()) x y =
  x == y ||
  List.length x = List.length y && List.for_all2 (equal_entry ~values) x y

and equal_value ?(values=default_values2 ()) x y =
  x == y ||
  match x, y with
  | Data x          , Data y           -> String.equal x y
  | Collection (a,x), Collection (c,y) ->
    equal_data_option a c &&
    (match Tbl2.find values (x, y) with
     | v                   -> v
     | exception Not_found ->
       let x' = List.filter (fun e -> not (List.mem e.k special_fields)) x in
       let y' = List.filter (fun e -> not (List.mem e.k special_fields)) y in
       let v = equal_entries x' y' in
       Tbl2.add values (x, y) v;
       v)
  | _ -> false

and equal_data_option x y = match x, y with
  | None  , None   -> true
  | Some x, Some y -> String.equal x y
  | _ -> false

(* CONTEXT *)

module Context: sig
  type t = entries
  val pp: t Fmt.t
  val empty: t
  val dump: t Fmt.t
  val equal: t -> t -> bool
  val v: entry list -> t
  val is_empty: t -> bool
  val add: t -> entry -> t
  val find: t -> string -> value option
  val entries: t -> entry list
  val insert: t -> string list -> entry -> t
  val (++): t -> t -> t
end = struct
  type t = entries (* reverse order *)
  let dump ppf t = pp_entries (fun ppf d -> Fmt.pf ppf "%S" d) ppf (List.rev t)
  let pp ppf t = pp_entries (fun ppf _ -> Fmt.string ppf "...") ppf (List.rev t)
  let is_empty x = x = []
  let equal x y = equal_entries x y
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
    match List.find (fun x -> x.k = k) m with
    | exception Not_found -> None
    | e                   -> Some e.v

  let insert m path (e:entry) =
    let replace m e =
      let m = List.filter (fun x -> x.k <> e.k) m in
      e :: m
    in
    let entry k x c = {k; v=Collection (x, c)} in
    let rec aux (m:t) k = function
      | []   -> k (replace m e)
      | h::t ->
        match find m h with
        | None                     -> aux [] (fun c -> k [entry h None c]) t
        | Some (Data x)            -> aux [] (fun c -> k [entry h (Some x) c]) t
        | Some (Collection (x, c)) ->
          aux c  (fun c -> k (replace m (entry h x c))) t
    in
    aux m (fun x -> x) path

end

let collection k l = { k; v = Collection (None, Context.(entries @@ v l)) }
let kollection k c = { k; v = Collection (None, (Context.entries c)) }

type context = Context.t

(* ERRORS *)

type loc = {
  file: string;
  context: context;
  ast: Ast.t;
}

let loc ~file ~context ast = { file; context; ast }

let equal_loc x y = String.equal x.file y.file && Ast.equal x.ast y.ast

type error =
  | Invalid_key of (string * loc)
  | Invalid_order of (string * loc)
  | Data_is_needed of (string * loc)
  | Collection_is_needed of (string * loc)
  | Param_is_needed of (string * string * loc)

let loc_of_error = function
  | Invalid_key (_, x) | Invalid_order (_, x)
  | Data_is_needed (_, x) | Collection_is_needed (_, x)
  | Param_is_needed (_, _, x) -> x

let err_invalid_key key loc = Invalid_key (key, loc)
let err_invalid_order key loc = Invalid_order (key, loc)
let err_data_is_needed key loc = Data_is_needed (key, loc)
let err_collection_is_needed key loc = Collection_is_needed (key, loc)
let err_param_is_needed key var loc = Param_is_needed (key, var, loc)

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
  | Param_is_needed (key, param, _) ->
    Fmt.pf ppf "They key %a should have the parameter %a in %a."
      pp_key key pp_key param pp_file file

let equal_error x y =
  x == y ||
  equal_loc (loc_of_error x) (loc_of_error y) &&
  match x, y with
  | Invalid_key (x, _)          , Invalid_key (y, _)          -> x = y
  | Invalid_order (x, _)        , Invalid_order (y, _)        -> x = y
  | Data_is_needed (x, _)       , Data_is_needed (y, _)       -> x = y
  | Collection_is_needed (x, _) , Collection_is_needed (y, _) -> x = y
  | Param_is_needed (a, b, _)   , Param_is_needed (c, d, _)   -> a = c && b = d
  | Invalid_key _, _ | Invalid_order _, _ | Data_is_needed _, _
  | Collection_is_needed _, _ | Param_is_needed _, _ -> false

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

  type t = {
    mutable v: error list;
    failfast : bool;
  }

  let v ?(failfast=false) () = { v=[]; failfast }

  let add' errors e =
    if List.exists (equal_error e) errors then errors
    else List.sort compare (e :: errors)

  let add errors e =
    errors.v <- add' errors.v e;
    if errors.failfast then (
      Log.err (fun l -> l "%a" pp_error e);
      exit 1
    )

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
    | Data _           , Data _            -> default
    | Collection (_, x), Collection (_, y) ->
      (match Context.find x order, Context.find y order with
       | Some (Data x), Some (Data y) -> custom_compare d x y
       | None, _ | _, None  ->
         Error.add errors (err_invalid_order order loc);
         default
       | Some (Collection _), _ | _, Some (Collection _) ->
         Error.add errors (err_data_is_needed order loc);
         default
      )
    | _ -> default
  in
  match loop.Ast.order with
  | None       -> default
  | Some order -> with_order order

let empty = Ast.Text ""

let eval_var ~file ~context ~errors v =
  let open Ast in
  let loc = loc ~file ~context (Var v) in
  let (>|=) x f = match x with None -> None | Some x -> Some (f x) in
  let find ctx k h = match Context.find ctx h with
    | Some x -> k x
    | None   -> Error.add errors (err_invalid_key h loc); None
  in
  let collection h k = function
    | Collection c -> k c
    | Data _ -> Error.add errors (err_collection_is_needed h loc); None
  in
  let data h k = function
    | Collection (Some d, _)
    | Data d       -> k d
    | Collection _ -> Error.add errors (err_data_is_needed h loc); None
  in
  let return k h c =
    k c >|= fun (p, v) ->
    List.rev (h::p), v
  in
  let rec var ctx k = function
    | []       -> None
    | Get v::t ->
      var context (fun x ->
          data (string_of_var v) (fun h ->
              var ctx k (Id h :: t) >|= fun (p, v) ->
              h :: p, v
            ) x
        ) v
    | Id h::t ->
      find ctx (fun c ->
          match t with
          | [] -> return k h c
          | _  ->
            collection h (fun (_, ctx) ->
                var (Context.v ctx) k t >|= fun (p, v) ->
                h :: p, v
              ) c
        ) h
    | App (h, p)::t ->
      find ctx (fun c ->
          collection h (fun (d, ctx) ->
              List.iter (fun (n, _) ->
                  if not (List.exists (fun {k; _} -> k = n) ctx) then
                    Error.add errors (err_invalid_key n loc)
                ) p;
              let ctx =
                List.filter (fun {k; _} -> not (List.mem_assoc k p)) ctx
              in
              let ctx = List.rev_map (param h) p @ ctx in
              match t with
              | [] -> return k h (Collection (d, ctx))
              | _  ->
                var (Context.v ctx) k t >|= fun (p, v) ->
                h :: p, v
            ) c
        ) h
  and param h (k, v) = match v with
    | `Text d -> {k; v=Data d}
    | `Var v  ->
      match var context (fun v -> Some ([h], v)) v with
      | Some (_, v) -> {k; v}
      | None        ->
        Error.add errors (err_param_is_needed h k loc);
        {k; v=Data ""}
  in
  let r = var context (fun x -> Some ([], x)) v in
  Log.debug (fun l ->
      let pp_value = pp_value (fun ppf _ -> Fmt.string ppf "...") in
      let pp_r = Fmt.Dump.(option @@ pair pp_ids pp_value) in
      l "eval_var: %a => %a" Ast.pp_var v pp_r r);
  r


let eval_test ~file ~context ~errors t =
  let open Ast in
  let var_is_defined v =
    let errors = Error.v () in
    match eval_var ~file ~context ~errors v with
    | None   -> false
    | Some _ -> true
  in
  let var_or_text = function
    | `Text d -> Data d
    | `Var v  ->
      match eval_var ~file ~context ~errors v with
      | None   -> Data "<undefined>"
      | Some v -> snd v
  in
  let rec aux k x =
    match x with
    | True       -> true
    | Paren x    -> aux k x
    | Def x      -> k (var_is_defined x)
    | Neg x      -> aux (fun x -> k (not x)) x
    | And (x, y) -> aux (fun x -> aux (fun y -> x && y) y) x
    | Or (x, y)  -> aux (fun x -> aux (fun y -> x || y) y) x
    | Op (x,o,y) ->
      let x = var_or_text x in
      let y = var_or_text y in
      let equal = match o with
        | `Eq  -> (fun x y -> equal_value x y)
        | `Neq -> (fun x y -> not (equal_value x y))
      in
      k (equal x y)

  in
  let b = aux (fun x -> x) t in
  Log.debug (fun l -> l "eval_test: %a => %b" Ast.pp_test t b);
  b

(* add .next and .prev to each element of the collection *)
let link_items c =
  let empty = Data "" in
  let nope _ = () in
  let n = List.length c in
  let v i e =
    let d, c = match e.v with
      | Data d            -> Some d, []
      | Collection (d, c) -> d, c
    in
    let set_prev, c =
      if i >= 1 then (
        let prev  = { k="prev"; v = empty } in
        let set_prev e = prev.v <- e.v in
        set_prev, Context.add c prev
      ) else
        nope, c
    in
    let set_next, c =
      if i < n-1 then (
        let next  = { k="next"; v = empty } in
        let set_next e = next.v <- e.v in
        set_next, Context.add c next
      ) else
        nope, c
    in
    set_prev, set_next, { e with v = Collection (d, c) }
  in
  let r = List.mapi v c in
  let a = Array.of_list r in
  List.mapi (fun i (set_prev, set_next, e) ->
      if i >= 1 then (
        let (_, _, p) = a.(i-1) in
        set_prev p;
      );
      if i < n-1 then (
        let (_, _, n) = a.(i+1) in
        set_next n
      );
      e
    ) r

let eval ~file ~context ?(failfast=false) contents =
  let open Ast in
  let errors = Error.v ~failfast () in
  let err ~context e t fmt =
    Fmt.kstrf (fun x ->
        let loc = loc ~file ~context t in
        Error.add errors (e x loc)
      ) fmt
  in
  let normalize = Ast.normalize ~file in

  let rec t ctx k = function
    | Text _ as x -> k x
    | Var v       -> var ctx (fun text -> t ctx k (normalize @@ Text text)) v
    | Seq l as s  ->
      Acc.list (t ctx) (fun l' ->
          if l == l' then k s else t ctx k (normalize @@ Seq l')
        ) l
    | If c  -> cond ctx k c
    | For l -> loop ctx k l

  and loop ctx k l =
    match eval_var ~file ~context:ctx ~errors l.map with
    | None             -> k empty
    | Some (p, Data _) ->
      err err_collection_is_needed ~context:ctx (For l) "%a" pp_ids p;
      k empty
    | Some (_, Collection (_, [])) -> k empty
    | Some (p, Collection (_, c))   ->
      let entries = match l.order with
        | None   -> c
        | Some _ ->
          let sort = sort ~file ~context:ctx ~errors l in
          List.sort sort c
      in
      let entries = link_items entries in
      assert (List.length entries > 0);
      let first = { k="first"; v = (List.hd entries).v } in
      let last  = { k="last" ; v = (List.hd (List.rev entries)).v } in
      let ctx = Context.insert ctx p first in
      let ctx = Context.insert ctx p last in
      let bodies =
        List.map (fun { k; v } ->
            Log.debug (fun d -> d "unrolling %s=%s" l.var k);
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
    if eval_test ~file ~context:ctx ~errors c.test
    then t ctx (fun x -> k x) c.then_
    else match c.else_ with
      | None   -> k empty
      | Some c -> cond ctx k c

  and var ctx k v =
    let replace p d =
      Log.info (fun l -> l "Replacing %a in %a." pp_ids p pp_file file);
      k d
    in
    match eval_var ~file ~context:ctx ~errors v with
    | None                        -> k ""
    | Some (p, Data d)            -> replace p d
    | Some (p, Collection (d, c)) ->
      match Context.find c "body" with
      | Some (Data d) ->
        let ctx = Context.(ctx ++ v c) in
        t ctx (fun s ->
            replace p (Fmt.to_to_string Ast.pp s)
          ) (normalize @@ Text d)
      | _ -> match d with
        | Some d -> replace p d
        | None   ->
          err err_data_is_needed ~context:ctx (Var v) "%s" (string_of_var v);
          k ""
  in
  let r = t context (fun x -> x) contents in
  r, errors.Error.v

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
    kollection k (context_of_page @@ parse_page ~file v)

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
let pp_entry ppf e = pp_entry Fmt.string ppf e
