(**************************************************************************)
(*  bibtex2html - A BibTeX to HTML translator                             *)
(*  Copyright (C) 1997-2014 Jean-Christophe Filliâtre and Claude Marché   *)
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

(*
 * bibtex2html - A BibTeX to HTML translator
 * Copyright (C) 1997 Jean-Christophe FILLIATRE
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License version 2 for more details
 * (enclosed in the file GPL).
 *)

(*i $Id: latexscan.mll,v 1.40 2010-02-22 07:38:19 filliatr Exp $ i*)

(*s This code is Copyright (C) 1997 Xavier Leroy. *)

{

let src = Logs.Src.create "ramen.latex"
module Log = (val Logs.src_log src: Logs.LOG)

open Latexmacros

type math_mode = MathNone | MathDisplay | MathNoDisplay

let brace_nesting = ref 0
let math_mode = ref MathNone

let is_math_mode () =
  match !math_mode with
  | MathNone -> false
  | MathDisplay | MathNoDisplay -> true

let hevea_url = ref false
let html_entities = ref false

let save_nesting f arg =
  let n = !brace_nesting in
  brace_nesting := 0;
  f arg;
  brace_nesting := n

let save_state f arg =
  let n = !brace_nesting and m = !math_mode in
  brace_nesting := 0;
  math_mode := MathNone;
  f arg;
  brace_nesting := n;
  math_mode := m

let verb_delim = ref (Char.chr 0)

let r = Str.regexp "[ \t\n]+"
let remove_whitespace u = Str.global_replace r "" u

let amp = Str.regexp_string "&"
let url s = Str.global_replace amp "&amp;" s

let print_latex_url ppf u =
  let u = url (remove_whitespace u) in
  Fmt.pf ppf "<a href=\"%s\">%s</a>" u u

let print_hevea_url ppf u t =
  let u = url (remove_whitespace u) in
  Fmt.pf ppf "<a href=\"%s\">%s</a>" u t

let chop_last_space s =
  let n = String.length s in
  if s.[n-1] = ' ' then String.sub s 0 (n-1) else s

let def_macro s n b =
  Log.debug (fun l -> l "macro: %s = %s\n" s b);
  let n = match n with None -> 0 | Some n -> int_of_string n in
  let rec code i subst =
    if i <= n then
      let r = Str.regexp ("#" ^ string_of_int i) in
      [Parameterized
         (fun arg ->
            let subst s = Str.global_replace r (subst s) arg in
            code (i+1) subst)]
    else begin
      let _s = subst b in
      (* eprintf "subst b = %s\n" s; flush stderr; *)
      [Recursive (subst b)]
    end
  in
  def s (code 1 (fun s -> s))

let exec_macro ppf ~main ~print_arg ~raw_arg ~skip_arg lexbuf m =
  let rec exec = function
    | Print str -> Fmt.string ppf str
    | Print_arg -> print_arg ppf lexbuf
    | Raw_arg f -> let s = raw_arg lexbuf in f ppf s
    | Skip_arg -> save_nesting skip_arg lexbuf
    | Recursive s -> main ppf (Lexing.from_string s)
    | Parameterized f -> List.iter exec (f (raw_arg lexbuf))
  in List.iter exec (find_macro m)
}

let space = [' ' '\t' '\n' '\r']
let float = '-'? (['0'-'9']+ | ['0'-'9']* '.' ['0'-'9']*)
let dimension = float ("sp" | "pt" | "bp" | "dd" | "mm" | "pc" |
                       "cc" | "cm" | "in" | "ex" | "em" | "mu")

rule main ppf = parse
(* Comments *)
    '%' [^ '\n'] * '\n' { main ppf lexbuf }
(* Paragraphs *)
  | "\n\n" '\n' *
                { Fmt.string ppf "<p>\n"; main ppf lexbuf }
(* Font changes *)
  | "{\\it" " "* | "{\\itshape" " "*
                  { Fmt.string ppf "<i>";
                    save_state (main ppf)lexbuf;
                    Fmt.string ppf "</i>"; main ppf lexbuf }
  | "{\\em" " "* | "{\\sl" " "* | "{\\slshape" " "*
                  { Fmt.string ppf "<em>";
                    save_state (main ppf) lexbuf;
                    Fmt.string ppf "</em>"; main ppf lexbuf }
  | "{\\bf" " "* | "{\\sf" " "* | "{\\bfseries" " "* | "{\\sffamily" " "*
                  { Fmt.string ppf "<b>";
                    save_state (main ppf) lexbuf;
                    Fmt.string ppf "</b>"; main ppf lexbuf }
  | "{\\sc" " "*  | "{\\scshape" " "* | "{\\normalfont" " "*
  | "{\\upshape" " "* | "{\\mdseries" " "* | "{\\rmfamily" " "*
                  { save_state (main ppf) lexbuf; main ppf lexbuf }
  | "{\\tt" " "* | "{\\ttfamily" " "*
                  { Fmt.string ppf "<tt>";
                    save_state (main ppf) lexbuf;
                    Fmt.string ppf "</tt>"; main ppf lexbuf }
  | "{\\small" " "*
                  { Fmt.string ppf "<font size=\"-1\">";
                    save_state (main ppf) lexbuf;
                    Fmt.string ppf "</font>"; main ppf lexbuf }
  | "{\\rm" " "*
                  { Fmt.string ppf "<span style=\"font-style: normal\">";
                    save_state (main ppf) lexbuf;
                    Fmt.string ppf "</span>"; main ppf lexbuf }
  | "{\\cal" " "*
                  { save_state (main ppf) lexbuf; main ppf lexbuf }
  | "\\cal" " "*  { main ppf lexbuf }
(* Double quotes *)
(***
  | '"'           { Fmt.string ppf "<tt>"; indoublequote lexbuf;
                    Fmt.string ppf "</tt>"; main ppf lexbuf }
***)
(* Verb, verbatim *)
  | ("\\verb" | "\\path") _
                { verb_delim := Lexing.lexeme_char lexbuf 5;
                  Fmt.string ppf "<tt>";
                  inverb ppf lexbuf;
                  Fmt.string ppf "</tt>";
                  main ppf lexbuf }
  | "\\begin{verbatim}"
                { Fmt.string ppf "<pre>"; inverbatim ppf lexbuf;
                  Fmt.string ppf "</pre>"; main ppf lexbuf }
(* Raw html, latex only *)
  | "\\begin{rawhtml}"
                { rawhtml ppf lexbuf; main ppf lexbuf }
  | "\\begin{latexonly}"
                { latexonly lexbuf; main ppf lexbuf }
(* Itemize and similar environments *)
  | "\\item[" [^ ']']* "]"
                { Fmt.string ppf "<dt>";
                  let s = Lexing.lexeme lexbuf in
                  Fmt.string ppf (String.sub s 6 (String.length s - 7));
                  Fmt.string ppf "<dd>"; main ppf lexbuf }
  | "\\item"    { Fmt.string ppf "<li>"; main ppf lexbuf }
(* Math mode (hmph) *)
  | "$"         { math_mode :=
                    begin
                      match !math_mode with
                        | MathNone -> MathNoDisplay
                        | MathNoDisplay -> MathNone
                        | MathDisplay -> (* syntax error *) MathNone
                    end;
                  main ppf lexbuf }
  | "$$"        { math_mode :=
                    begin
                      match !math_mode with
                        | MathNone ->
                            Fmt.string ppf "<blockquote>";
                            MathDisplay
                        | MathNoDisplay -> MathNoDisplay
                        | MathDisplay ->
                            Fmt.string ppf "\n</blockquote>";
                            MathNone
                    end;
                  main ppf lexbuf }
(* \hkip *)
  | "\\hskip" space* dimension
    (space* "plus" space* dimension)? (space* "minus" space* dimension)?
                { Fmt.string ppf " "; main ppf lexbuf }
(* Special characters *)
  | "\\char" ['0'-'9']+
                { let lxm = Lexing.lexeme lexbuf in
                  let code = String.sub lxm 5 (String.length lxm - 5) in
                  Fmt.char ppf (Char.chr(int_of_string code));
                  main ppf lexbuf }
  | "<"         { Fmt.string ppf "&lt;"; main ppf lexbuf }
  | ">"         { Fmt.string ppf "&gt;"; main ppf lexbuf }
  | "~"         { Fmt.string ppf "&nbsp;"; main ppf lexbuf }
  | "``"        { Fmt.string ppf "&ldquo;"; main ppf lexbuf }
  | "''"        { Fmt.string ppf "&rdquo;"; main ppf lexbuf }
  | "--"        { exec_macro ppf ~main ~print_arg ~raw_arg ~skip_arg lexbuf "--";
                  main ppf lexbuf }
  | "---"       { exec_macro ppf ~main ~print_arg ~raw_arg ~skip_arg lexbuf "---";
                  main ppf lexbuf }
  | "^"         { if is_math_mode() then begin
                    let buf = Lexing.from_string (raw_arg lexbuf) in
                    Fmt.string ppf "<sup>";
                    save_state (main ppf) buf;
                    Fmt.string ppf"</sup>"
                  end else
                    Fmt.string ppf "^";
                  main ppf lexbuf }
  | "_"         { if is_math_mode() then begin
                    let buf = Lexing.from_string (raw_arg lexbuf) in
                    Fmt.string ppf "<sub>";
                    save_state (main ppf) buf;
                    Fmt.string ppf"</sub>"
                  end else
                    Fmt.string ppf "_";
                  main ppf lexbuf }
(* URLs *)
  | "\\url" { let url = raw_arg lexbuf in
              if !hevea_url then
                let text = raw_arg lexbuf in print_hevea_url ppf url text
              else
                print_latex_url ppf url;
              main ppf lexbuf }
  | "\\" " "
      { Fmt.string ppf " "; main ppf lexbuf }
(* General case for environments and commands *)
  | ("\\begin{" | "\\end{") ['A'-'Z' 'a'-'z' '@']+ "}" |
    "\\" (['A'-'Z' 'a'-'z' '@']+ '*'? " "? | [^ 'A'-'Z' 'a'-'z'])
                { let m = chop_last_space (Lexing.lexeme lexbuf) in
                  exec_macro ppf ~main ~print_arg ~raw_arg ~skip_arg lexbuf m;
                  main ppf lexbuf }
(* Nesting of braces *)
  | '{'         { incr brace_nesting; main ppf lexbuf }
  | '}'         { if !brace_nesting <= 0
                  then ()
                  else begin decr brace_nesting; main ppf lexbuf end }
(* Default rule for other characters *)
  | eof         { () }
  | ['A'-'Z' 'a'-'z']+
                { if is_math_mode() then Fmt.string ppf "<em>";
                  Fmt.string ppf(Lexing.lexeme lexbuf);
                  if is_math_mode() then Fmt.string ppf "</em>";
                  main ppf lexbuf }
  | _           { Fmt.char ppf (Lexing.lexeme_char lexbuf 0); main ppf lexbuf }

and indoublequote ppf = parse
    '"'         { () }
  | "<"         { Fmt.string ppf "&lt;"; indoublequote ppf lexbuf }
  | ">"         { Fmt.string ppf "&gt;"; indoublequote ppf lexbuf }
  | "&"         { Fmt.string ppf "&amp;"; indoublequote ppf lexbuf }
  | "\\\""      { Fmt.string ppf "\""; indoublequote ppf lexbuf }
  | "\\\\"      { Fmt.string ppf "\\"; indoublequote ppf lexbuf }
  | eof         { () }
  | _           { Fmt.char ppf (Lexing.lexeme_char lexbuf 0);
                  indoublequote ppf lexbuf }

and inverb ppf = parse
    "<"         { Fmt.string ppf "&lt;"; inverb ppf lexbuf }
  | ">"         { Fmt.string ppf "&gt;"; inverb ppf lexbuf }
  | "&"         { Fmt.string ppf "&amp;"; inverb ppf lexbuf }
  | eof         { () }
  | _           { let c = Lexing.lexeme_char lexbuf 0 in
                  if c == !verb_delim then ()
                                      else (Fmt.char ppf c; inverb ppf lexbuf) }
and inverbatim ppf = parse
    "<"         { Fmt.string ppf "&lt;"; inverbatim ppf lexbuf }
  | ">"         { Fmt.string ppf "&gt;"; inverbatim ppf lexbuf }
  | "&"         { Fmt.string ppf "&amp;"; inverbatim ppf lexbuf }
  | "\\end{verbatim}" { () }
  | eof         { () }
  | _           { Fmt.char ppf (Lexing.lexeme_char lexbuf 0);
                  inverbatim ppf lexbuf }

and rawhtml ppf = parse
    "\\end{rawhtml}" { () }
  | eof         { () }
  | _           { Fmt.char ppf (Lexing.lexeme_char lexbuf 0);
                  rawhtml ppf lexbuf }

and latexonly = parse
    "\\end{latexonly}" { () }
  | eof         { () }
  | _           { latexonly lexbuf }

and print_arg ppf = parse
    "{"         { save_nesting (main ppf) lexbuf }
  | "["         { skip_optional_arg lexbuf; print_arg ppf lexbuf }
  | " "         { print_arg ppf lexbuf }
  | eof         { () }
  | _           { Fmt.char ppf (Lexing.lexeme_char lexbuf 0); main ppf lexbuf }

and skip_arg = parse
    "{"         { incr brace_nesting; skip_arg lexbuf }
  | "}"         { decr brace_nesting;
                  if !brace_nesting > 0 then skip_arg lexbuf }
  | "["         { if !brace_nesting = 0 then skip_optional_arg lexbuf;
                  skip_arg lexbuf }
  | " "         { skip_arg lexbuf }
  | eof         { () }
  | _           { if !brace_nesting > 0 then skip_arg lexbuf }

and raw_arg = parse
  | " " | "\n"  { raw_arg lexbuf }
  | '{'         { nested_arg lexbuf }
  | "["         { skip_optional_arg lexbuf; raw_arg lexbuf }
  | '\\' ['A'-'Z' 'a'-'z']+
                { Lexing.lexeme lexbuf }
  | eof         { "" }
  | _           { Lexing.lexeme lexbuf }

and nested_arg = parse
    '}'         { "" }
  | '{'         { let l = nested_arg lexbuf in
                  "{" ^ l ^ "}" ^ (nested_arg lexbuf) }
  | eof         { "" }
  | [^ '{' '}']+{ let x = Lexing.lexeme lexbuf in
                  x ^ (nested_arg lexbuf)   }

and skip_optional_arg = parse
    "]"         { () }
  | eof         { () }
  | _           { skip_optional_arg lexbuf }

(* ajout personnel: [read_macros] pour lire les macros (La)TeX *)

and read_macros = parse
  | "\\def" ('\\' ['a'-'z' 'A'-'Z' '@']+ as s) ("#" (['0'-'9']+ as n))?
      { let b = raw_arg lexbuf in
        def_macro s n b;
        read_macros lexbuf }
  | "\\newcommand" space*
    "{" ("\\" ['a'-'z' 'A'-'Z']+ as s) "}" ("[" (['0'-'9']+ as n) "]")?
      { let b = raw_arg lexbuf in
        def_macro s n b;
        read_macros lexbuf }
  | "\\let" ('\\' ['a'-'z' 'A'-'Z' '@']+ as s) '='
      { let b = raw_arg lexbuf in
        def_macro s None b;
        read_macros lexbuf }
  | eof
      { () }
  | _
      { read_macros lexbuf }
