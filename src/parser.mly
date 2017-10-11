%{
open Ast
%}

%token <string> VAR DATA
%token FOR IN ENDFOR PIPE
%token EOF

%start main
%type <Ast.t> main

%%

main:
  | exprs EOF { $1 }

expr:
  | VAR  { Var $1 }
  | DATA { Data $1 }
  | FOR VAR IN VAR PIPE VAR exprs ENDFOR
         { For { var=$2; map=$4; order=Some $6; body=$7 } }
  | FOR VAR IN VAR exprs ENDFOR
         { For { var=$2; map=$4; order=None; body=$5 } }

exprs:
  | list(expr) { Seq $1 }
