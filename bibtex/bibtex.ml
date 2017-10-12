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

let src = Logs.Src.create "ramen.bib"
module Log = (val Logs.src_log src: Logs.LOG)

(*s Datatype for BibTeX bibliographies. *)

include Types

let dump_entry_type = Fmt.string
let dump_key = Fmt.string

let dump_atom ppf = function
  | Id s     -> Fmt.pf ppf "@[Id %S@]" s
  | String s -> Fmt.pf ppf "@[String %S@]" s

let dump_atoms = Fmt.Dump.list dump_atom

let dump_command ppf = function
  | Comment s     -> Fmt.pf ppf "@[Comment %S@]" s
  | Preamble a    -> Fmt.pf ppf "@[Preamble %a@]" dump_atoms a
  | Abbrev (s, a) -> Fmt.pf ppf "@[Abbrev(%s,@ %a)@]" s dump_atoms a
  | Entry (e,k,a) -> Fmt.pf ppf "@[Entry(%a,@ %a,@ %a)@]"
                       dump_entry_type e
                       dump_key k
                       Fmt.(Dump.list (Dump.pair string dump_atoms)) a

let dump = Fmt.vbox ~indent:2 (Fmt.Dump.list dump_command)

let empty = []

let size b = List.length b

(*s the natural iterator on biblio must start at the first entry, so
   it is the [fold_right] function on lists, NOT the [fold_left]! *)

let fold = List.fold_right

let add biblio command = command :: biblio

module Abbrev: sig
  type t
  val v: unit -> t
  val add: t -> string -> string -> unit
  val find: t -> string -> string option
end = struct

  type t = (string, string) Hashtbl.t
  let add t a s = Hashtbl.add t a s
  let find t s =
    try Some (Hashtbl.find t s)
    with Not_found -> None

  let v () =
    let t = Hashtbl.create 97 in
    (* months are predefined abbreviations *)
    List.iter (fun (id,m) -> add t id m)
      [ "jan", "January" ;
        "feb", "February" ;
        "mar", "March" ;
        "apr", "April" ;
        "may", "May" ;
        "jun", "June" ;
        "jul", "July" ;
        "aug", "August" ;
        "sep", "September" ;
        "oct", "October" ;
        "nov", "November" ;
        "dec", "December" ];
    t

end

type fields = (string * string) list

type entry = entry_type * key * fields

let expand_list abbrev l =
  let rec aux acc = function
    | []              -> String.concat "" (List.rev acc)
    | String s :: rem -> aux (s :: acc) rem
  | Id s     :: rem ->
    let s = match Abbrev.find abbrev s with Some s -> s | None -> s in
    aux (s :: acc) rem
  in
  Latex.to_html (aux [] l)

let rec expand_fields t = function
  | []           -> []
  | (n,l) :: rem -> (n, expand_list t l) :: expand_fields t rem

let macros_in_preamble s =
  try
    let lb = Lexing.from_string s in Latexscan.read_macros lb
  with _ -> ()

let expand abbrev (t: t): entry list =
  fold (fun command accu ->
      match command with
      | Comment _       -> accu
      | Entry (e, k, f) -> (e, k, expand_fields abbrev f) :: accu
      | Preamble l ->
        let s = expand_list abbrev l in
        macros_in_preamble s;
        accu
      | Abbrev (a, l)   ->
        let s = expand_list abbrev l in
        Abbrev.add abbrev a s;
        accu
    ) t []

module Date = struct

  let int_of_month = function
    | "Janvier" | "January" -> 0
    | "Février" | "February" -> 1
    | "Mars" | "March" -> 2
    | "Avril" | "April" -> 3
    | "Mai" | "May" -> 4
    | "Juin" | "June" -> 5
    | "Juillet" | "July" -> 6
    | "Août" | "August" -> 7
    | "Septembre" | "September" -> 8
    | "Octobre" | "October" -> 9
    | "Novembre" | "November" -> 10
    | "Décembre" | "December" -> 11
    | _ -> invalid_arg "int_of_month"

  let month_day_re1 = Str.regexp "\\([a-zA-Z]+\\)\\( \\|~\\)\\([0-9]+\\)"
  let month_day_re2 = Str.regexp "\\([0-9]+\\)\\( \\|~\\)\\([a-zA-Z]+\\)"
  let month_anything = Str.regexp "\\([a-zA-Z]+\\)"

  let parse_month a m =
    if Str.string_match month_day_re1 m 0 then
      int_of_month (Str.matched_group 1 m), int_of_string (Str.matched_group 3 m)
    else if Str.string_match month_day_re2 m 0 then
      int_of_month (Str.matched_group 3 m), int_of_string (Str.matched_group 1 m)
    else if Str.string_match month_anything m 0 then
      match Abbrev.find a (Str.matched_group 1 m) with
      | Some m -> int_of_month m, 1
      | None   ->
        (* be Mendeley-friendly *)
        int_of_month (Str.matched_group 1 m), 1
    else
      int_of_month m, 1


  type date = { year : int; month : int; day : int }

  let dummy_date = { year = 0; month = 0; day = 0 }

  let extract_year k f =
    try int_of_string (List.assoc "year" f)
    with Failure _ ->
      Log.warn (fun l -> l "Warning: incorrect year in entry %s" k);
      0

  let extract_month a f =
    try parse_month a (List.assoc "month" f)
    with Not_found | Failure _ ->
      0, 1

  let rec find_entry k = function
    | [] -> raise Not_found
    | (_,k',_) as e :: r -> if k = k' then e else find_entry k r

  let rec extract_date a el (_,k,f) =
    try
      let y = extract_year k f in
      let m,d = extract_month a f in
      { year = y; month = m; day = d }
    with Not_found ->
    try extract_date a el (find_entry (List.assoc "crossref" f) el)
    with Not_found -> dummy_date

  let combine_comp c d =
    if c=0 then d else c

  let compare a el e1 e2 =
    let d1 = extract_date a el e1 in
    let d2 = extract_date a el e2 in
    combine_comp
      (d1.year - d2.year)
      (combine_comp
         (d1.month - d2.month)
         (d1.day - d2.day))

end

let pp_position ppf lexbuf =
  let open Lexing in
  let pos = lexbuf.lex_curr_p in
  Format.fprintf ppf "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let of_string str =
  let lb = Lexing.from_string str in
  try Some (Parser.command_list Lexer.token lb)
  with
  | Parsing.Parse_error
  | Failure _ ->
    Log.err (fun l -> l "%a: syntax error\n%!" pp_position lb);
    None

let to_html_entries t =
  let a = Abbrev.v () in
  let t = expand a t in
  List.sort (Date.compare a t) t
