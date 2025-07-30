(** Footer component module

    This module provides a footer component that displays copyright information,
    social media links, and an RSS feed link. *)

open Core

type t = { site : Site.t; palette : Colors.palette }
(** Component data for the footer *)

val render : t -> Html.t
(** [render t] creates the footer component with copyright info and social
    links. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints footer data [t]. *)
