(**************************************************************************)
(*  bibtex2html - A BibTeX to HTML translator                             *)
(*  Copyright (C) 1997-2014 Jean-Christophe Filliâtre and Claude Marché   *)
(*  Copyright (C) 2017 Thomas Gazagnaire                                  *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU General Public                   *)
(*  License version 2, as published by the Free Software Foundation.      *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(*  See the GNU General Public License version 2 for more details         *)
(*  (enclosed in the file GPL).                                           *)
(**************************************************************************)

(** A datatype for BibTeX bibliographies. *)

type entry_type = string

type key = string

type atom =
  | Id of string
  | String of string

type command =
  | Comment of string
  | Preamble of atom list
  | Abbrev of string * atom list
  | Entry  of entry_type * key * (string * atom list) list

type t
(** The type for bibliographies. *)

val dump: t Fmt.t
(** [dump] is the raw pretty-printer bibliographies. *)

val empty: t
(** [empty] is an empty bibliography *)

val add: t -> command -> t
(** [add b c] adds an entry [c] in the biblio [b] and returns the new
    biblio. The [c] is supposed not to exists yet in [b]. *)

val size: t -> int
(** [size b] is the number of commands in [b] *)

val fold: (command -> 'a -> 'a) -> t -> 'a -> 'a
(** [fold f b accu] iterates [f] on the commands of [b], starting from
    [a]. If the commands of [b] are $c_1,\ldots,c_n$ in this order,
    then it computes $f ~ c_n ~ (f ~ c_{n-1} ~ \cdots ~ (f ~ c_1 ~
    a)\cdots)$. *)

val of_string: string -> t option
(** [of_string s] parses the string [s] into a bibliography. *)

(** {1 Expansion} *)

type fields = (string * string) list

type entry = entry_type * key * fields

val to_html_entries: t -> entry list
