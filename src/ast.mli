type t =
  | Data of string
  | Var of string
  | If of cond
  | For of loop
  | Seq of t list

and loop = {
  var   : string;
  map   : string;
  order : order option;
  body  : t;
}

and cond = {
  test : string;
  then_: t;
}

and order = [`Up | `Down] * string

val pp: t Fmt.t
val dump: t Fmt.t
val equal: t -> t -> bool
