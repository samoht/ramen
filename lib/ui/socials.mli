(** Social media components

    This module provides components for rendering social media links and icons.
*)

open Core

type t = { hover : Tw.t list option; site : Site.t; palette : Colors.palette }
(** Component data for social links *)

val render : t -> Html.t list
(** [render t] is a list of social media links for the site. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints social data [t]. *)
