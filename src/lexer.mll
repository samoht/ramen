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
  | "{{"    { t.mode <- `Program; data t }
  | eof     { eof t }
  | newline { add_newline t lexbuf; text t lexbuf }
  | _ as c  { add_data t c; text t lexbuf }

and program t = parse
  | "}}"     { t.mode <- `Text; text t lexbuf }
  | white    { program t lexbuf }
  | newline  { Lexing.new_line lexbuf; program t lexbuf }
  | '.'      { DOT }
  | "for"    { FOR }
  | "endfor" { ENDFOR }
  | "if"     { IF }
  | "elif"   { ELIF }
  | "else"   { ELSE }
  | "endif"  { ENDIF }
  | "&&"     { AND }
  | ":"      { COLON }
  | ","      { COMMA }
  | "="      { EQ }
  | "!"      { BANG }
  | "!="     { NEQ }
  | "in"     { IN }
  | "|"      { PIPE }
  | "-"      { MINUS }
  | "["      { LBRA }
  | "]"      { RBRA }
  | "("      { LPAR }
  | ")"      { RPAR }
  | var      { let v = Lexing.lexeme lexbuf in p t "VAR %S" v; VAR v }
  | eof      { unclosed_tag () }

{

let token t lexbuf =
  match t.mode with
  | `Text    -> text t lexbuf
  | `Program -> program t lexbuf
  | `Eof     -> EOF

}
