// symtab.h

#define NSYMS 100	/* maximum number of symbols */

struct symtab_struct {
    char name[50];
	int type;
	float (*funcptr)();
	float value;
	
} symtab[NSYMS];

int lookSym(char *s);
float getValue(char *name);
int getType(char *name);
void insertSym(char *name, int type);
void printSym();
void assignSym(char *name, float val);

void yyerror(char *msg);