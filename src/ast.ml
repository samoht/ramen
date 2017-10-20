let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

type t =
  | Data of string
  | Var of var
  | If of cond
  | For of loop
  | Seq of t list

and loop = {
  var   : string;
  map   : var;
  order : order option;
  body  : t;
}

and cond = {
  test : test list;
  then_: t;
  else_: cond option;
}

and test =
  | Def of var
  | Ndef of var
  | Eq of var_or_data * var_or_data
  | Neq of var_or_data * var_or_data

and order = [`Up | `Down] * string

and var = id list

and var_or_data = [`Var of var | `Data of string]

and id =
  | Id of string
  | Get of var

let rec pp ppf = function
  | Data s -> Fmt.string ppf s
  | Var v  -> Fmt.pf ppf "{{ %a }}" pp_var v
  | Seq l  -> Fmt.(list ~sep:(unit "") pp) ppf l
  | If c   -> pp_cond ppf c
  | For l  -> pp_loop ppf l

and pp_loop ppf t =
  let o ppf = match t.order with
    | None            -> Fmt.string ppf ""
    | Some (`Up  , s) -> Fmt.pf ppf " | %s" s
    | Some (`Down, s) -> Fmt.pf ppf " | -%s" s
  in
  Fmt.pf ppf "{{ for %s in %a%t }}%a{{ endfor }}" t.var pp_var t.map o pp t.body

and pp_cond ppf t =
  Fmt.pf ppf "{{ if %a }}%a%a" pp_ands t.test pp t.then_ pp_elif t.else_

and pp_ands ppf x = Fmt.(list ~sep:(unit " && ") pp_test) ppf x

and pp_test ppf = function
  | Def x     -> pp_var ppf x
  | Ndef x    -> Fmt.pf ppf "!%a" pp_var x
  | Eq (x, y) -> Fmt.pf ppf "(%a = %a)" pp_var_or_data x pp_var_or_data y
  | Neq(x, y) -> Fmt.pf ppf "(%a != %a)" pp_var_or_data x pp_var_or_data y

and pp_elif ppf = function
  | None   -> Fmt.string ppf "{{ endif }}"
  | Some t ->
    Fmt.pf ppf "{{ elif %a }}%a%a" pp_ands t.test pp t.then_ pp_elif t.else_

and pp_var ppf t = Fmt.(list ~sep:(unit ".") pp_id) ppf t

and pp_var_or_data ppf = function
  | `Var v  -> pp_var ppf v
  | `Data d -> Fmt.string ppf d

and pp_id ppf = function
  | Id s  -> Fmt.string ppf s
  | Get v -> Fmt.pf ppf "[%a]" pp_var v

let rec dump ppf = function
  | Data s -> Fmt.pf ppf "@[<hov 2>Data %S@]" s
  | Var v  -> Fmt.pf ppf "@[<hov 2>Var %a@]" dump_var v
  | Seq l  -> Fmt.pf ppf "@[<hov 2>Seq %a@]" Fmt.(Dump.list dump) l
  | If c   -> Fmt.pf ppf "@[<hov 2>If %a@]" dump_cond c
  | For l  -> Fmt.pf ppf "@[<hov 2>For %a@]" dump_loop l

and dump_loop ppf t =
  Fmt.pf ppf "{var=%s;@ map=%a;@ order=%a;@ body=%a}"
    t.var dump_var t.map Fmt.(Dump.option dump_order) t.order dump t.body

and dump_cond ppf t =
  Fmt.pf ppf "{test=%a;@ then_=%a;@ else_=%a}"
   dump_ands t.test dump t.then_ Fmt.(Dump.option dump_cond) t.else_

and dump_ands ppf t = Fmt.(Dump.list dump_test) ppf t

and dump_test ppf = function
  | Def t     -> Fmt.pf ppf "@[<hov 2>Def %a@]" pp_var t
  | Ndef t    -> Fmt.pf ppf "@[<hov 2>Ndef %a@]" pp_var t
  | Eq (x, y) ->
    Fmt.pf ppf "@[<hov 2>Eq (%a,@ %a)@]" pp_var_or_data x pp_var_or_data y
  | Neq(x, y) ->
    Fmt.pf ppf "@[<hov 2>Neq (%a,@ %a)@]" pp_var_or_data x pp_var_or_data y

and dump_order ppf (t, s) = match t with
  | `Up   -> Fmt.string ppf s
  | `Down -> Fmt.pf ppf "-%s" s

and dump_var ppf t = Fmt.(Dump.list dump_id) ppf t

and dump_id ppf = function
  | Id s  -> Fmt.pf ppf "@[<hov 2>Id %S@]" s
  | Get v -> Fmt.pf ppf "@[<hov 2>Get %a@]" dump_var v

let rec equal x y =
  x == y ||
  match x, y with
  | Data x, Data y -> String.equal x y
  | Var x , Var y  -> equal_var x y
  | Seq x , Seq y  -> List.length x = List.length y && List.for_all2 equal x y
  | For x , For y  -> equal_loop x y
  | If  x , If y   -> equal_cond x y
  | _ -> false

and equal_loop x y =
  String.equal x.var y.var
  && equal_var x.map y.map
  && equal_order x.order y.order
  && equal x.body y.body

and equal_order x y = match x, y with
  | None      , None         -> true
  | Some (a, x), Some (b, y) ->  a = b && String.equal x y
  | _ -> false

and equal_cond x y =
  equal_tests x.test y.test
  && equal x.then_ y.then_
  && match x.else_, y.else_ with
  | None  , None   -> true
  | Some x, Some y -> equal_cond x y
  | _ -> false

and equal_test x y = match x, y with
  | Neq (a,b), Neq(c,d)
  | Eq (a, b), Eq (c, d) -> equal_var_or_data a c && equal_var_or_data b d
  | Ndef x   , Ndef y
  | Def x    , Def y     -> equal_var x y
  | _ -> false

and equal_tests x y =
  List.length x = List.length y
  && List.for_all2 equal_test x y

and equal_var x y =
  List.length x = List.length y
  && List.for_all2 id_equal x y

and equal_var_or_data x y = match x, y with
  | `Var x , `Var y  -> equal_var x y
  | `Data x, `Data y -> String.equal x y
  | _ -> false

and id_equal x y = match x, y with
  | Id x , Id y  -> String.equal x y
  | Get x, Get y -> equal_var x y
  | _ -> false

let name var =
  let rec aux acc = function
    | []        -> Some (String.concat "." (List.rev acc))
    | Id x :: t -> aux (x :: acc) t
    | _         -> None
  in
  aux [] var
