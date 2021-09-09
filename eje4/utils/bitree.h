#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define COUNT 15

const char* TLabelString[] = {"NONE", "DECL", "STMT", "SUM", "MULT", "REST", "SEMICOLON", "PROG", "RET", "DECLS", "STMTS"};

enum TLabel {NONE, DECL, STMT, SUM, MULT, REST, SEMICOLON, PROG, RET, DECLS, STMTS};

const char* TTypeString[] = {"None", "Int", "Bool"};

enum TType {None, Int, Bool};

typedef struct infoToken {
    int value;
    int line;
    enum TType type;
    enum TLabel label;
    char* text;
} infoT;

typedef struct nodeTree {
    infoT atr;
    struct nodeTree* left;
    struct nodeTree* right;
} nodeT;

nodeT* newTree(infoT newatr, nodeT *newleft, nodeT *newright){
    nodeT *arbol = (nodeT*) malloc(sizeof(nodeT));
    arbol->atr = newatr;
    arbol->left = newleft;    
    arbol->right = newright;
    return arbol;
}

nodeT* newNode(infoT newatr){
    nodeT *arbol = (nodeT*) malloc(sizeof(nodeT));
    arbol->atr = newatr;
    arbol->left = NULL;    
    arbol->right = NULL;
    return arbol;
}


void printfNode(infoT atr){
	printf("[V:%d, Ln:%d, T:%s, V:%s, txt:%s]\n\n", atr.value, atr.line, TTypeString[atr.type], TLabelString[atr.label], atr.text);
}

void printInOrderTree(nodeT *nodeTree, int space) {

	if(nodeTree==NULL)
		return;
    space += COUNT;

	printInOrderTree(nodeTree->right, space);
	for (int i = COUNT; i < space; i++)
		printf(" ");
	printfNode(nodeTree->atr);
	printInOrderTree(nodeTree->left, space);

} 