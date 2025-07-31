(** Page types *)

type static = Static.t
(** Static page type (alias for Static.t) *)

(** Page variant for site navigation *)
type t =
  | Index
  | Blog_index of Blog.index
  | Blog_post of Blog.t
  | Blog_feed
  | Papers
  | Static_page of Static.t
  | Error
  | Sitemap
  | Robots_txt

(** Utility functions *)

val blog_index :
  ?filter:Blog.filter -> ?author:Blog.author -> ?tag:string -> int -> t
(** [blog_index ?filter ?author ?tag page_num] creates a blog index page.
*)

val url : ?domain:bool -> t -> string
(** [url ?domain page] returns the URL for a page, optionally with domain. *)

val pp_static : Static.t Pp.t
(** [pp_static static] pretty-prints a static page. *)

val pp : t Pp.t
(** [pp t] pretty-prints a page. *)
