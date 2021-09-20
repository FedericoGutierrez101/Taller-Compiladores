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
	printInOrderTree(nodeTree->left, space);
} 

void symbolTableInOrder(nodeT* nodeTree, nodeSt* st) {
    if (nodeTree==NULL) return;
    //nodeSt* newSt = newNodeSt(nodeTree->atr, NULL);
    st = newNodeSt(nodeTree->atr, NULL);
    nodeTree->st = st;
    //st->next = newSt;
    symbolTableInOrder(nodeTree->left, st->next);
    //printfNode(newSt->info);
    symbolTableInOrder(nodeTree->right, st->next);
} 

void insertList(nodeSt* list, nodeSt* element)
{
    if (list == NULL) {
        printf("retorna lis = elementoooooooooooooooooooooooooooooo\n");
        list = element;
    } else {
        while(list->next != NULL) {
            list = list->next;
        }
        list->next=element;
    }
}








nodeSt* checkIfExist(char* name, nodeSt* st){
    if (st==NULL) return NULL;
    nodeSt* newst = st;
    printf("asdasdaasdasaaaaaaaaasdasdaasdasaaaaaaaaasdasdaasdasaaaaaaaaasdasdaasdasaaaaaaaaasdasdaasdasaaaaaaaad");
    while(newst != NULL) {
        printf("original name: %s, st name: %s", name, newst->info.name);
        if (strcmp(newst->info.name, name)==0)
            return newst;
        newst = newst->next;
    }
    return NULL;
}

// Chequear la lista hasta llegar a la etiqueta prog para verificar que la variable no se haya declarado antes
int checkNoRedeclaration(char* name, nodeSt* st, int count){
    if (st==NULL)
        return 1;
    if (count > 1)
        return 0;
    if (st->info.name==name)
        count = count + 1; 
    return checkNoRedeclaration(name, st->next, count+1);
}

// Chequear la lista hasta llegar a la etiqueta prog para verificar que la variable se haya declarado antes
int checkDeclaration(char* name, nodeSt* st){
    if (name==NULL || st == NULL) return 0;
    if (st->info.name==name){
        printf("variable declarada");
        return 1;
    }
    return checkDeclaration(name, st->next);
}

// Asigna el tipo decladarado a las variables en el stmt
int putType(nodeT* nodeTree, nodeSt* st){
    if (st->info.label==DECLS){
        printf("variable: '%s' no declarada",nodeTree->atr.name);
        return 0;
    }
    if (st->info.name==nodeTree->atr.name){
        nodeTree->atr.type = st->info.type;
        return 1;
    }
    return putType(nodeTree, st->next);
}

// En una funcion (=,*,+) verificar que ambos lados tengan el mismo tipo
int checkFuncTypes(nodeT* nodeTree, nodeSt* st){
    if (nodeTree->left->atr.label!=FUNC && nodeTree->left->atr.type==None){
        putType(nodeTree->left, st);
    } else if (nodeTree->left->atr.label==FUNC){
        checkFuncTypes(nodeTree->left, st);
    }
    if (nodeTree->right->atr.label!=FUNC && nodeTree->right->atr.type==None){
        putType(nodeTree->right, st);
    } else if (nodeTree->right->atr.label==FUNC){
        checkFuncTypes(nodeTree->right, st);
    }
    if (nodeTree->left->atr.type != nodeTree->right->atr.type){
        return 0;
    } else {
        nodeTree->atr.type = nodeTree->left->atr.type;
        return 1;
    }
}

void printSt(nodeSt* node){
    if (node == NULL) return;
    printfNode(node->info);
    printSt(node->next);
}

// Demo de como verificaria la valides de el codigo
void checkValidation(nodeT *nodeTree, nodeSt* st){
    if (nodeTree == NULL) return; 
    if (nodeTree->atr.label==STMT){
        checkDeclaration(nodeTree->left->atr.name, st);
    } /*else if(nodeTree->atr.label==DECL){
        checkNoRedeclaration(nodeTree->left->atr.name, st, 0);
    } else if(nodeTree->atr.label==FUNC){
        checkFuncTypes(nodeTree, st);
    }*/
    checkValidation(nodeTree->left, st);
    checkValidation(nodeTree->right, st);
}


