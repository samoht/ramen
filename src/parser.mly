%{
open Ast
%}

%token <string> VAR DATA
%token DOT
%token FOR IN ENDFOR PIPE MINUS
%token IF ELIF ENDIF
%token AND EQ NEQ BANG
%token LBRA RBRA
%token LPAR RPAR
%token EOF

%start main
%type <Ast.t> main

%%

main:
  | exprs EOF { $1 }

expr:
  | var                { Var $1 }
  | DATA               { Data $1 }
  | IF test exprs elif { If { test=$2; then_=$3; else_= $4 } }
  | FOR VAR IN var ordering exprs ENDFOR
                       { For { var=$2; map=$4; order=$5; body=$6 } }

elif:
  | ELIF test exprs elif { Some { test=$2; then_=$3; else_= $4 } }
  | ENDIF                { None }

cond:
  | var                   { Def $1 }
  | BANG var              { Ndef $2 }
  | LPAR var EQ var RPAR  { Eq (`Var $2, `Var $4) }
  | LPAR var NEQ var RPAR { Neq (`Var $2, `Var $4) }

test:
  | separated_nonempty_list(AND, cond) { $1 }

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
