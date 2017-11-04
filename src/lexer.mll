{
open Parser

type t = {
  debug       : bool;
  mutable mode: [`Text | `Program | `Eof];
  buffer      : Buffer.t
}

let v ?(debug=false) () = { debug; mode = `Text; buffer = Buffer.create 8196 }
let p t fmt = Fmt.kstrf (fun s -> if t.debug then print_endline s) fmt

let data t = match t.mode with
  | `Eof -> EOF
  | _    ->
    let str = Buffer.contents t.buffer in
    Buffer.reset t.buffer;
    p t "DATA %s" str;
    DATA str

let eof t =
  p t "EOF";
  match t.mode with
  | `Eof -> EOF
  | _    ->
    let data = data t in
    t.mode <- `Eof;
    data

let add_data t c =
  p t "adding %c" c;
  Buffer.add_char t.buffer c

let add_newline t l =
  Lexing.new_line l;
  let str = Lexing.lexeme l in
  for i = 0 to String.length str - 1 do
    add_data t str.[i]
  done

let check_newlines l =
  let s = Lexing.lexeme l in
  for i=0 to String.length s - 1 do
    if s.[i] = '\n' then Lexing.new_line l
  done

exception Error of string
let syntax_error s = raise (Error s)

exception Unclosed_tag
let unclosed_tag () = raise Unclosed_tag
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let var = (alpha | digit | '-' | '_')+
let newline = '\r' | '\n' | "\r\n"
let white = [' ' '\t']+

rule text t = parse
  | (white* newline white*)? "{{" {
      check_newlines lexbuf;
      t.mode <- `Program; data t }
  | eof     { eof t }
  | newline { add_newline t lexbuf; text t lexbuf }
  | _ as c  { add_data t c; text t lexbuf }

and program t = parse
  | "}}"     { t.mode <- `Text; text t lexbuf }
  | white    { program t lexbuf }
  | newline  { Lexing.new_line lexbuf; program t lexbuf }
  | '\''     { string t lexbuf }
  | '.'      { DOT }
  | "for"    { FOR }
  | "in"     { IN }
  | "do"     { DO }
  | "done"   { DONE }
  | "if"     { IF }
  | "elif"   { ELIF }
  | "else"   { ELSE }
  | "fi"     { FI }
  | "&&"     { AND }
  | "||"     { OR }
  | ":"      { COLON }
  | ","      { COMMA }
  | "="      { EQ }
  | "!"      { BANG }
  | "!="     { NEQ }
  | "["      { LBRA }
  | "]"      { RBRA }
  | "("      { LPAR }
  | ")"      { RPAR }
  | "sort"   { SORT }
  | "rev"    { REV }
  | var      { let v = Lexing.lexeme lexbuf in p t "VAR %S" v; VAR v }
  | eof      { unclosed_tag () }

and string t = parse
  | '\''    { data t }
  | newline { add_newline t lexbuf; string t lexbuf }
  | _ as c  { add_data t c; string t lexbuf }

{

let token t lexbuf =
  match t.mode with
  | `Text    -> text t lexbuf
  | `Program -> program t lexbuf
  | `Eof     -> EOF

}
