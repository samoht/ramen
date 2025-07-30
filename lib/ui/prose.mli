(** Prose content formatting

    This module provides components for rendering prose content with consistent
    typography and styling. *)

type size := [ `Very_small | `Small | `Normal ]
type padding := [ `None | `Small | `Normal ]
type color := [ `Normal | `Light ]

val p :
  ?size:size ->
  ?padding:padding ->
  ?color:color ->
  ?clamp:int ->
  palette:Colors.palette ->
  Html.t list ->
  Html.t
(** [p ?size ?padding ?color ?clamp ~palette content] is a styled paragraph
    element. *)
