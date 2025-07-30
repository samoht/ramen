(** Fmt - Lightweight formatting DSL for UI modules

    This module provides a lightweight string formatting DSL that avoids
    Printf/Format modules to keep js_of_ocaml bundle sizes small. The Format
    module is known to significantly increase JavaScript bundle sizes, so we use
    simple string concatenation instead. *)

type 'a t = 'a -> string
(** The type of formatters. *)

val pp : 'a t -> string
(** [pp f] converts a formatter function to its string representation. *)

val str : string list -> string
(** [str segments] concatenates segments into a single string. *)

val sep : string -> string list -> string
(** [sep separator segments] joins segments with separator. *)

val lines : string list -> string
(** [lines segments] joins segments with newlines. *)

val kv : string -> string -> string
(** [kv key value] formats a key-value pair. *)

val field : string -> string -> string
(** [field key value] formats a field as "key = value;". *)

val braces : string -> string
(** [braces content] wraps content in braces. *)

val parens : string -> string
(** [parens content] wraps content in parentheses. *)

val quote : string -> string
(** [quote s] wraps string in quotes. *)

val indent : int -> string -> string
(** [indent n s] indents string with n spaces. *)

val option : 'a t -> 'a option t
(** [option f opt] formats an option value using [f] for the [Some] case. *)

val list : ?sep:string -> 'a t -> 'a list t
(** [list ?sep f lst] formats a list using [f] for each element, separated by
    [sep] (default: ", "). *)

val record : (string * string) list -> string
(** [record fields] formats a record as
    "[ field1 = value1; field2 = value2; ... ]". *)

val string : string t
(** [string s] returns the string itself (identity formatter). *)

val bool : bool t
(** [bool b] formats a boolean as "true" or "false". *)

val int : int t
(** [int n] converts an integer to string. *)

val float : float t
(** [float f] converts a float to string. *)
