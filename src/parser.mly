%{
open Ast
%}

%token <string> VAR DATA
%token FOR IN ENDFOR PIPE MINUS
%token IF ENDIF
%token EOF

%start main
%type <Ast.t> main

%%

main:
  | exprs EOF { $1 }

expr:
  | VAR  { Var $1 }
  | DATA { Data $1 }
  | IF VAR exprs ENDIF { If { test=$2; then_=$3 } }
  | FOR VAR IN VAR ordering exprs ENDFOR
         { For { var=$2; map=$4; order=$5; body=$6 } }

ordering:
  |                { None }
  | PIPE VAR       { Some (`Up  , $2) }
  | PIPE MINUS VAR { Some (`Down, $3) }

exprs:
  | list(expr) { Seq $1 }
