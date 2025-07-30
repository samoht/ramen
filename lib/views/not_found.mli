(** 404 error page generation

    This module generates the 404 Not Found error page displayed when users
    access non-existent URLs. *)

val file : string
(** [file] is the source file location. *)

val render : site:Core.Site.t -> Ui.Layout.t
(** [render ~site] generates a 404 error page. *)
