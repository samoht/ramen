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

val find_string : string -> Yaml.value -> string option
(** [find_string key yaml] extracts a string value from YAML. *)

val find_int : string -> Yaml.value -> int option
(** [find_int key yaml] extracts an integer value from YAML. *)

val find_float : string -> Yaml.value -> float option
(** [find_float key yaml] extracts a float value from YAML. *)

val find_bool : string -> Yaml.value -> bool option
(** [find_bool key yaml] extracts a boolean value from YAML. *)

val find_list : string -> Yaml.value -> Yaml.value list option
(** [find_list key yaml] extracts a list value from YAML. *)

val find_string_list : string -> Yaml.value -> string list option
(** [find_string_list key yaml] extracts a list of strings from YAML. *)
