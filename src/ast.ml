let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

type t =
  | Text of string
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
  | Eq of var_or_text * var_or_text
  | Neq of var_or_text * var_or_text

and order = [`Up | `Down] * string

and var = id list

and var_or_text = [`Var of var | `Text of string]

and id =
  | Id of string
  | App of string * params
  | Get of var

and params = (string * var_or_text) list

let rec pp ppf = function
  | Text s -> Fmt.string ppf s
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
  | Eq (x, y) -> Fmt.pf ppf "(%a = %a)" pp_var_or_text x pp_var_or_text y
  | Neq(x, y) -> Fmt.pf ppf "(%a != %a)" pp_var_or_text x pp_var_or_text y

and pp_elif ppf = function
  | None   -> Fmt.string ppf "{{ endif }}"
  | Some t ->
    Fmt.pf ppf "{{ elif %a }}%a%a" pp_ands t.test pp t.then_ pp_elif t.else_

and pp_var ppf t = Fmt.(list ~sep:(unit ".") pp_id) ppf t

and pp_param ppf (n, v) = Fmt.pf ppf "%s: %a" n pp_var_or_text v

and pp_params ppf t = Fmt.(list ~sep:(unit ", ")) pp_param ppf t

and pp_var_or_text ppf = function
  | `Var v  -> pp_var ppf v
  | `Text d -> Fmt.pf ppf "%S" d

and pp_id ppf = function
  | Id s       -> Fmt.string ppf s
  | App (n, p) -> Fmt.pf ppf "%s(%a)" n pp_params p
  | Get v      -> Fmt.pf ppf "[%a]" pp_var v

let rec dump ppf = function
  | Text s -> Fmt.pf ppf "@[<hov 2>Text %S@]" s
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
  | Def t     -> Fmt.pf ppf "@[<hov 2>Def %a@]" dump_var t
  | Ndef t    -> Fmt.pf ppf "@[<hov 2>Ndef %a@]" dump_var t
  | Eq (x, y) ->
    Fmt.pf ppf "@[<hov 2>Eq (%a,@ %a)@]" dump_var_or_text x dump_var_or_text y
  | Neq(x, y) ->
    Fmt.pf ppf "@[<hov 2>Neq (%a,@ %a)@]" dump_var_or_text x dump_var_or_text y

and dump_order ppf (t, s) = match t with
  | `Up   -> Fmt.string ppf s
  | `Down -> Fmt.pf ppf "-%s" s

and dump_var ppf t = Fmt.(Dump.list dump_id) ppf t

and dump_param ppf (n, v) = Fmt.pf ppf "(%S, %a)" n dump_var_or_text v

and dump_params ppf t = Fmt.(Dump.list dump_param) ppf t

and dump_var_or_text ppf = function
  | `Text s -> Fmt.pf ppf "@[<hov 2>`Text %S@]" s
  | `Var v  -> Fmt.pf ppf "@[<hov 2>`Var %a@]" dump_var v

and dump_id ppf = function
  | Id s       -> Fmt.pf ppf "@[<hov 2>Id %S@]" s
  | App (n, p) -> Fmt.pf ppf "@[<hov 2>{name=%s;@ params=%a}@]" n dump_params p
  | Get v      -> Fmt.pf ppf "@[<hov 2>Get %a@]" dump_var v

let equal_list eq x y =
  List.length x = List.length y
  && List.for_all2 eq x y

let rec equal x y =
  x == y ||
  match x, y with
  | Text x, Text y -> String.equal x y
  | Var x , Var y  -> equal_var x y
  | Seq x , Seq y  -> equal_list equal x y
  | For x , For y  -> equal_loop x y
  | If  x , If y   -> equal_cond x y
  | Text _, _ | Var _, _ | Seq _, _ | For _, _ | If _, _ -> false

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
  | Eq (a, b), Eq (c, d) -> equal_var_or_text a c && equal_var_or_text b d
  | Ndef x   , Ndef y
  | Def x    , Def y     -> equal_var x y
  | Neq _, _ | Eq _, _ | Ndef _, _ | Def _, _ -> false

and equal_tests x y = equal_list equal_test x y

and equal_var x y = equal_list equal_id x y

and equal_param x y =
  String.equal (fst x) (fst y) && equal_var_or_text (snd x) (snd y)

and equal_var_or_text x y = match x, y with
  | `Var x , `Var y  -> equal_var x y
  | `Text x, `Text y -> String.equal x y
  | `Var _, _ | `Text _, _ -> false

and equal_id x y = match x, y with
  | Id x , Id y  -> String.equal x y
  | Get x, Get y -> equal_var x y
  | App (a,b), App (c,d) ->
    String.equal a c && equal_list equal_param b d
  | Id _, _ | Get _, _ | App _, _ -> false

let name var =
  let rec aux acc = function
    | []        -> Some (String.concat "." (List.rev acc))
    | App (x, _) :: t
    | Id x :: t -> aux (x :: acc) t
    | _         -> None
  in
  aux [] var
