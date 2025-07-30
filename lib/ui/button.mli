(** Button component *)

type variant = Primary | Secondary | Outline

val render :
  ?variant:variant ->
  ?size:[ `Small | `Medium | `Large ] ->
  href:string ->
  string ->
  Html.t
(** [render ?variant ?size ~href label] renders a button styled as a link. *)
