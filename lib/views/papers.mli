(** Papers/publications page renderer *)

val render : site:Core.Site.t -> papers:Core.Paper.t list -> Ui.Layout.t
(** [render ~site ~papers] renders the papers page. *)

val file : string
(** [file] is the source file location. *)
