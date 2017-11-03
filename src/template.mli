(** Template engine. *)

(** {1 Entries} *)

type entry
(** The type for template rule entries. *)

val pp_entry: entry Fmt.t
(** [pp_entry pp_data] is the pretty-printer for entries. *)

val data: string -> string -> entry
(** [data k v] is the template rule replacing [k] by [v]. *)

val collection: string -> entry list -> entry
(** [collection k v] is the template rule associating [k] to the
    collection [v]. *)

(** {1 Context} *)

module Context: sig

  type t
  (** The type for templating context. *)

  val empty: t
  (** The empty context. *)

  val is_empty: t -> bool
  (** [is_empty t] is true iff [t] is equal to {!empty}. *)

  val pp: t Fmt.t
  (** [pp] is the pretty-printer for contextes. *)

  val dump: t Fmt.t
  (** [dump] dump the contents of any context. *)

  val equal: t -> t -> bool
  (** [equal] is the equality for templating contexes. *)

  val v: entry list -> t
  (** [v es] is the context build from the entries [es]. *)

  val (++): t -> t -> t
  (** [x ++ y] is the union of [x] and [y]. *)

  val add: t -> entry -> t
  (** [add t e] adds the entry in [t]. *)

end

val kollection: string -> Context.t -> entry
(** Same as {!collection} but for contexts. *)

module Ast: sig
  include (module type of Ast)
  val parse: file:string -> string -> t
  val normalize: file:string -> t -> t
end

type context = Context.t
(** The type for contexes. *)

(** {1 Core Engine} *)

type error
(** The type for templating errors. *)

val pp_error: error Fmt.t
(** Pretty-print templating errors. *)

val eval: file:string -> context:Context.t -> ?failfast:bool ->
  Ast.t -> Ast.t * error list
(** [eval c t] evaluates [t] calls using the context [t]. *)

(** {1 Contexts} *)

val read_data: string -> context
(** [read_page dir] reads every files in [dir] and create the rules:
    {i "{% include <filename> %}" -> <file contents>}. *)

(** The type for page templates. *)
type page = {
  file   : string;
  context: context;
  body   : Ast.t;
  v      : string; (** raw body *)
}

val context_of_page: page -> Context.t
(** [entry_of_page p] is the context corresponding [p]'s context and
    adding the binding "body" to [p]'s body. *)

val parse_page: file:string -> string -> page
(** [parse_page ~file s] parses [s] as a page -- a page has a header,
    with a list of key/value pairs and a body, separated by {i
    ---}. *)

val read_pages: dir:string -> page list
(** [read_page dir] reads every files in [dir] and call {!parse_page}
    on them. *)
