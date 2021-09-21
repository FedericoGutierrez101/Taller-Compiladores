#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define COUNT 15

const char* TLabelString[] = {"NONE", "DECL", "STMT", "SUM", "MULT", "REST", "SEMICOLON", "PROG", "RET", "DECLS", "STMTS","FUNC", "CONST", "VAR"};

enum TLabel {NONE, DECL, STMT, SUM, MULT, REST, SEMICOLON, PROG, RET, DECLS, STMTS, FUNC, CONST, VAR};

const char* TTypeString[] = {"None", "Int", "Bool"};

enum TType {None, Int, Bool};

typedef struct infoToken {
    int value;
    enum TType type;
    enum TLabel label;
    char* name;
} infoT;

typedef struct node {
    infoT info;
    struct node * next;
} nodeSt;

typedef struct nodeTree {
    infoT atr;
    nodeSt* st;
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

nodeT* newTreeSt(infoT newatr, nodeT *newleft, nodeT *newright, nodeSt* newst){
    nodeT *arbol = (nodeT*) malloc(sizeof(nodeT));
    arbol->atr = newatr;
    arbol->left = newleft;    
    arbol->right = newright;
    arbol->st = newst;
    return arbol;
}

nodeT* newNode(infoT newatr){
    nodeT *arbol = (nodeT*) malloc(sizeof(nodeT));
    arbol->atr = newatr;
    arbol->left = NULL;    
    arbol->right = NULL;
    return arbol;
}

nodeSt* newNodeSt(infoT newinfo, nodeSt* newnext){
    nodeSt *node = (nodeSt*) malloc(sizeof(nodeSt));
    node->info = newinfo;
    node->next = newnext;
    return node;
}

void printfNode(infoT atr){
	printf("[V:%d, T:%s, V:%s, name:%s]\n\n", atr.value, TTypeString[atr.type], TLabelString[atr.label], atr.name);
}

void printInOrderTree(nodeT *nodeTree, int space) {
	if(nodeTree==NULL)
		return;
    space += COUNT;

	printInOrderTree(nodeTree->right, space);
	for (int i = COUNT; i < space; i++)
		printf(" ");
	printfNode(nodeTree->atr);
    if (nodeTree->st != NULL) {
        for (int i = COUNT; i < space; i++)
		printf(" ");
        printf("esete:");
        printfNode(nodeTree->st->info);
    }
	printInOrderTree(nodeTree->left, space);
} 

void printList(nodeSt *list) {
	if (list == NULL) return;
    nodeSt* nlist = list;
    while (nlist!=NULL) {
        printfNode(nlist->info);
        nlist = nlist->next;
    }
} 

nodeSt* insertList(nodeSt* list, nodeSt* element)
{
    if (list == NULL) {
        list = newNodeSt(element->info, NULL);

    } else {
        nodeSt* nlist = list;
        while(nlist->next != NULL) {
            nlist = nlist->next;
        }
        nlist->next=element;
    }
    return list;
}

nodeSt* find(char* name, nodeSt* st){
    nodeSt* newst = st;
    while(newst != NULL) {
        if (newst->info.name != NULL && strcmp(newst->info.name, name) == 0)
            return newst;
        newst = newst->next;
    }
    return newst;
}

void printSt(nodeSt* node){
    if (node == NULL) return;
    printfNode(node->info);
    printSt(node->next);
}

enum TType checkTypes(nodeT* nodeTree){
    if (nodeTree == NULL) return None; 
    if (nodeTree->atr.label == VAR || nodeTree->atr.label == CONST)
        return nodeTree->st->info.type;
    if (nodeTree->atr.label == FUNC && nodeTree->atr.type == None){
        nodeTree->st->info.type = checkTypes(nodeTree->left);
        if (nodeTree->st->info.type != checkTypes(nodeTree->right)){
            return None; 
        } else {
            return nodeTree->st->info.type;
        }
    }
    return None;
}

// Demo de como verificaria la valides de el codigo
void checkValidation(nodeT *nodeTree){
    if (nodeTree == NULL) return; 
    if (nodeTree->atr.label==STMT || nodeTree->atr.label==DECL){
        if (checkTypes(nodeTree->left) != checkTypes(nodeTree->right)){
            printf("tipos incompatibles");
        }
    } 
    checkValidation(nodeTree->left);
    checkValidation(nodeTree->right);
}
