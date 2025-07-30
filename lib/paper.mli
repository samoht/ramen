(** Papers module for loading academic publications *)

type file = Core.Paper.file
(** The type of a paper file (e.g., PDF) *)

type author = Core.Paper.author
(** The type of a paper author *)

type t = Core.Paper.t
(** The type of a paper/publication *)

val load : dir:string -> (t list, string) result
(** [load ~dir] loads all papers from the papers.json file in the given
    directory. Returns [Ok []] if the file doesn't exist. *)

val pp : t Fmt.t
(** [pp t] pretty-prints paper [t]. *)
