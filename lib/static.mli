(** Static page loading functionality *)

type t = Core.Static.t [@@deriving show]
(** Static page type *)

val load : dir:string -> (t list, [> `Load of string ]) result
(** [load ~dir] loads static pages from the pages directory. *)

val pp : t Fmt.t
(** [pp] pretty-prints a static page. *)
