(** Author type *)

type t = {
  name : string;
  title : string option;
  hidden : bool;
  avatar : string option;
  slug : string;
  aliases : string list;
  homepage : string option;
}

val pp : t Pp.t
(** [pp t] pretty-prints author [t]. *)

val find_by_name : t list -> string -> t option
(** [find_by_name authors name] finds an author by name or alias. *)
