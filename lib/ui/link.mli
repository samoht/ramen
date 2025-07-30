(** Link module for creating styled anchor elements

    This module provides functions to create consistent, styled links throughout
    the application with Tailwind CSS classes. It supports both internal and
    external links with appropriate visual indicators. *)

type external_link = { href : string; label : string }

val ocaml_org : external_link
(** OCaml.org website link. *)

val github_org : external_link
(** GitHub organization link. *)

val x : external_link
(** X (formerly Twitter) profile link. *)

val discord : external_link
(** Discord server link. *)

val external' :
  ?class_:Tw.t list -> palette:Colors.palette -> Html.t list -> string -> Html.t
(** [external' ?class_ ~palette content url] is an external link with custom
    styling. *)

val internal' :
  ?class_:Tw.t list -> palette:Colors.palette -> Html.t list -> string -> Html.t
(** [internal' ?class_ ~palette content url] is an internal link with custom
    styling. *)

val external_nav : palette:Colors.palette -> external_link -> Html.t
(** [external_nav ~palette link] is a navigation link for external URLs. *)
