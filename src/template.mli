(** Template engine. *)

type rule
(** The type for template rules. *)

val rule: k:string -> v:string -> rule
(** [rule ~k ~v] is the rule replacing [k] by [v]. *)

val k: rule -> string
(** [k r] is [r]'s input. *)

val v: rule -> string
(** [v r] is [r]'s output. *)

val replace: ?all:bool -> rule -> string -> string
(** [replace ?all r s] replaces [r]'s input by [r]'s ouput in [s]. If
    [all] is set (by default it is not), do not stop on the first
    occurence. *)

val eval: rule list -> string -> string
(** [eval r s] calls {!replace} for every bindings of [r] recursively,
    until reaching a fix point. *)

(** {1 Custom Templates} *)

val read_data: string -> rule list
(** [read_page dir] reads every files in [dir] and create the rules:
    {i "{% include <filename> %}" -> <file contents>}. *)

val parse_page: string -> rule list * string
(** [parse_page s] parses [s] as a page -- a page has a header, with a
    list of key/value pairs and a body, separated by {i ---}. *)

val read_pages: string -> (string * rule list * string) list
(** [read_page dir] reads every files in [dir] and call {!parse_page}
    on them. *)
