type t =
  | Text of string
  | Var of var
  | If of cond
  | For of loop
  | Seq of t list

and loop = {
  for_: string;
  in_ : iter;
  do_ : t;
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

val pp: t Fmt.t
val dump: t Fmt.t
val equal: t -> t -> bool
val name: var -> string option
val equal_var: var -> var -> bool
val pp_var: var Fmt.t
val pp_var_or_text: var_or_text Fmt.t
val pp_test: test Fmt.t
