(** Homepage generation

    This module handles rendering of the site's homepage, including recent blog
    posts and static content. *)

val render :
  site:Core.Site.t ->
  static_pages:Core.Page.static list ->
  blog_posts:Core.Blog.t list ->
  Ui.Layout.t
(** [render ~site] generates the homepage with recent posts and content. *)

val file : string
(** [file] is the source file location. *)
