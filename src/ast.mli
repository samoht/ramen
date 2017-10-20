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

val pp: t Fmt.t
val dump: t Fmt.t
val equal: t -> t -> bool
val name: var -> string option
val equal_var: var -> var -> bool
val pp_var: var Fmt.t
val pp_var_or_data: var_or_data Fmt.t
val pp_test: test Fmt.t
