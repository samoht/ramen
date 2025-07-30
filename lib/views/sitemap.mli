(** XML sitemap generation

    This module generates XML sitemaps for search engines, listing all
    accessible pages for better SEO. *)

val file : string
(** [file] is the source file location. *)

val render : site:Core.Site.t -> pages:Core.Page.t list -> Ui.Layout.t
(** [render ~site] generates an XML sitemap of all pages. *)
