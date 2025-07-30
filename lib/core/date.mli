(** Date formatting utilities *)

val month_to_string : int -> string
(** [month_to_string m] converts month number (1-12) to abbreviated month name.
*)

val weekday_to_string : Ptime.weekday -> string
(** [weekday_to_string wd] converts weekday to abbreviated string. *)

val normalize_date : string -> string
(** [normalize_date date] normalizes an RFC3339 date string to a pretty format.
    Example: "2024-01-01" -> "Mon, 01 Jan 2024". *)

val pretty_date : string -> string
(** [pretty_date date] is an alias for [normalize_date]. *)
