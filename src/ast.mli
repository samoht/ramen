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
  test : var list;
  then_: t;
  else_: cond option;
}

and order = [`Up | `Down] * string

and var = id list

and id =
  | Id of string
  | Get of var

val pp: t Fmt.t
val dump: t Fmt.t
val equal: t -> t -> bool
val name: var -> string option
