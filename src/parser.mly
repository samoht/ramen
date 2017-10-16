%{
open Ast
%}

%token <string> VAR DATA
%token DOT
%token FOR IN ENDFOR PIPE MINUS
%token IF ELIF ENDIF
%token AND
%token LBRA RBRA
%token EOF

%start main
%type <Ast.t> main

%%

main:
  | exprs EOF { $1 }

expr:
  | var                { Var $1 }
  | DATA               { Data $1 }
  | IF cond exprs elif { If { test=$2; then_=$3; else_= $4 } }
  | FOR VAR IN var ordering exprs ENDFOR
                       { For { var=$2; map=$4; order=$5; body=$6 } }

elif:
  | ELIF cond exprs elif { Some { test=$2; then_=$3; else_= $4 } }
  | ENDIF                { None }

cond:
  | separated_nonempty_list(AND, var) { $1 }

var:
  | separated_nonempty_list(DOT, id) { $1 }

id:
  | VAR           { Id $1 }
  | LBRA var RBRA { Get $2 }

ordering:
  |                { None }
  | PIPE VAR       { Some (`Up  , $2) }
  | PIPE MINUS VAR { Some (`Down, $3) }

exprs:
  | list(expr) { Seq $1 }
