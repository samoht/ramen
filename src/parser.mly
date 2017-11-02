%{
open Ast
%}

%token <string> VAR DATA
%token DOT
%token COLON COMMA
%token FOR IN ENDFOR PIPE MINUS
%token IF ELIF ENDIF ELSE
%token BANG
%token AND
%token OR
%token EQ NEQ
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
  | DATA               { Text $1 }
  | IF test exprs elif { If { test=$2; then_=$3; else_= $4 } }
  | FOR VAR IN var ordering exprs ENDFOR
                       { For { var=$2; map=$4; order=$5; body=$6 } }

elif:
  | ELIF test exprs elif { Some { test=$2; then_=$3; else_= $4 } }
  | ELSE exprs ENDIF     { Some { test=True; then_=$2; else_=None } }
  | ENDIF                { None }

test:
  | var                                   { Def $1 }
  | BANG test                             { Neg $2 }
  | LPAR var_or_text op var_or_text RPAR  { Op ($2, $3, $4) }
  | test AND test                         { And ($1, $3) }
  | test OR test                          { Or ($1, $3) }

var_or_text:
  | var  { `Var $1 }
  | DATA { `Text $1 }

op:
  | EQ  { `Eq }
  | NEQ { `Neq }

var:
  | separated_nonempty_list(DOT, id) { $1 }

param:
  | VAR COLON var { ($1, `Var $3) }

params:
  | separated_nonempty_list(COMMA, param) { $1 }

id:
  | VAR                  { Id $1 }
  | VAR LPAR params RPAR { App ($1, $3) }
  | LBRA var RBRA        { Get $2 }

ordering:
  |                { None }
  | PIPE VAR       { Some (`Up  , $2) }
  | PIPE MINUS VAR { Some (`Down, $3) }

exprs:
  | list(expr) { Seq $1 }
