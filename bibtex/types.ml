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

type t = command list
(** [t] is stored as a list. Beware, this in reverse order: the first
    entry is at the end of the list. This is intentional! *)
