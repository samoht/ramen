let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

type t =
  | Text of string
  | Var of var
  | If of cond
  | For of loop
  | Seq of t list

and loop = {
  for_ : string;
  in_  : iter;
  do_  : t;
}

and iter =
  | Base of var
  | Rev of iter
  | Sort of iter * string

and cond = {
  if_  : test;
  then_: t;
  else_: t option;
}

and test =
  | Paren of test
  | Def of var
  | Op of var_or_text * op * var_or_text
  | Neg of test
  | And of test * test
  | Or of test * test

and op = [`Eq | `Neq]

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
  Fmt.pf ppf "{{ for %s in %a do }}%a{{ done }}" t.for_ pp_iter t.in_ pp t.do_

and pp_iter ppf = function
  | Base v     -> pp_var ppf v
  | Rev t      -> Fmt.pf ppf "rev(%a)" pp_iter t
  | Sort (f,x) -> Fmt.pf ppf "sort(%a, %s)" pp_iter f x

and pp_cond ppf t =
  Fmt.pf ppf "{{ if %a }}%a%a{{ fi }}" pp_test t.if_ pp t.then_ pp_else t.else_

and pp_else ppf = function
  | None   -> Fmt.string ppf ""
  | Some t -> Fmt.pf ppf "{{ else }}%a" pp t

and pp_test ppf = function
  | Paren x     -> Fmt.pf ppf "(%a)" pp_test x
  | Def x       -> pp_var ppf x
  | Neg x       -> Fmt.pf ppf "!%a" pp_test x
  | Op (x,o,y)  -> Fmt.pf ppf "%a %a %a" pp_var_or_text x pp_op o pp_var_or_text y
  | And (x, y)  -> Fmt.pf ppf "%a && %a" pp_test x pp_test y
  | Or (x, y)   -> Fmt.pf ppf "%a || %a" pp_test x pp_test y

and pp_op ppf = function
  | `Eq  -> Fmt.string ppf "="
  | `Neq -> Fmt.string ppf "!="

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
  Fmt.pf ppf "{for_=%s;@ in_=%a;@ do_=%a}" t.for_ dump_iter t.in_ dump t.do_

and dump_iter ppf = function
  | Base var   -> Fmt.pf ppf "@[<hov 2>Base %a@]" dump_var var
  | Rev t      -> Fmt.pf ppf "@[<hov 2>Rev %a@]" dump_iter t
  | Sort (f,x) -> Fmt.pf ppf "@[<hov 2>Sort (%a,@ %s)@]" dump_iter f x

and dump_cond ppf t =
  Fmt.pf ppf "{test=%a;@ then_=%a;@ else_=%a}"
   dump_test t.if_ dump t.then_ Fmt.(Dump.option dump) t.else_

and dump_test ppf = function
  | Paren t    -> Fmt.pf ppf "@[<hov 2>Paren %a@]" dump_test t
  | Def t      -> Fmt.pf ppf "@[<hov 2>Def %a@]" dump_var t
  | Neg t      -> Fmt.pf ppf "@[<hov 2>Neg %a@]" dump_test t
  | And (x, y) -> Fmt.pf ppf "@[<hov 2>And (%a,@ %a)@]" dump_test x dump_test y
  | Or  (x, y) -> Fmt.pf ppf "@[<hov 2>Or (%a,@ %a)@]" dump_test x dump_test y
  | Op (x,o,y) ->
    Fmt.pf ppf "@[<hov 2>Op (%a,@ %a,@ %a)@]"
      dump_var_or_text x dump_op o dump_var_or_text y

and dump_op ppf = function
  | `Eq  -> Fmt.string ppf "`Eq"
  | `Neq -> Fmt.string ppf "`Neq"

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
  String.equal x.for_ y.for_
  && equal_iter x.in_ y.in_
  && equal x.do_ y.do_

and equal_iter x y = match x, y with
  | Base x    , Base y     -> equal_var x y
  | Rev x     , Rev y      -> equal_iter x y
  | Sort (a,b), Sort (c,d) -> equal_iter a c && String.equal b d
  | Base _, _ | Rev _, _ | Sort _, _ -> false

and equal_cond x y =
  equal_test x.if_ y.if_
  && equal x.then_ y.then_
  && match x.else_, y.else_ with
  | None  , None   -> true
  | Some x, Some y -> equal x y
  | _ -> false

and equal_test x y = match x, y with
  | Paren a   , Paren b    -> equal_test a b
  | Neg a     , Neg b      -> equal_test a b
  | Op (a,x,b), Op (c,y,d) ->
    equal_var_or_text a c && equal_op x y && equal_var_or_text b d
  | And (a, b), And (c, d) -> equal_test a c && equal_test b d
  | Or (a, b) , Or (c ,d)  -> equal_test a c && equal_test b d
  | Def x    , Def y     -> equal_var x y
  | Paren _, _ | Neg _, _ | Op _, _ | Def _, _ | And _, _ | Or _, _ -> false

and equal_op = (=)

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
