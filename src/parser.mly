%{
open Ast
%}

%token <string> VAR DATA
%token DOT
%token COLON COMMA
%token FOR IN DO DONE REV SORT
%token IF ELIF ELSE FI
%token BANG
%token AND
%token OR
%token EQ NEQ
%token LBRA RBRA
%token LPAR RPAR
%token EOF

%left OR
%left AND
%left BANG

%start main
%type <Ast.t> main

%%

main:
  | exprs EOF { $1 }

expr:
  | var                           { Var $1 }
  | DATA                          { Text $1 }
  | IF LPAR test RPAR exprs elif  { If { if_=$3; then_=$5; else_= $6 } }
  | FOR VAR IN iter DO exprs DONE { For { for_=$2; in_=$4; do_=$6 } }

elif:
  | ELSE exprs FI                  { Some $2 }
  | ELIF LPAR test RPAR exprs elif { Some (If { if_=$3; then_=$5; else_=$6 }) }
  | FI                             { None }

test:
  | var                        { Def $1 }
  | LPAR test RPAR             { Paren $2 }
  | BANG test                  { Neg $2 }
  | var_or_text op var_or_text { Op ($1, $2, $3) }
  | test AND test              { And ($1, $3) }
  | test OR test               { Or ($1, $3) }

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

iter:
  | var                           { Base $1 }
  | REV iter                      { Rev $2 }
  | SORT LPAR iter COMMA VAR RPAR { Sort ($3, $5) }

exprs:
  | list(expr) { Seq $1 }
