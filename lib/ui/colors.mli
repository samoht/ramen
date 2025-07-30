(** Color definitions and semantic color mappings for the UI *)

(** {1 Color Palette} *)

type palette = {
  primary : Tw.color;
  secondary : Tw.color;
  accent : Tw.color;
  neutral : Tw.color;
}
(** The color palette type defines the core colors used throughout the UI *)

val default_palette : palette
(** Default color palette for the design system. *)

(** {1 Color Generation Functions} *)

(** Functions to generate colors based on a palette *)

val text_primary : palette -> Tw.t
(** [text_primary palette] generates primary text color from palette. *)

val text_secondary : palette -> Tw.t
(** [text_secondary palette] generates secondary text color from palette. *)

val text_muted : palette -> Tw.t
(** [text_muted palette] generates muted text color from palette. *)

val bg_primary : palette -> Tw.t
(** [bg_primary palette] generates primary background color from palette. *)

val bg_secondary : palette -> Tw.t
(** [bg_secondary palette] generates secondary background color from palette. *)

val border_muted : palette -> Tw.t
(** [border_muted palette] generates muted border color from palette. *)

val border_accent : palette -> Tw.t
(** [border_accent palette] generates accent border color from palette. *)

val hover_text_primary : palette -> Tw.t
(** [hover_text_primary palette] generates hover text color from palette. *)

val pp_palette : palette Core.Pp.t
(** [pp_palette palette] pretty-prints color palette. *)
