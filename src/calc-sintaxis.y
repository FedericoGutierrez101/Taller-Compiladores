%{

#include <stdlib.h>
#include <stdio.h>
#include "utils/bitree.h"

int yylex();
int yyerror(char *);

nodeSt* symboltable;

%}
 
%union { int i; char *s; struct nodeTree *tn;}
 
%token<i> INT TTRUE TFALSE
%token<s> ID 
%token TINT TBOOL 
%token RETURN

%type<tn> VALUE expr decl stmt stmts decls prog return returns
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
                    //printList(symboltable);
                    //printInOrderTree($$, 0);
                    checkValidation($$); 
                }
    | decls {
                infoT root = {0, None, PROG, NULL};
                infoT rootLeft = {0, None, DECLS, NULL};
                nodeT* left = newTree(rootLeft, $1, NULL);
                $$ = newTree(root, left, NULL); 
                //printList(symboltable);
                //printInOrderTree($$, 0);
                checkValidation($$); 
            }
    ;   

stmts: stmt { $$ = $1;}
    | stmt returns { 
                        infoT root = {0, None, SEMICOLON, NULL};
                        $$ = newTree(root, $1, $2); 
                    }

    | stmt stmts {
                    infoT root = {0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }

    | stmt returns stmts {   infoT root = {0, None, SEMICOLON, NULL};
                            infoT rootLeft = {0, None, STMT, NULL};
                            nodeT* left = newTree(rootLeft, NULL, $2);
                            $$ = newTree(root, left, $3);
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
                        stleft->info.value = $3->st->info.value;
                        left->st = stleft;
                        $$ = newTree(root, left, $3); 
                    } 
    ;

decls: decl { $$ = $1;}
    | decl decls {
                    infoT root = {0, None, SEMICOLON, NULL};
                    $$ = newTree(root, $1, $2); 
                }
    
    | decl returns decls {   infoT root = {0, None, SEMICOLON, NULL};
                            nodeT* left = newTree(root, $1, $2);
                            $$ = newTree(root, left, $3);
                        }

    | decl returns   {   infoT root = {0, None, SEMICOLON, NULL};
                        $$ = newTree(root, $1, $2); 
                    }
    ;

decl: type ID '=' expr ';'{
                            infoT root = {0, None, DECL, NULL};
                            infoT rootLeft = {$4->st->info.value, $1, VAR, $2};
                            nodeSt* stleft = find($2, symboltable);
                            if (stleft == NULL){
                                stleft = newNodeSt(rootLeft, NULL); 
                                insertList(symboltable, stleft);
                            } else {
                                printf("la variable: %s ya esta declarada", stleft->info.name);
                                exit(1);
                            }
                            nodeT* left = newNode(rootLeft);
                            left->st = stleft; 
                            $$ = newTree(root, left, $4); 
                        } 
    ;

returns: return { $$ = $1;}

    | return returns {  infoT root = {0, None, SEMICOLON, NULL};
                        $$ = newTree(root, $1, $2); 
                    }
    ;


return: RETURN expr ';' {   infoT root = {0, None, RET, NULL};
                            $$ = newTree(root, NULL, $2);
                        }
    ;

type: TINT    {$$ = Int;}
    | TBOOL   {$$ = Bool;}
    ;

expr: VALUE               

    | expr '+' expr {   
                        infoT root = {($1->st->info.value + $3->st->info.value), None, FUNC, NULL}; 
                        nodeSt* st = newNodeSt(root, NULL); 
                        symboltable = insertList(symboltable, st);
                        $$ = newTreeSt(root, $1, $3, st);
                    }

    | expr '*' expr {   
                        infoT root = {($1->st->info.value * $3->st->info.value), None, FUNC, NULL}; 
                        nodeSt* st = newNodeSt(root, NULL); 
                        symboltable = insertList(symboltable, st);
                        $$ = newTreeSt(root, $1, $3, st);
                    }   

    | '(' expr ')' { $$ = $2;}

    | ID {
        infoT root = {0, None, VAR, $1}; 
        nodeSt* st = find($1, symboltable); 
        if (st==NULL){
            printf("La variable: %s no esta declarada\n", $1);
            exit(1);
        } 
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