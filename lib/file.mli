(** File assets module for managing static files *)

type path = Core.File.path
(** The type of a file path *)

type target = Core.File.target
(** The type of a file target *)

type t = Core.File.t
(** The type of a file asset *)

type url = Core.File.url
(** The type of a URL *)

val load : dir:string -> (t list, string) result
(** [load ~dir] loads all static file assets from the images and css
    subdirectories of the given directory. *)

val pp : t Fmt.t
(** [pp t] pretty-prints file [t]. *)
