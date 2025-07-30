(** Section layout component

    This module provides a flexible section component for organizing page
    content with customizable width, background, and padding options. *)

type background := [ `White | `Gray | `Dark | `Blue | `Gradient ]
type width := [ `Normal | `Large ]
type padding := [ `None | `Small | `Normal ]

val render :
  ?width:width ->
  ?background:background ->
  ?py:padding ->
  ?pt:padding ->
  ?pb:padding ->
  ?id:string ->
  Html.t list ->
  Html.t
(** [render ?width ?background ?py ?pt ?pb ?id content] is a styled section
    element. *)
