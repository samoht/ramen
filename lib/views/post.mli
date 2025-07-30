(** Individual blog post page generation

    This module handles rendering of individual blog post pages, including
    metadata, tags, and content formatting. *)

val file : Core.Blog.t -> string
(** [file blog] returns the source file path for the given blog post. *)

val render : site:Core.Site.t -> Core.Blog.t -> Ui.Layout.t
(** [render ~site blog] renders a blog post page with the given site
    configuration and blog post data. *)
