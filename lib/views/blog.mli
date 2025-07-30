(** Blog listing page generation

    This module handles rendering of the blog index pages, including pagination,
    tag filtering, and author filtering. *)

open Core

val file : string
(** [file] is the source file location. *)

val render :
  site:Site.t ->
  blog_posts:Blog.t list ->
  all_tags:string list ->
  Blog.index ->
  Ui.Layout.t
(** [render ~site index] renders a blog index page with the given site
    configuration and blog index data. *)
