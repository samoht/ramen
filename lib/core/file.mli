(** File types *)

type path = { url : string }

type target =
  | File of path
  | Responsive of { main : int * path; alternates : (path * int) list }

type t = { origin : string; target : target }

type url =
  | Url of string
  | Responsive of { src : string; srcset : string; sizes : string }

val pp : t Pp.t
(** [pp t] pretty-prints file [t]. *)

(** {2 Utility functions} *)

val url_of_target : target -> url
(** [url_of_target target] converts a file target to a URL. *)

val href : t -> string
(** [href file] returns the main URL for a file. *)
