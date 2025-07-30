(** Avatar component module

    This module provides functions to render user avatars with consistent
    styling, size options, and visual effects like opacity and ring borders. *)

open Core

type opacity =
  | Opacity_50
  | Opacity_70  (** Valid opacity values for avatars *)

type size =
  | Size_6
  | Size_8
  | Size_10
  | Size_12
  | Size_16  (** Valid size values for avatars *)

type t = {
  size : size option;
  opacity : opacity option;
  ring : int option;
  author : Author.t;
}
(** Component data for avatars *)

val render : t -> Html.t
(** [render t] renders an avatar image for the author. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints avatar data [t]. *)
