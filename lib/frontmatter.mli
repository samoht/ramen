(** Frontmatter parsing utilities *)

type t = {
  yaml : Yaml.value;  (** The parsed YAML frontmatter *)
  body : string;  (** The content after the frontmatter *)
  body_start : int;  (** Line number where the body starts (0-based) *)
}

val pp : t Core.Pp.t
(** [pp] is a pretty-printer for frontmatter. *)

type error = Unclosed_delimiter | Yaml_parse_error of string

val parse : string -> (t option, error) result
(** [parse content] extracts YAML frontmatter from markdown content. Returns
    [Ok None] if no frontmatter is found. Returns [Ok (Some t)] if frontmatter
    is successfully parsed. Returns [Error msg] if frontmatter exists but cannot
    be parsed. *)

val string : string -> Yaml.value -> string option
(** [string key yaml] extracts a string value from YAML. *)

val int : string -> Yaml.value -> int option
(** [int key yaml] extracts an integer value from YAML. *)

val float : string -> Yaml.value -> float option
(** [float key yaml] extracts a float value from YAML. *)

val bool : string -> Yaml.value -> bool option
(** [bool key yaml] extracts a boolean value from YAML. *)

val list : string -> Yaml.value -> Yaml.value list option
(** [list key yaml] extracts a list value from YAML. *)

val string_list : string -> Yaml.value -> string list option
(** [string_list key yaml] extracts a list of strings from YAML. *)
