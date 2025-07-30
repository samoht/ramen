(** RSS/Atom feed generation

    This module generates RSS feeds for blog posts, enabling readers to
    subscribe to content updates. *)

val file : string
(** [file] is the source file location. *)

val render : site:Core.Site.t -> blog_posts:Core.Blog.t list -> Ui.Layout.t
(** [render ~site] generates an RSS feed for all blog posts. *)
