%{

#include <stdlib.h>
#include <stdio.h>
#include "utils/bitree.h"

%}
 
%union { int i; char *s; struct nodeTree *tn;}
 
%token<i> INT
%token<s> ID
%token TMENOS
%token TINT TBOOL TTRUE TFALSE
%token RETURN

%type<tn> VALUE expr decl stmt stmts decls prog
%type<i> type

%left '+' TMENOS 
%left '*'

 
%%
prog: decls stmts {  
                    infoT root = {0, 0, None, PROG, NULL};
                    infoT rootLeft = {0, 0, None, DECLS, NULL};
                    infoT rootRight = {0, 0, None, STMTS, NULL};
                    nodeT* left = newTree(rootLeft, $1, NULL);
                    nodeT* right = newTree(rootRight, NULL, $2);
                    $$ = newTree(root, left, right); 
                    printInOrderTree($$, 0); 
                };   

stmts: stmt RETURN expr ';'{ 
                            infoT root = {0, 0, None, SEMICOLON, NULL};
                            infoT rootRight = {0, 0, None, RET, NULL};
                            nodeT* right = newTree(rootRight, NULL, $3);
                            $$ = newTree(root, $1, right); 
                        }

    | stmt stmts {
                    infoT root = {0, 0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    ;

stmt: ID '=' expr ';' {
                        infoT root = {0, 0, None, STMT, NULL};
                        infoT rootLeft = {0, 0, None, NONE, $1};
                        nodeT* left = newNode(rootLeft);
                        $$ = newTree(root, left, $3); 
                    } 
    ;

decls: decl { $$ = $1;}
    | decl decls {
                    infoT root = {0, 0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    ;

decl: type ID '=' expr ';'{
                            infoT root = {0, 0, None, DECL, NULL};
                            infoT rootLeft = {0, 0, $1, NONE, $2};
                            nodeT* left = newNode(rootLeft);
                            $$ = newTree(root, left, $4); 
                        } 
    ;
  
type: TINT    {$$ = Int;}
    | TBOOL   {$$ = Bool;}
    ;

expr: VALUE               

    | expr '+' expr {   
                        infoT root = {0, 0, None, SUM, NULL}; 
                        $$ = newTree(root, $1, $3);
                    }

    | expr '*' expr {   
                        infoT root = {0, 0, None, MULT, NULL}; 
                        $$ = newTree(root, $1, $3);
                    }

    | expr TMENOS expr {   
                        infoT root = {0, 0, None, REST, NULL}; 
                        $$ = newTree(root, $1, $3);
                    }    

    | '(' expr ')' { $$ = $2;}

    | ID {
        infoT root = {0, 0, None, NONE, $1}; 
        $$ = newNode(root);
    }
    ;

VALUE : INT {
        infoT root = {$1, 0, Int, NONE, NULL}; 
        $$ = newNode(root);
    }
| TTRUE {
        infoT root = {1, 0, Bool, NONE, NULL};
        $$ = newNode(root);
    }
| TFALSE { 
        infoT root = {0, 0, Bool, NONE, NULL};
        $$ = newNode(root);
    }
;

 
%%