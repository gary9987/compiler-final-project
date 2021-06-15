// symtab.c
#include "symtab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void yyerror(char *msg){
	fprintf(stderr, "%s\n", msg);
	exit(1);
}


int lookSym(char *s){
	for(int i=0; i<NSYMS; ++i){
		// found
		if( !strcmp(symtab[i].name, s)){
			return i;
		}
		// free
		if( !strcmp(symtab[i].name, "") ){
			return i;
		}
	}
    //printf("%s", s);
	yyerror("Too many symbols");
	exit(1);	/* cannot continue */
}

void insertSym(char *name, int type){
	int ind = lookSym(name);
    symtab[ind].type = type;
    strcpy(symtab[ind].name, name);
    printf("Insert %s %d\n", name, type);
}

void printSym(){
    for(int i=0; i<NSYMS; ++i){
		// found
		if(strcmp(symtab[i].name, "")){
            //int
            if(symtab[i].type == 1)
			    printf("Var: %s, Value: %f, Type1: %d\n", symtab[i].name, symtab[i].value, symtab[i].type);
            // double
            if(symtab[i].type == 2)
			    printf("Var: %s, Value: %f, Type2: %d\n", symtab[i].name, symtab[i].value, symtab[i].type);
		}
	}
}

float getValue(char *name){
    int ind = lookSym(name);
    return symtab[ind].value;
}

int getType(char *name){
    int ind = lookSym(name);
    return symtab[ind].type;
}

void assignSym(char *name, float val){
    //printf("%s\n", name);
    int ind = lookSym(name);
    //printf("ssfagragrag %d\n",ind);
    symtab[ind].value = val;
}