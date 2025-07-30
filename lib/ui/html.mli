(** A library for building HTML documents programmatically.

    This module provides a type-safe and declarative API for creating HTML
    elements and attributes. It is designed to be used for generating static
    HTML pages. *)

type t
(** The abstract type for an HTML node. *)

type attr
(** The abstract type for an HTML attribute. *)

module At : sig
  (** Functions for creating HTML attributes. *)

  val id : string -> attr
  (** [id "my-id"] creates an [id] attribute. *)

  (** {1 Global attributes} *)

  val title : string -> attr
  (** [title "My Title"] creates a [title] attribute. *)

  val lang : string -> attr
  (** [lang "en"] creates a [lang] attribute. *)

  val dir : string -> attr
  (** [dir "ltr"] creates a [dir] attribute. *)

  val tabindex : int -> attr
  (** [tabindex 0] creates a [tabindex] attribute. *)

  val contenteditable : bool -> attr
  (** [contenteditable true] creates a [contenteditable] attribute. *)

  val spellcheck : bool -> attr
  (** [spellcheck true] creates a [spellcheck] attribute. *)

  val onclick : string -> attr
  (** [onclick "..."] creates an [onclick] attribute. *)

  (** {1 Event attributes} *)

  val onchange : string -> attr
  (** [onchange "..."] creates an [onchange] attribute. *)

  val oninput : string -> attr
  (** [oninput "..."] creates an [oninput] attribute. *)

  val onsubmit : string -> attr
  (** [onsubmit "..."] creates an [onsubmit] attribute. *)

  val type' : string -> attr
  (** [type' "text/css"] creates a [type] attribute. *)

  (** {1 Form attributes} *)

  val value : string -> attr
  (** [value "..."] creates a [value] attribute. *)

  val name : string -> attr
  (** [name "description"] creates a [name] attribute. *)

  val placeholder : string -> attr
  (** [placeholder "..."] creates a [placeholder] attribute. *)

  val required : attr
  (** The [required] attribute. *)

  val disabled : attr
  (** The [disabled] attribute. *)

  val checked : attr
  (** The [checked] attribute. *)

  val readonly : attr
  (** The [readonly] attribute. *)

  val href : string -> attr
  (** [href "/path"] creates an [href] attribute. *)

  (** {1 Link attributes} *)

  val target : string -> attr
  (** [target "_blank"] creates a [target] attribute. *)

  val rel : string -> attr
  (** [rel "stylesheet"] creates a [rel] attribute. *)

  val download : string -> attr
  (** [download "file.pdf"] creates a [download] attribute. *)

  val src : string -> attr
  (** [src "/image.png"] creates a [src] attribute. *)

  (** {1 Media attributes} *)

  val alt : string -> attr
  (** [alt "description"] creates an [alt] attribute for images. *)

  val width : int -> attr
  (** [width 800] creates a [width] attribute. *)

  val height : int -> attr
  (** [height 600] creates a [height] attribute. *)

  val loading : string -> attr
  (** [loading "lazy"] creates a [loading] attribute. *)

  val charset : string -> attr
  (** [charset "utf-8"] creates a [charset] attribute. *)

  (** {1 Meta attributes} *)

  val content : string -> attr
  (** [content "..."] creates a [content] attribute. *)

  val property : string -> attr
  (** [property "og:title"] creates a [property] attribute. *)

  val style : string -> attr
  (** [style "color:red;"] creates a [style] attribute. *)

  (** {1 Style attribute} *)

  val datetime : string -> attr
  (** [datetime "2025-07-28"] creates a [datetime] attribute. *)

  (** {1 Time attributes} *)

  val srcset : string -> attr
  (** [srcset "..."] creates a [srcset] attribute for responsive images. *)

  (** {1 Image attributes} *)

  val sizes : string -> attr
  (** [sizes "..."] creates a [sizes] attribute for responsive images. *)

  val title' : string -> attr
  (** [title' "My Page"] creates a [title] attribute for elements. *)

  (** {1 Additional attributes} *)

  val loading_lazy : attr
  (** The [loading="lazy"] attribute. *)

  val v : string -> string -> attr
  (** [v key value] creates a generic key-value attribute. *)

  val int : string -> int -> attr
  (** [int key value] creates a generic key-value attribute where the value is
      an integer. *)

  val true' : string -> attr
  (** [true' key] creates a boolean attribute with a "true" value. *)

  val false' : string -> attr
  (** [false' key] creates a boolean attribute with a "false" value. *)

  (** {2 SVG Attributes} *)

  val fill_rule : [ `evenodd ] -> attr
  (** [fill_rule `evenodd] sets the fill rule *)

  val clip_rule : [ `evenodd ] -> attr
  (** [clip_rule `evenodd] sets the clipping rule *)

  val cx : int -> attr
  (** [cx n] sets the center x coordinate *)

  val cy : int -> attr
  (** [cy n] sets the center y coordinate *)

  val r : int -> attr
  (** [r n] sets the radius *)

  val view_box : string -> attr
  (** [view_box "0 0 20 20"] sets the viewBox *)

  val fill : string -> attr
  (** [fill "currentColor"] sets the fill color *)

  val stroke : string -> attr
  (** [stroke "currentColor"] sets the stroke color *)

  val stroke_width : string -> attr
  (** [stroke_width "2"] sets the stroke width *)

  val stroke_linecap : string -> attr
  (** [stroke_linecap "round"] sets the stroke line cap *)

  val stroke_linejoin : string -> attr
  (** [stroke_linejoin "round"] sets the stroke line join *)

  val x : string -> attr
  (** [x "10"] sets the x coordinate *)

  val y : string -> attr
  (** [y "10"] sets the y coordinate *)

  val rx : string -> attr
  (** [rx "5"] sets the x radius for rounded rectangles *)

  val d : string -> attr
  (** [d "M10 10 L20 20"] sets the path data *)

  val x1 : string -> attr
  (** [x1 "0"] sets the first x coordinate *)

  val y1 : string -> attr
  (** [y1 "0"] sets the first y coordinate *)

  val x2 : string -> attr
  (** [x2 "20"] sets the second x coordinate *)

  val y2 : string -> attr
  (** [y2 "20"] sets the second y coordinate *)
end

(** {1 Text helpers} *)

val txt : string -> t
(** [txt s] creates a text node from string [s]. *)

val txtf : string list -> t
(** [txtf ["a"; "b"]] is equivalent to [txt "ab"]. *)

val raw : string -> t
(** [raw html] creates a node from raw HTML string. Use with caution. *)

val rawf : string list -> t
(** [rawf ["a"; "b"]] is equivalent to [raw "ab"]. *)

val empty : t
(** [empty] is the empty element, equivalent to no content. *)

(** {1 Aria module}

    Accessibility attributes following ARIA standards. *)
module Aria : sig
  val label : string -> attr
  (** [label "description"] creates an aria-label attribute. *)

  val labelledby : string -> attr
  (** [labelledby "id"] creates an aria-labelledby attribute. *)

  val describedby : string -> attr
  (** [describedby "id"] creates an aria-describedby attribute. *)

  val hidden : attr
  (** [hidden] is the aria-hidden="true" attribute. *)

  val expanded : bool -> attr
  (** [expanded true] creates an aria-expanded attribute. *)

  val current : string -> attr
  (** [current "page"] creates an aria-current attribute. *)

  val role : string -> attr
  (** [role "navigation"] creates a role attribute. *)
end

(** {1 Conversion functions} *)

val to_string : ?doctype:bool -> t -> string
(** [to_string ?doctype element] converts HTML element to string representation.
    If [doctype] is true (default: false), includes the HTML5 doctype
    declaration. *)

val of_htmlit : Htmlit.El.html -> t
(** [of_htmlit el] converts a raw element from the underlying HTML generation
    library into the {!t} type. For interoperability. *)

val to_tw : t -> Tw.t list
(** [to_tw t] extracts all styling classes from an HTML tree. For internal use
    by the CSS generator. *)

(** {1 Livereload module}

    Development-time live reloading support. *)
module Livereload : sig
  val enabled : bool
  (** [enabled] is true if SITE_LIVERELOAD environment variable is "true". *)

  val endpoint : string
  (** [endpoint] is the WebSocket endpoint for livereload. Defaults to
      "ws://localhost:8080" or SITE_LIVERELOAD_ENDPOINT. *)

  val script : t
  (** [script] is the JavaScript code for livereload functionality. Only
      included when [enabled] is true. *)
end

(** {1 HTML Elements} *)

val div : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [div ?at ?tw children] is a div element. *)

val span : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [span ?at ?tw children] is a span element. *)

val p : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [p ?at ?tw children] is a paragraph element. *)

val a : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [a ?at ?tw children] is an anchor/link element. *)

val ul : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [ul ?at ?tw children] is an unordered list element. *)

val li : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [li ?at ?tw children] is a list item element. *)

val nav : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [nav ?at ?tw children] is a navigation element. *)

val section : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [section ?at ?tw children] is a section element. *)

val article : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [article ?at ?tw children] is an article element. *)

val header : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [header ?at ?tw children] is a header element. *)

val footer : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [footer ?at ?tw children] is a footer element. *)

val h1 : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [h1 ?at ?tw children] is an h1 heading element. *)

val h2 : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [h2 ?at ?tw children] is an h2 heading element. *)

val h3 : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [h3 ?at ?tw children] is an h3 heading element. *)

val h4 : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [h4 ?at ?tw children] is an h4 heading element. *)

val h5 : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [h5 ?at ?tw children] is an h5 heading element. *)

val h6 : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [h6 ?at ?tw children] is an h6 heading element. *)

val img : ?at:attr list -> ?tw:Tw.t list -> unit -> t
(** [img ?at ?tw ()] is an img element. *)

val script : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [script ?at ?tw children] is a script element. *)

val meta : ?at:attr list -> ?tw:Tw.t list -> unit -> t
(** [meta ?at ?tw ()] is a meta element. *)

val link : ?at:attr list -> ?tw:Tw.t list -> unit -> t
(** [link ?at ?tw ()] is a link element. *)

val title : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [title ?at ?tw children] is a title element. *)

val head : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [head ?at ?tw children] is a head element. *)

val body : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [body ?at ?tw children] is a body element. *)

val root : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [root ?at ?tw children] is the root [<html>] element of a document. *)

val void : t
(** [void] is an empty void element. *)

val option : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [option ?at ?tw children] is an option element. *)

val select : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [select ?at ?tw children] is a select element. *)

val main : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [main ?at ?tw children] is a main element. *)

val aside : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [aside ?at ?tw children] is an aside element. *)

val time : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [time ?at ?tw children] is a time element. *)

val dialog : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [dialog ?at ?tw children] is a dialog element. *)

val data : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [data ?at ?tw children] is a data element. *)

val picture : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [picture ?at ?tw children] is a picture element. *)

val slot : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [slot ?at ?tw children] is a slot element. *)

val template : ?at:attr list -> ?tw:Tw.t list -> t list -> t
(** [template ?at ?tw children] is a template element. *)

(** {1 SVG Support} *)

(** {2 SVG Elements} *)

val svg : at:attr list -> Htmlit.El.html list -> Htmlit.El.html
(** [svg ~at children] creates an SVG root element. *)

val g : at:attr list -> Htmlit.El.html list -> Htmlit.El.html
(** [g ~at children] creates a group element. *)

val circle : at:attr list -> Htmlit.El.html list -> Htmlit.El.html
(** [circle ~at children] creates a circle element. *)

val rect : at:attr list -> Htmlit.El.html list -> Htmlit.El.html
(** [rect ~at children] creates a rectangle element. *)

val path : at:attr list -> Htmlit.El.html list -> Htmlit.El.html
(** [path ~at children] creates a path element. *)

val line : at:attr list -> Htmlit.El.html list -> Htmlit.El.html
(** [line ~at children] creates a line element. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints HTML element [t]. *)
