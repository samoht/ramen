(** Authors module for loading team member information *)

type t = Core.Author.t [@@deriving show, yaml]
(** The type of an author *)

val load : dir:string -> (t list, string) result
(** [load ~dir] loads the list of authors from the team/team.yml file in the
    given directory. Returns [Ok []] if the file doesn't exist. *)
