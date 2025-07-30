(** Paper types *)

type file = { name : string; url : string }
type author = { name : string; url : string option }

type t = {
  title : string;
  authors : author list;
  where : string;
  year : string;
  abstract : string option;
  files : file list;
}

val pp : t Pp.t
(** [pp t] pretty-prints paper [t]. *)
