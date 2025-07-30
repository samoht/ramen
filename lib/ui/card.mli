(** Card component *)

type variant =
  | Default  (** Basic card with background and border radius *)
  | Elevated  (** Card with shadow *)
  | Outlined  (** Card with border outline *)

val render : ?variant:variant -> ?classes:Tw.t list -> Html.t list -> Html.t
(** [render ?variant ?classes children] renders a card container. *)
