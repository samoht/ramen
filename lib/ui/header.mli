(** Header component module for site navigation

    This module provides a responsive header component with navigation menu,
    logo, and external links. It adapts to mobile and desktop viewports. *)

open Core

(* Menu item type *)
type menu_item = { label : string; page : Page.t }
(** A menu item with a display label and associated page *)

type t = {
  menu : menu_item list option;
  active_page : Page.t option;
  site : Site.t;
  palette : Colors.palette;
}
(** Component data for the header *)

val render : t -> Html.t
(** [render t] creates a header component. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints header data [t]. *)
