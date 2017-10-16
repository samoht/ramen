(** Template engine. *)

(** {1 Entries} *)

type entry
(** The type for template rule entries. *)

val pp_entry: string Fmt.t -> entry Fmt.t
(** [pp_entry pp_data] is the pretty-printer for entries using
    [pp_data] to display raw data. *)

val data: string -> string -> entry
(** [data k v] is the template rule replacing [k] by [v]. *)

val collection: string -> entry list -> entry
(** [collection k v] is the template rule associating [k] to the
    collection [v]. *)

(** {1 Context} *)

module Context: sig

  type t
  (** The type for templating context. *)

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
  val parse: string -> t
  val normalize: t -> t
end

type context = Context.t
(** The type for contexes. *)

(** {1 Core Engine} *)

type error
(** The type for templating errors. *)

val pp_error: error Fmt.t
(** Pretty-print templating errors. *)

val subst: file:string -> entry -> Ast.t -> (Ast.t, error) result
(** [replace ?all r s] replaces [r]'s key by [r]'s value in [s] if [r]
    is a data entry. If [all] is set (by default it is not), do not
    stop on the first occurence. *)

val eval: file:string -> context -> Ast.t -> Ast.t * error list
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

val parse_page: file:string -> string -> page
(** [parse_page ~file s] parses [s] as a page -- a page has a header,
    with a list of key/value pairs and a body, separated by {i
    ---}. *)

val read_pages: dir:string -> page list
(** [read_page dir] reads every files in [dir] and call {!parse_page}
    on them. *)
