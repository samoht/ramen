(** Robots.txt file generation

    This module generates the robots.txt file for search engine crawlers,
    including sitemap location and crawl directives. *)

val file : string
(** [file] is the source file location. *)

val render : site:Core.Site.t -> Ui.Layout.t
(** [render ~site] generates the robots.txt content. *)
