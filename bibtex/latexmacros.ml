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

(* This code is an adaptation of a code written by Xavier Leroy in
   1995-1997, in his own made latex2html translator. See

   @inproceedings{Leroy-latex2html,
               author =        "Xavier Leroy",
               title =         "Lessons learned from the translation of
                         documentation from \LaTeX\ to {HTML}",
               booktitle =     "ERCIM/W4G Int. Workshop on WWW
                         Authoring and Integration Tools",
               year =          1995,
               month =         feb}

*)


let src = Logs.Src.create "ramen.latex"
module Log = (val Logs.src_log src: Logs.LOG)

(*s Actions and translations table. *)

type action =
  | Print of string
  | Print_arg
  | Skip_arg
  | Raw_arg of string Fmt.t
  | Parameterized of (string -> action list)
  | Recursive of string  (*r piece of LaTeX to analyze recursively *)

let cmdtable = (Hashtbl.create 19 : (string, action list) Hashtbl.t)

let def name action =
  Hashtbl.add cmdtable name action

let find_macro name =
  try
    Hashtbl.find cmdtable name
  with Not_found ->
    Log.err (fun l -> l "Unknown macro: %s\n" name);
    []
;;
(*s Translations of general LaTeX macros. *)

(* Sectioning *)
def "\\part"
  [Print "<H0>"; Print_arg; Print "</H0>\n"];
def "\\chapter"
  [Print "<H1>"; Print_arg; Print "</H1>\n"];
def "\\chapter*"
  [Print "<H1>"; Print_arg; Print "</H1>\n"];
def "\\section"
  [Print "<H2>"; Print_arg; Print "</H2>\n"];
def "\\section*"
  [Print "<H2>"; Print_arg; Print "</H2>\n"];
def "\\subsection"
  [Print "<H3>"; Print_arg; Print "</H3>\n"];
def "\\subsection*"
  [Print "<H3>"; Print_arg; Print "</H3>\n"];
def "\\subsubsection"
  [Print "<H4>"; Print_arg; Print "</H4>\n"];
def "\\subsubsection*"
  [Print "<H4>"; Print_arg; Print "</H4>\n"];
def "\\paragraph"
  [Print "<H5>"; Print_arg; Print "</H5>\n"];

(* Text formatting *)
def "\\begin{alltt}" [Print "<pre>"];
def "\\end{alltt}" [Print "</pre>"];
def "\\textbf" [Print "<b>" ; Print_arg ; Print "</b>"];
def "\\mathbf" [Print "<b>" ; Print_arg ; Print "</b>"];
def "\\texttt" [Print "<tt>" ; Print_arg ; Print "</tt>"];
def "\\mathtt" [Print "<tt>" ; Print_arg ; Print "</tt>"];
def "\\textit" [Print "<i>" ; Print_arg ; Print "</i>"];
def "\\mathit" [Print "<i>" ; Print_arg ; Print "</i>"];
def "\\textsl" [Print "<i>" ; Print_arg ; Print "</i>"];
def "\\textem" [Print "<em>" ; Print_arg ; Print "</em>"];
def "\\textrm" [Print_arg];
def "\\mathrm" [Print_arg];
def "\\textmd" [Print_arg];
def "\\textup" [Print_arg];
def "\\textnormal" [Print_arg];
def "\\mathnormal" [Print "<i>" ; Print_arg ; Print "</i>"];
def "\\mathcal" [Print_arg];
def "\\mathbb" [Print_arg];
def "\\mathfrak" [Print_arg];

def "\\textin" [Print "<sub>"; Print_arg; Print "</sub>"];
def "\\textsu" [Print "<sup>"; Print_arg; Print "</sup>"];
def "\\textsuperscript" [Print "<sup>"; Print_arg; Print "</sup>"];
def "\\textsi" [Print "<i>" ; Print_arg ; Print "</i>"];

(* Basic color support. *)

def "\\textcolor" [ Parameterized (function name ->
  match String.lowercase_ascii name with
  (* At the moment, we support only the 16 named colors defined in HTML 4.01. *)
  | "black" | "silver" | "gray" | "white" | "maroon" | "red" | "purple" | "fuchsia"
  | "green" | "lime" | "olive" | "yellow" | "navy" | "blue" | "teal" | "aqua" ->
    [ Print (Printf.sprintf "<font color=%s>" name);
      Print_arg ;
      Print "</font>"
    ]
  (* Other, unknown colors have no effect. *)
  | _ ->
    [ Print_arg ]
  )];

(* Fonts without HTML equivalent *)
def "\\textsf" [Print "<b>" ; Print_arg ; Print "</b>"];
def "\\mathsf" [Print "<b>" ; Print_arg ; Print "</b>"];
def "\\textsc" [Print_arg];

def "\\textln" [Print_arg];
def "\\textos" [Print_arg];
def "\\textdf" [Print_arg];
def "\\textsw" [Print_arg];

def "\\rm" [];
def "\\cal" [];
def "\\emph" [Print "<em>" ; Print_arg ; Print "</em>"];
def "\\mbox" [Print_arg];
def "\\footnotesize" [];
def "\\etalchar" [ Print "<sup>" ; Raw_arg Fmt.string ; Print "</sup>" ];
def "\\newblock" [Print " "];

(* Environments *)
def "\\begin{itemize}" [Print "<p><ul>"];
def "\\end{itemize}" [Print "</ul>"];
def "\\begin{enumerate}" [Print "<p><ol>"];
def "\\end{enumerate}" [Print "</ol>"];
def "\\begin{description}" [Print "<p><dl>"];
def "\\end{description}" [Print "</dl>"];
def "\\begin{center}" [Print "<blockquote>"];
def "\\end{center}" [Print "</blockquote>"];
def "\\begin{htmlonly}" [];
def "\\end{htmlonly}" [];
def "\\begin{flushleft}" [Print "<blockquote>"];
def "\\end{flushleft}" [Print "</blockquote>"];

(* Special characters *)
def "\\ " [Print " "];
def "\\\n" [Print " "];
def "\\{" [Print "{"];
def "\\}" [Print "}"];
def "\\l" [Print "l"];
def "\\L" [Print "L"];
def "\\oe" [Print "&oelig;"];
def "\\OE" [Print "&OElig;"];
def "\\o" [Print "&oslash;"];
def "\\O" [Print "&Oslash;"];
def "\\ae" [Print "&aelig;"];
def "\\AE" [Print "&AElig;"];
def "\\aa" [Print "&aring;"];
def "\\AA" [Print "&Aring;"];
def "\\i" [Print "i"];
def "\\j" [Print "j"];
def "\\&" [Print "&amp;"];
def "\\$" [Print "$"];
def "\\%" [Print "%"];
def "\\_" [Print "_"];
def "\\slash" [Print "/"];
def "\\copyright" [Print "(c)"];
def "\\th" [Print "&thorn;"];
def "\\TH" [Print "&THORN;"];
def "\\dh" [Print "&eth;"];
def "\\DH" [Print "&ETH;"];
def "\\dj" [Print "&#273;"];
def "\\DJ" [Print "&#272;"];
def "\\ss" [Print "&szlig;"];
def "\\rq" [Print "&rsquo;"];
def "\\'" [Raw_arg(function ppf -> function
    | "e" -> Fmt.string ppf "&eacute;"
    | "E" -> Fmt.string ppf "&Eacute;"
    | "a" -> Fmt.string ppf "&aacute;"
    | "A" -> Fmt.string ppf "&Aacute;"
    | "o" -> Fmt.string ppf "&oacute;"
    | "O" -> Fmt.string ppf "&Oacute;"
    | "i" -> Fmt.string ppf "&iacute;"
    | "\\i" -> Fmt.string ppf "&iacute;"
    | "I" -> Fmt.string ppf "&Iacute;"
    | "u" -> Fmt.string ppf "&uacute;"
    | "U" -> Fmt.string ppf "&Uacute;"
    | "'"  -> Fmt.string ppf "&rdquo;"
    | "c" -> Fmt.string ppf "&#x107;"
    | "C" -> Fmt.string ppf "&#x106;"
    | "g" -> Fmt.string ppf "&#x1f5;"
    | "G" -> Fmt.string ppf "G"
    | "l" -> Fmt.string ppf "&#x13A;"
    | "L" -> Fmt.string ppf "&#x139;"
    | "n" -> Fmt.string ppf "&#x144;"
    | "N" -> Fmt.string ppf "&#x143;"
    | "r" -> Fmt.string ppf "&#x155;"
    | "R" -> Fmt.string ppf "&#x154;"
    | "s" -> Fmt.string ppf "&#x15b;"
    | "S" -> Fmt.string ppf "&#x15a;"
    | "y" -> Fmt.string ppf "&yacute;"
    | "Y" -> Fmt.string ppf "&Yacute;"
    | "z" -> Fmt.string ppf "&#x179;"
    | "Z" -> Fmt.string ppf "&#x17a;"
    | ""  -> Fmt.char   ppf  '\''
    | s   -> Fmt.string ppf s)];
def "\\`" [Raw_arg(function ppf -> function
    | "e" -> Fmt.string ppf "&egrave;"
    | "E" -> Fmt.string ppf "&Egrave;"
    | "a" -> Fmt.string ppf "&agrave;"
    | "A" -> Fmt.string ppf "&Agrave;"
    | "o" -> Fmt.string ppf "&ograve;"
    | "O" -> Fmt.string ppf "&Ograve;"
    | "i" -> Fmt.string ppf "&igrave;"
    | "\\i" -> Fmt.string ppf "&igrave;"
    | "I" -> Fmt.string ppf "&Igrave;"
    | "u" -> Fmt.string ppf "&ugrave;"
    | "U" -> Fmt.string ppf "&Ugrave;"
    | "`"  -> Fmt.string ppf "&ldquo;"
    | ""  -> Fmt.string ppf "&lsquo;"
    | s   -> Fmt.string ppf s)];
def "\\~" [Raw_arg(function ppf -> function
    | "n" -> Fmt.string ppf "&ntilde;"
    | "N" -> Fmt.string ppf "&Ntilde;"
    | "o" -> Fmt.string ppf "&otilde;"
    | "O" -> Fmt.string ppf "&Otilde;"
    | "i" -> Fmt.string ppf "&#x129;"
    | "\\i" -> Fmt.string ppf "&#x129;"
    | "I" -> Fmt.string ppf "&#x128;"
    | "a" -> Fmt.string ppf "&atilde;"
    | "A" -> Fmt.string ppf "&Atilde;"
    | "u" -> Fmt.string ppf "&#169;"
    | "U" -> Fmt.string ppf "&#168;"
    | ""  -> Fmt.string ppf "&tilde;"
    | s   -> Fmt.string ppf s)];
def "\\k" [Raw_arg(function ppf -> function
    | "A" -> Fmt.string ppf "&#260;"
    | "a" -> Fmt.string ppf "&#261;"
    | "i" -> Fmt.string ppf "&#302;"
    | "I" -> Fmt.string ppf "&#303;"
    | s   -> Fmt.string ppf s)];
def "\\c" [Raw_arg(function ppf -> function
    | "c" -> Fmt.string ppf "&ccedil;"
    | "C" -> Fmt.string ppf "&Ccedil;"
    | s   -> Fmt.string ppf s)];
def "\\^" [Raw_arg(function ppf -> function
    |"a" -> Fmt.string ppf "&acirc;"
    | "A" -> Fmt.string ppf "&Acirc;"
    | "e" -> Fmt.string ppf "&ecirc;"
    | "E" -> Fmt.string ppf "&Ecirc;"
    | "i" -> Fmt.string ppf "&icirc;"
    | "\\i" -> Fmt.string ppf "&icirc;"
    | "I" -> Fmt.string ppf "&Icirc;"
    | "o" -> Fmt.string ppf "&ocirc;"
    | "O" -> Fmt.string ppf "&Ocirc;"
    | "u" -> Fmt.string ppf "&ucirc;"
    | "U" -> Fmt.string ppf "&Ucirc;"
    | "w" -> Fmt.string ppf "&#x175;"
    | "W" -> Fmt.string ppf "&#x174;"
    | "y" -> Fmt.string ppf "&#x177;"
    | "Y" -> Fmt.string ppf "&#x176;"
    | ""  -> Fmt.char   ppf '^'
    | s   -> Fmt.string ppf s)];
def "\\hat" [Raw_arg(function ppf -> function
    | "a" -> Fmt.string ppf "<em>&acirc;</em>"
    | "A" -> Fmt.string ppf "<em>&Acirc;</em>"
    | "e" -> Fmt.string ppf "<em>&ecirc;</em>"
    | "E" -> Fmt.string ppf "<em>&Ecirc;</em>"
    | "i" -> Fmt.string ppf "<em>&icirc;</em>"
    | "\\i" -> Fmt.string ppf "<em>&icirc;</em>"
    | "I" -> Fmt.string ppf "<em>&Icirc;</em>"
    | "o" -> Fmt.string ppf "<em>&ocirc;</em>"
    | "O" -> Fmt.string ppf "<em>&Ocirc;</em>"
    | "u" -> Fmt.string ppf "<em>&ucirc;</em>"
    | "U" -> Fmt.string ppf "<em>&Ucirc;</em>"
    | ""  -> Fmt.char   ppf '^'
    | s   -> Fmt.string ppf s)];
def "\\\"" [Raw_arg(function ppf -> function
    | "e" -> Fmt.string ppf "&euml;"
    | "E" -> Fmt.string ppf "&Euml;"
    | "a" -> Fmt.string ppf "&auml;"
    | "A" -> Fmt.string ppf "&Auml;"
    | "\\i" -> Fmt.string ppf "&iuml;"
    | "i" -> Fmt.string ppf "&iuml;"
    | "I" -> Fmt.string ppf "&Iuml;"
    | "o" -> Fmt.string ppf "&ouml;"
    | "O" -> Fmt.string ppf "&Ouml;"
    | "u" -> Fmt.string ppf "&uuml;"
    | "U" -> Fmt.string ppf "&Uuml;"
    | "y" -> Fmt.string ppf "&yuml;"
    | "Y" -> Fmt.string ppf "&Yuml;"
    | s   -> Fmt.string ppf s)];
def "\\d" [Raw_arg Fmt.string ];
def "\\." [Raw_arg (function ppf -> function
    | "a" -> Fmt.string ppf "&#x227;"
    | "A" -> Fmt.string ppf "&#x226;"
    | "c" -> Fmt.string ppf "&#x10b;"
    | "C" -> Fmt.string ppf "&#x10a;"
    | "e" -> Fmt.string ppf "&#279;"
    | "E" -> Fmt.string ppf "&#278;"
    | "g" -> Fmt.string ppf "&#289;"
    | "G" -> Fmt.string ppf "&#288;"
    | "i" -> Fmt.string ppf "i"
    | "\\i" -> Fmt.string ppf "i"
    | "I" -> Fmt.string ppf "&#304;"
    | "o" -> Fmt.string ppf "&#559;"
    | "O" -> Fmt.string ppf "&#558;"
    | "z" -> Fmt.string ppf "&#380;"
    | "Z" -> Fmt.string ppf "&#379;"
    | s   -> Fmt.string ppf s)];
def "\\u" [Raw_arg(function  ppf -> function
    | "a" -> Fmt.string ppf "&#x103;"
    | "A" -> Fmt.string ppf "&#x102;"
    | "e" -> Fmt.string ppf "&#x115;"
    | "E" -> Fmt.string ppf "&#x114;"
    | "i" -> Fmt.string ppf "&#x12C;"
    | "\\i" -> Fmt.string ppf "&#x12C;"
    | "I" -> Fmt.string ppf "&#x12D;"
    | "g" -> Fmt.string ppf "&#x11F;"
    | "G" -> Fmt.string ppf "&#x11E;"
    | "o" -> Fmt.string ppf "&#x14F;"
    | "O" -> Fmt.string ppf "&#x14E;"
    | "u" -> Fmt.string ppf "&#x16D;"
    | "U" -> Fmt.string ppf "&#x16C;"
    | s   -> Fmt.string ppf s)];
def "\\v" [Raw_arg(function ppf -> function
    | "C" -> Fmt.string ppf "&#x010C;"
    | "c" -> Fmt.string ppf "&#x010D;"
    | "D" -> Fmt.string ppf "&#270;"
    | "d" -> Fmt.string ppf "&#271;"
    | "E" -> Fmt.string ppf "&#282;"
    | "e" -> Fmt.string ppf "&#283;"
    | "N" -> Fmt.string ppf "&#327;"
    | "n" -> Fmt.string ppf "&#328;"
    | "r" -> Fmt.string ppf "&#X0159;"
    | "R" -> Fmt.string ppf "&#X0158;"
    | "s" -> Fmt.string ppf "&scaron;" (*"&#X0161;"*)
    | "S" -> Fmt.string ppf "&Scaron;" (*"&#X0160;"*)
    | "T" -> Fmt.string ppf "&#356;"
    | "t" -> Fmt.string ppf "&#357;"
    | "\\i" -> Fmt.string ppf "&#X012D;"
    | "i" -> Fmt.string ppf "&#X012D;"
    | "I" -> Fmt.string ppf "&#X012C;"
    | "Z" -> Fmt.string ppf "&#381;"
    | "z" -> Fmt.string ppf "&#382;"
    | s   -> Fmt.string ppf s)];
def "\\H" [Raw_arg (function ppf -> function
    | "O" -> Fmt.string ppf "&#336;"
    | "o" -> Fmt.string ppf "&#337;"
    | "U" -> Fmt.string ppf "&#368;"
    | "u" -> Fmt.string ppf "&#369;"
    | s -> Fmt.string ppf s)];
def "\\r" [Raw_arg (function ppf -> function
    | "U" -> Fmt.string ppf "&#366;"
    | "u" -> Fmt.string ppf "&#367;"
    | s -> Fmt.string ppf s)];

(* Math macros *)
def "\\[" [Print "<blockquote>"];
def "\\]" [Print "\n</blockquote>"];
def "\\le" [Print "&lt;="];
def "\\leq" [Print "&lt;="];
def "\\log" [Print "log"];
def "\\ge" [Print "&gt;="];
def "\\geq" [Print "&gt;="];
def "\\neq" [Print "&lt;&gt;"];
def "\\circ" [Print "o"];
def "\\bigcirc" [Print "O"];
def "\\sim" [Print "~"];
def "\\(" [Print "<I>"];
def "\\)" [Print "</I>"];
def "\\mapsto" [Print "<tt>|-&gt;</tt>"];
def "\\times" [Print "&#215;"];
def "\\neg" [Print "&#172;"];
def "\\frac" [Print "("; Print_arg; Print ")/("; Print_arg; Print ")"];
def "\\not" [Print "not "];

(* Math symbols printed as texts (could we do better?) *)
def "\\ne" [Print "=/="];
def "\\in" [Print "in"];
def "\\forall" [Print "for all"];
def "\\exists" [Print "there exists"];
def "\\vdash" [Print "|-"];
def "\\ln" [Print "ln"];
def "\\gcd" [Print "gcd"];
def "\\min" [Print "min"];
def "\\max" [Print "max"];
def "\\exp" [Print "exp"];
def "\\rightarrow" [Print "-&gt;"];
def "\\to" [Print "-&gt;"];
def "\\longrightarrow" [Print "--&gt;"];
def "\\Rightarrow" [Print "=&gt;"];
def "\\leftarrow" [Print "&lt;-"];
def "\\longleftarrow" [Print "&lt;--"];
def "\\Leftarrow" [Print "&lt;="];
def "\\leftrightarrow" [Print "&lt;-&gt;"];
def "\\sqrt" [Print "sqrt("; Print_arg; Print ")"];
def "\\vee" [Print "V"];
def "\\lor" [Print "V"];
def "\\wedge" [Print "/\\"];
def "\\land" [Print "/\\"];
def "\\Vert" [Print "||"];
def "\\parallel" [Print "||"];
def "\\mid" [Print "|"];
def "\\cup" [Print "U"];
def "\\inf" [Print "inf"];

(* Misc. macros. *)
def "\\TeX" [Print "T<sub>E</sub>X"];
def "\\LaTeX" [Print "L<sup>A</sup>T<sub>E</sub>X"];
def "\\LaTeXe"
  [Print "L<sup>A</sup>T<sub>E</sub>X&nbsp;2<FONT FACE=symbol>e</FONT>"];
def "\\tm" [Print "<sup><font size=-1>TM</font></sup>"];
def "\\par" [Print "<p>"];
def "\\@" [Print " "];
def "\\#" [Print "#"];
def "\\/" [];
def "\\-" [];
def "\\left" [];
def "\\right" [];
def "\\smallskip" [];
def "\\medskip" [];
def "\\bigskip" [];
def "\\relax" [];
def "\\markboth" [Skip_arg; Skip_arg];
def "\\dots" [Print "..."];
def "\\dot" [Print "."];
def "\\simeq" [Print "&tilde;="];
def "\\approx" [Print "&tilde;"];
def "\\^circ" [Print "&deg;"];
def "\\ldots" [Print "..."];
def "\\cdot" [Print "&#183;"];
def "\\cdots" [Print "..."];
def "\\newpage" [];
def "\\hbox" [Print_arg];
def "\\noindent" [];
def "\\label" [Print "<A name=\""; Print_arg; Print "\"></A>"];
def "\\ref" [Print "<A href=\"#"; Print_arg; Print "\">(ref)</A>"];
def "\\index" [Skip_arg];
def "\\\\" [Print "<br>"];
def "\\," [];
def "\\;" [];
def "\\!" [];
def "\\hspace" [Skip_arg; Print " "];
def "\\symbol"
  [Raw_arg (fun ppf s ->
     try let n = int_of_string s in Fmt.char ppf (Char.chr n)
     with _ -> ())];
def "\\html" [Raw_arg Fmt.string];
def "\\textcopyright" [Print "&copy;"];
def "\\textordfeminine" [Print "&ordf;"];
def "\\textordmasculine" [Print "&ordm;"];
def "\\backslash" [Print "&#92;"];


(* hyperref *)
def "\\href"
  [Print "<a href=\""; Raw_arg Fmt.string;
   Print "\">"; Print_arg; Print "</a>"];

(* Bibliography *)
def "\\begin{thebibliography}" [Print "<H2>References</H2>\n<dl>\n"; Skip_arg];
def "\\end{thebibliography}" [Print "</dl>"];
def "\\bibitem" [Raw_arg (fun ppf r ->
    Fmt.string ppf "<dt><A name=\""; Fmt.string ppf r; Fmt.string ppf "\">[";
    Fmt.string ppf r; Fmt.string ppf "]</A>\n";
    Fmt.string ppf "<dd>")];

(* Greek letters *)
(***
   List.iter
   (fun symbol -> def ("\\" ^ symbol) [Print ("<EM>" ^ symbol ^ "</EM>")])
   ["alpha";"beta";"gamma";"delta";"epsilon";"varepsilon";"zeta";"eta";
   "theta";"vartheta";"iota";"kappa";"lambda";"mu";"nu";"xi";"pi";"varpi";
   "rho";"varrho";"sigma";"varsigma";"tau";"upsilon";"phi";"varphi";
   "chi";"psi";"omega";"Gamma";"Delta";"Theta";"Lambda";"Xi";"Pi";
   "Sigma";"Upsilon";"Phi";"Psi";"Omega"];
 ***)
def "\\alpha" [Print "&alpha;"];
def "\\beta" [Print "&beta;"];
def "\\gamma" [Print "&gamma;"];
def "\\delta" [Print "&delta;"];
def "\\epsilon" [Print "&epsilon;"];
def "\\varepsilon" [Print "&epsilon;"];
def "\\zeta" [Print "&zeta;"];
def "\\eta" [Print "&eta;"];
def "\\theta" [Print "&theta;"];
def "\\vartheta" [Print "&theta;"];
def "\\iota" [Print "&iota;"];
def "\\kappa" [Print "&kappa;"];
def "\\lambda" [Print "&lambda;"];
def "\\mu" [Print "&mu;"];
def "\\nu" [Print "&nu;"];
def "\\xi" [Print "&xi;"];
def "\\pi" [Print "&pi;"];
def "\\varpi" [Print "&piv;"];
def "\\rho" [Print "&rho;"];
def "\\varrho" [Print "&rho;"];
def "\\sigma" [Print "&sigma;"];
def "\\varsigma" [Print "&sigmaf;"];
def "\\tau" [Print "&tau;"];
def "\\upsilon" [Print "&upsilon;"];
def "\\phi" [Print "&phi;"];
def "\\varphi" [Print "&phi;"];
def "\\chi" [Print "&chi;"];
def "\\psi" [Print "&psi;"];
def "\\omega" [Print "&omega;"];
def "\\Gamma" [Print "&Gamma;"];
def "\\Delta" [Print "&Delta;"];
def "\\Theta" [Print "&Theta;"];
def "\\Lambda" [Print "&Lambda;"];
def "\\Xi" [Print "&Xi;"];
def "\\Pi" [Print "&Pi;"];
def "\\Sigma" [Print "&Sigma;"];
def "\\Upsilon" [Print "&Upsilon;"];
def "\\Phi" [Print "&Phi;"];
def "\\Psi" [Print "&Psi;"];
def "\\Omega" [Print "&Omega;"];


(* macros for the AMS styles *)

def "\\bysame" [Print "<u>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</u>"];
def "\\MR"
  [Raw_arg (fun ppf s ->
       let mr =
         try
           let i = String.index s ' ' in
           if i=0 then raise Not_found;
           String.sub s 0 i
         with Not_found -> s
       in
       Fmt.string ppf "<a href=\"http://www.ams.org/mathscinet-getitem?mr=";
       Fmt.string ppf mr;
       Fmt.string ppf "\">MR ";
       Fmt.string ppf s;
       Fmt.string ppf "</a>")];
def "\\MRhref"
  [Print "<a href=\"http://www.ams.org/mathscinet-getitem?mr=";
   Print_arg; Print "\">"; Print_arg; Print "</a>"];

(* macros for the aaai-named style *)

def "\\em" [];
def "\\protect" [];
def "\\bgroup" []; (* should go into latexscan? *)
def "\\egroup" []; (* should go into latexscan? *)
def "\\citename" [];

(* dashes *)
def "--" [Print "--"];
def "---" [Print "---"];

()

(* Unicode entities *)

let unicode_entities () =
  def "\\models" [Print "&#X22A8;"];
  def "\\curlyvee" [Print "&#X22CE;"];
  def "\\curlywedge" [Print "&#X22CF"];
  def "\\bigcirc" [Print "&#9711;"];
  def "\\varepsilon" [Print "&#603;"];
  def "\\not" [Raw_arg (function ppf -> function
      | "\\models" -> Fmt.string ppf "&#8877;"
      | s -> Fmt.string ppf "not "; Fmt.string ppf s)];
  def "--" [Print "&#x2013;"];
  def "---" [Print "&#x2014;"];
  ()

let html_entities () =
  def "\\sqrt" [Print "&radic;("; Print_arg; Print ")"];
  def "\\copyright" [Print "&copy;"];
  def "\\tm" [Print "&trade;"];
  def "\\lang" [Print "&lang;"];
  def "\\rang" [Print "&rang;"];
  def "\\lceil" [Print "&lceil;"];
  def "\\rceil" [Print "&rceil;"];
  def "\\lfloor" [Print "&lfloor;"];
  def "\\rfloor" [Print "&rfloor;"];
  def "\\le" [Print "&le;"];
  def "\\leq" [Print "&le;"];
  def "\\ge" [Print "&ge;"];
  def "\\geq" [Print "&ge;"];
  def "\\neq" [Print "&ne;"];
  def "\\approx" [Print "&asymp;"];
  def "\\cong" [Print "&cong;"];
  def "\\equiv" [Print "&equiv;"];
  def "\\propto" [Print "&prop;"];
  def "\\subset" [Print "&sub;"];
  def "\\subseteq" [Print "&sube;"];
  def "\\supset" [Print "&sup;"];
  def "\\supseteq" [Print "&supe;"];
  def "\\ang" [Print "&ang;"];
  def "\\perp" [Print "&perp;"];
  def "\\therefore" [Print "&there4;"];
  def "\\sim" [Print "&sim;"];
  def "\\times" [Print "&times;"];
  def "\\ast" [Print "&lowast;"];
  def "\\otimes" [Print "&otimes;"];
  def "\\oplus" [Print "&oplus;"];
  def "\\lozenge" [Print "&loz;"];
  def "\\diamond" [Print "&loz;"];
  def "\\neg" [Print "&not;"];
  def "\\pm" [Print "&plusmn;"];
  def "\\dagger" [Print "&dagger;"];
  def "\\ne" [Print "&ne;"];
  def "\\in" [Print "&isin;"];
  def "\\notin" [Print "&notin;"];
  def "\\ni" [Print "&ni;"];
  def "\\forall" [Print "&forall;"];
  def "\\exists" [Print "&exist;"];
  def "\\Re" [Print "&real;"];
  def "\\Im" [Print "&image;"];
  def "\\aleph" [Print "&alefsym;"];
  def "\\wp" [Print "&weierp;"];
  def "\\emptyset" [Print "&empty;"];
  def "\\nabla" [Print "&nabla;"];
  def "\\rightarrow" [Print "&rarr;"];
  def "\\to" [Print "&rarr;"];
  def "\\longrightarrow" [Print "&rarr;"];
  def "\\Rightarrow" [Print "&rArr;"];
  def "\\leftarrow" [Print "&larr;"];
  def "\\longleftarrow" [Print "&larr;"];
  def "\\Leftarrow" [Print "&lArr;"];
  def "\\leftrightarrow" [Print "&harr;"];
  def "\\sum" [Print "&sum;"];
  def "\\prod" [Print "&prod;"];
  def "\\int" [Print "&int;"];
  def "\\partial" [Print "&part;"];
  def "\\vee" [Print "&or;"];
  def "\\lor" [Print "&or;"];
  def "\\wedge" [Print "&and;"];
  def "\\land" [Print "&and;"];
  def "\\cup" [Print "&cup;"];
  def "\\infty" [Print "&infin;"];
  def "\\simeq" [Print "&cong;"];
  def "\\cdot" [Print "&sdot;"];
  def "\\cdots" [Print "&sdot;&sdot;&sdot;"];
  def "\\vartheta" [Print "&thetasym;"];
  def "\\angle" [Print "&ang;"];
  def "\\=" [Raw_arg(function ppf -> function
      | "a" -> Fmt.string ppf "&abar;"
      | "A" -> Fmt.string ppf "&Abar;"
      | s   -> Fmt.string ppf s)];
  def "--" [Print "&ndash;"];
  def "---" [Print "&mdash;"];
  ()

(*s Macros for German BibTeX style. *)

let is_german_style = function
  | "gerabbrv" | "geralpha" | "gerapali" | "gerplain" | "gerunsrt" -> true
  | _ -> false

let init_style_macros st =
  if is_german_style st then begin
    List.iter (fun (m,s) -> def m [ Print s; Print_arg ])
      [ "\\btxetalshort", "et al" ;
        "\\btxeditorshort", "Hrsg";
        "\\Btxeditorshort", "Hrsg";
        "\\btxeditorsshort", "Hrsg";
        "\\Btxeditorsshort", "Hrsg";
        "\\btxvolumeshort", "Bd";
        "\\Btxvolumeshort", "Bd";
        "\\btxnumbershort", "Nr";
        "\\Btxnumbershort", "Nr";
        "\\btxeditionshort", "Aufl";
        "\\Btxeditionshort", "Aufl";
        "\\btxchaptershort", "Kap";
        "\\Btxchaptershort", "Kap";
        "\\btxpageshort", "S";
        "\\Btxpageshort", "S";
        "\\btxpagesshort", "S";
        "\\Btxpagesshort", "S";
        "\\btxtechrepshort", "Techn. Ber";
        "\\Btxtechrepshort", "Techn. Ber";
        "\\btxmonjanshort", "Jan";
        "\\btxmonfebshort", "Feb";
        "\\btxmonaprshort", "Apr";
        "\\btxmonaugshort", "Aug";
        "\\btxmonsepshort", "Sep";
        "\\btxmonoctshort", "Okt";
        "\\btxmonnovshort", "Nov";
        "\\btxmondecshort", "Dez";
      ];
    List.iter (fun (m,s) -> def m [ Skip_arg; Print s])
      [ "\\btxetallong", "et alii";
        "\\btxandshort", "und";
        "\\btxandlong", "und";
        "\\btxinlong", "in:";
        "\\btxinshort", "in:";
        "\\btxofseriesshort", "d. Reihe";
        "\\btxinseriesshort", "in";
        "\\btxofserieslong", "der Reihe";
        "\\btxinserieslong", "in";
        "\\btxeditorlong", "Herausgeber";
        "\\Btxeditorlong", "Herausgeber";
        "\\btxeditorslong", "Herausgeber";
        "\\Btxeditorslong", "Herausgeber";
        "\\btxvolumelong", "Band";
        "\\Btxvolumelong", "Band";
        "\\btxnumberlong", "Nummer";
        "\\Btxnumberlong", "Nummer";
        "\\btxeditionlong", "Auflage";
        "\\Btxeditionlong", "Auflage";
        "\\btxchapterlong", "Kapitel";
        "\\Btxchapterlong", "Kapitel";
        "\\btxpagelong", "Seite";
        "\\Btxpagelong", "Seite";
        "\\btxpageslong", "Seiten";
        "\\Btxpageslong", "Seiten";
        "\\btxmastthesis", "Diplomarbeit";
        "\\btxphdthesis", "Doktorarbeit";
        "\\btxtechreplong", "Technischer Bericht";
        "\\Btxtechreplong", "Technischer Bericht";
        "\\btxmonjanlong", "Januar";
        "\\btxmonfeblong", "Februar";
        "\\btxmonmarlong", "März";
        "\\btxmonaprlong", "April";
        "\\btxmonmaylong", "Mai";
        "\\btxmonjunlong", "Juni";
        "\\btxmonjullong", "Juli";
        "\\btxmonauglong", "August";
        "\\btxmonseplong", "September";
        "\\btxmonoctlong", "Oktober";
        "\\btxmonnovlong", "November";
        "\\btxmondeclong", "Dezember";
        "\\btxmonmarshort", "März";
        "\\btxmonmayshort", "Mai";
        "\\btxmonjunshort", "Juni";
        "\\btxmonjulshort", "Juli";
        "\\Btxinlong", "In:";
        "\\Btxinshort", "In:";
      ]
  end
