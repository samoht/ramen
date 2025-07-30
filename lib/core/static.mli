(** Static page types and utilities *)

type t = {
  title : string;
  description : string option;
  layout : string;
  name : string;
  body_html : string;
  in_nav : bool; (* Whether to show in navigation *)
  nav_order : int option; (* Optional ordering in navigation *)
}
(** Static page data *)

val pp : t Pp.t
(** [pp t] pretty-prints a static page. *)
