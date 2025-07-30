(** Hero section component for consistent page headers *)

type style =
  | Gradient  (** Index page style with gradient background *)
  | Simple  (** Blog/Papers style with plain background *)
  | Post  (** Blog post style with border *)

type t = {
  style : style option;
  title : string;
  description : string;
  subtitle : string option;
  palette : Colors.palette;
}
(** Component data for hero sections *)

val render : t -> Html.t
(** [render t] creates a hero section. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints hero data [t]. *)
