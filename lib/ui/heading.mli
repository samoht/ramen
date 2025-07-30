(** Heading module for creating consistent heading elements

    This module provides functions to create properly styled headings at
    different levels (H1-H4) with consistent typography, spacing, and color
    options. *)

val h1 :
  ?color:[ `Normal | `Light ] ->
  ?clamp:int ->
  ?padding:[ `Normal | `Small ] ->
  ?id:string ->
  palette:Colors.palette ->
  string ->
  Html.t
(** [h1 ?color ?clamp ?padding ?id ~palette text] is an H1 heading element. *)

val h2 :
  ?color:[ `Normal | `Light ] ->
  ?clamp:int ->
  ?padding:[ `Normal | `Small ] ->
  ?id:string ->
  palette:Colors.palette ->
  string ->
  Html.t
(** [h2 ?color ?clamp ?padding ?id ~palette text] is an H2 heading element. *)

val h3 :
  ?color:[ `Normal | `Light ] ->
  ?clamp:int ->
  ?padding:[ `Normal | `Small ] ->
  ?id:string ->
  palette:Colors.palette ->
  string ->
  Html.t
(** [h3 ?color ?clamp ?padding ?id ~palette text] is an H3 heading element. *)

val h4 :
  ?color:[ `Normal | `Light ] ->
  ?clamp:int ->
  ?padding:[ `Normal | `Small ] ->
  ?id:string ->
  palette:Colors.palette ->
  string ->
  Html.t
(** [h4 ?color ?clamp ?padding ?id ~palette text] is an H4 heading element. *)
