(** Author card component module

    This module provides a card component to display author information
    including avatar, name, bio, and links. Used in blog posts and author pages.
*)

open Core

val render : Blog.author -> Html.t
(** [render author] creates a card component displaying the author's information
    including avatar, name, bio, and social links. *)
