type t =
  | Data of string
  | Var of string
  | For of loop
  | Seq of t list

and loop = {
  var   : string;
  map   : string;
  order : string option;
  body  : t;
}

val pp: t Fmt.t
val dump: t Fmt.t
val equal: t -> t -> bool
