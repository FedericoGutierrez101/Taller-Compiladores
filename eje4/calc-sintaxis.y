%{

#include <stdlib.h>
#include <stdio.h>
#include "utils/bitree.h"

int yylex();
int yyerror(char *);

infoT info= {0, None, PROG, "symboltable"};
nodeSt* symboltable;

%}
 
%union { int i; char *s; struct nodeTree *tn;}
 
%token<i> INT
%token<s> ID
%token TINT TBOOL TTRUE TFALSE
%token RETURN

%type<tn> VALUE expr decl stmt stmts decls prog
%type<i> type

%left '+'  
%left '*'

 
%%
prog: decls stmts { 
                    infoT root = {0, None, PROG, NULL};
                    infoT rootLeft = {0, None, DECLS, NULL};
                    infoT rootRight = {0, None, STMTS, NULL};
                    nodeT* left = newTree(rootLeft, $1, NULL);
                    nodeT* right = newTree(rootRight, NULL, $2);
                    $$ = newTree(root, left, right); 
                    printList(symboltable);
                    printInOrderTree($$, 0); 
                };   

stmts: stmt RETURN expr ';'{ 
                            infoT root = {0, None, SEMICOLON, NULL};
                            infoT rootRight = {0, None, RET, NULL};
                            nodeT* right = newTree(rootRight, NULL, $3);
                            $$ = newTree(root, $1, right); 
                        }

    | stmt stmts {
                    infoT root = {0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    ;

stmt: ID '=' expr ';' {
                        infoT root = {0, None, STMT, NULL};
                        infoT rootLeft = {0, None, VAR, $1};
                        nodeSt* stleft = find($1, symboltable); 
                        if (stleft == NULL){
                            printf("la variable: %s no existe\n", $1);
                        }
                        nodeT* left = newNode(rootLeft);
                        left->st = stleft;
                        $$ = newTree(root, left, $3); 
                    } 
    ;

decls: decl { $$ = $1;}
    | decl decls {
                    infoT root = {0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    ;

decl: type ID '=' expr ';'{
                            infoT root = {0, None, DECL, NULL};
                            //infoT rootLeft = {0, $1, VAR, $2};
                            infoT rootLeft = {$4->atr.value, $1, VAR, $2};
                            nodeSt* stleft = find($2, symboltable);
                            if (stleft == NULL){
                                stleft = newNodeSt(rootLeft, NULL); 
                                insertList(symboltable, stleft);
                            } else {
                                printf("la variable: %s ya esta declarada", stleft->info.name);
                            }
                            nodeT* left = newNode(rootLeft);
                            left->st = stleft; 
                            $$ = newTree(root, left, $4); 
                        } 
    ;
  
type: TINT    {$$ = Int;}
    | TBOOL   {$$ = Bool;}
    ;

expr: VALUE               

    | expr '+' expr {   
                        infoT root = {0, None, FUNC, NULL}; 
                        nodeSt* st = newNodeSt(root, NULL); 
                        symboltable = insertList(symboltable, st);
                        $$ = newTreeSt(root, $1, $3, st);
                    }

    | expr '*' expr {   
                        infoT root = {0, None, FUNC, NULL}; 
                        nodeSt* st = newNodeSt(root, NULL); 
                        symboltable = insertList(symboltable, st);
                        $$ = newTreeSt(root, $1, $3, st);
                    }   

    | '(' expr ')' { $$ = $2;}

    | ID {
        infoT root = {0, None, VAR, $1}; 
        nodeSt* st = find($1, symboltable); 
        if (st==NULL) printf("la variable: %s no existe\n", $1);
        $$ = newNode(root);
        $$->st = st;
    }
    ;

VALUE : INT {
        infoT root = {$1, Int, CONST, NULL};
        nodeSt* st = newNodeSt(root, NULL); 
        symboltable = insertList(symboltable, st);
        $$ = newNode(root);
        $$->st = st;
    }
| TTRUE {
        infoT root = {1, Bool, CONST, NULL};
        nodeSt* st = newNodeSt(root, NULL); 
        symboltable = insertList(symboltable, st);
        $$ = newNode(root);
        $$->st = st;
    }
| TFALSE { 
        infoT root = {0, Bool, CONST, NULL};
        nodeSt* st = newNodeSt(root, NULL); 
        symboltable = insertList(symboltable, st);
        $$ = newNode(root);
        $$->st = st;
    }
;

 
%%