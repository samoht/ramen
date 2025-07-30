(** Layout module for page templating

    This module provides the layout system for rendering HTML pages with
    consistent structure, including head metadata, OpenGraph tags, and body
    content. *)

type config = { main_css : string; js : string list }

type og = {
  title : string;
  description : string option;
  url : string;
  typ : [ `Website | `Article ];
  image : string;
}

type links = { prev : string option; next : string option; canonical : string }
type t

val render :
  title:string ->
  ?description:string ->
  ?og:og ->
  ?links:links ->
  site:Core.Site.t ->
  Core.Page.t ->
  Html.t list ->
  t
(** [render ~title ?description ?og ?links ~site page content] is a complete
    HTML page layout. *)

val raw : string -> t
(** [raw html] is a layout from raw HTML string. *)

val to_string : config -> t -> string
(** [to_string config layout] converts layout to string with CSS/JS
    configuration. *)

val to_tw : t -> Tw.t list
(** [to_tw layout] extracts all Tailwind classes from layout for CSS generation.
*)

val pp_config : config Core.Pp.t
(** [pp_config config] pretty-prints configuration [config]. *)

val pp_og : og Core.Pp.t
(** [pp_og og] pretty-prints OpenGraph metadata [og]. *)

val pp_links : links Core.Pp.t
(** [pp_links links] pretty-prints navigation links [links]. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints layout [t]. *)
