%union{
	float f;
	int dec;
	char str[100];
	int type;
	struct symtab_struct *symp;
	char* constchar;
}

%token PROGRAM Begin END DECLARE AS IF THEN ELSE ENDIF Assign_Op PRINT WHILE ENDWHILE FOR TO ENDFOR STEP DOWNTO
%token L_OP LE_OP EQ_OP NE_OP S_OP SE_OP
%token <str> VarName
%token <type> TYPE
%token <dec> NUMBER
%token <str> FNUMBER
%type <symp> E T F Expr
%type <constchar> ConOp FOR_Step FOR_To

%{	
	#define MAX_LENGTH 100
	#include "symtab.h"
	#include "stack.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>

	extern int yylex();
	// ================ var ======================
	FILE *fp;
	char var_name[MAX_LENGTH][MAX_LENGTH] = {};
	char buf[MAX_LENGTH];
	int tmp_var_count = 1;
	int label_count = 1;
	int global_type = 1;
	// ================ function =================
	void declare(char* buf, int type);
	void inserVarName(char *name);
	void yyerror(char *msg);
	void assignToASM(char *name, char* value);
	struct symtab_struct *creatTmp(int type);
	void tmpVarToASM();

%}

%%
Start: PROGRAM VarName 
	   {
		   fprintf(fp,"START %s\n", $2);
	   } 
	   Begin Stmt_List END 
	   {
		   printSym();
		   fprintf(fp,"HALT %s\n", $2);
		   tmpVarToASM();
	   }
	 ; 

Stmt_List: Stmt
		 | Stmt_List Stmt 
		 ;

Stmt: DECLARE_Stmt
	| IF_Stmt {printf("Match IF_Stmt\n");}
	| WHILE_Stmt
	| FOR_Stmt
	| PRINT_Stmt {printf("Match PRINT_Stmt\n");}
	| Assign_Stmt {printf("Match Assign_Stmt\n");}
	;


DECLARE_Stmt: DECLARE VarList AS TYPE ';'	{	 declare(buf, $4); fprintf(fp, "%s", buf); printf("Match %s AS %d\n", buf, $4); printSym();}
			;

VarList: VarName				{	printf("Match VarName\n"); inserVarName($1);} 
	   | VarList ',' VarName    {	printf("VarList , VarName\n"); inserVarName($3); } 
	   ;

Expr: E {printf("Match Expr\n"); $$ = $1;}
	;

E: E '+' T
   {
	   fprintf(fp, "%s_ADD %s,%s,T&%d\n", $1->type==1?"I":"F", $1->name, $3->name, tmp_var_count);
	   $$ = creatTmp($1->type);
   }
 | E '-' T
   {
	   fprintf(fp, "%s_SUB %s,%s,T&%d\n", $1->type==1?"I":"F", $1->name, $3->name, tmp_var_count);
	   $$ = creatTmp($1->type);
   }
 | T	{$$ = $1;}
 ;

T: T '*' T
   {
	   fprintf(fp, "%s_MUL %s,%s,T&%d\n", $1->type==1?"I":"F", $1->name, $3->name, tmp_var_count);
	   $$ = creatTmp($1->type);
   }
 | T '/' T
   {
	   fprintf(fp, "%s_DIV %s,%s,T&%d\n", $1->type==1?"I":"F", $1->name, $3->name, tmp_var_count);
	   $$ = creatTmp($1->type);
   }
 | F
   {
	   $$ = $1;
   }
 ;

F: '(' E ')'	
 | '-' F
   {
	   fprintf(fp, "%s_UMINUS %s, T&%d\n", $2->type==1?"I":"F", $2->name, tmp_var_count);
	   $$ = creatTmp($2->type);
   }
 | NUMBER
   {
	   struct symtab_struct *p = malloc(sizeof(symtab));
	   p->value = $1;
	   p->type = 1;
	   sprintf(p->name, "%d", (int)$1);
	   $$ = p;
   }
 | FNUMBER	
   {
	   struct symtab_struct *p = malloc(sizeof(symtab));
	   p->value = atof($1);
	   p->type = 2;
	   strcpy(p->name, $1);
	   $$ = p;
   }
 | VarName
   {	
	   char tmp[MAX_LENGTH] = "";
	   strcpy(tmp, $1);
	   for(int i=0; i<strlen(tmp); ++i){
		   if(tmp[i] == '['){
			   tmp[i] = '\0';
			   break;
		   }
	   }
	   int orig_ind = lookSym(tmp); // without []
	   int ind = lookSym($1);	// with []
	   $$ = &symtab[ind];
	   symtab[ind].type = symtab[orig_ind].type;
	   printf("VARN %s\n", $$->name);
   }
 ;

PRINT_Stmt: PRINT {strcpy(buf, "");} '(' PRINT_List ')' ';'
			{
				fprintf(fp, "CALL print,%s\n", buf);
			}
		  ;
PRINT_List: Expr
		    {
				strcat(buf, $1->name);
			}
	      | PRINT_List ',' Expr
		    {
				strcat(buf, ",");
				strcat(buf, $3->name);
			}
		  ;

Assign_Stmt: VarName Assign_Op Expr ';' 
			{ 
				int ind = lookSym($1);
				int type = symtab[ind].type;
				fprintf(fp, "%s_STORE %s,%s\n", type==1?"I":"F", $3->name, $1);
			}
		   ;
Condition: Expr ConOp Expr	{printf("Match Condition\n");}
		   {
			   fprintf(fp, "%s_CMP %s, %s\n", $1->type==1?"I":"F", $1->name, $3->name);
			   push(&con_stack, label_count);
			   fprintf(fp, "%s lb&%d\n", $2, label_count++);
		   }
		 ;
ConOp: L_OP {$$ = "JLE";}
	 | LE_OP {$$ = "JL";}
	 | EQ_OP {$$ = "JNE";}
	 | NE_OP {$$ = "JE";}
	 | S_OP {$$ = "JGE";}
	 | SE_OP {$$ = "JG";}
	 ;

IF_Stmt: IF '(' Condition ')' THEN Stmt_List 
         {
			push(&if_stack, label_count++);
			fprintf(fp, "J lb&%d\n", top(&if_stack));
			fprintf(fp, "lb&%d:	", pop(&con_stack));
		 }
		 ELSE_Stmt ENDIF
		 {
			fprintf(fp, "lb&%d:	", pop_front(&if_stack));
		 }
	   ;
ELSE_Stmt: ELSE Stmt_List	{printf("Match ELSE_Stmt\n");}
		 |
		 ;

WHILE_Stmt: WHILE 
			{
				push(&while_stack, label_count);
				fprintf(fp, "lb&%d:	", label_count++);
			}
			'(' Condition ')' Stmt_List ENDWHILE	
			{
				fprintf(fp, "J lb&%d\n", pop(&while_stack));
				fprintf(fp, "lb&%d:	", pop(&con_stack));
				printf("Match WHILE\n");
			}
	      ;

FOR_Stmt: FOR '(' VarName Assign_Op Expr FOR_To Expr FOR_Step')' 
		  {	
			  fprintf(fp, "I_STORE %s,%s\n", ($5->name), $3);
			  push(&for_stack, label_count);
			  fprintf(fp, "lb&%d:	", label_count++);
		  } 
		  Stmt_List ENDFOR	
		  {
			  if(!strcmp($8, "1")){
				  fprintf(fp, "%s %s\n", !strcmp($6, "TO")?"INC":"DEC", $3);	
			  }
			  else{
				  struct symtab_struct *p = creatTmp(1);
				  fprintf(fp, "%s %s,%s,%s\n", !strcmp($6, "TO")?"I_ADD":"I_SUB", $3, $8, p->name);
				  fprintf(fp, "I_STORE %s,%s\n", p->name, $3);
			  }
			  fprintf(fp, "I_CMP %s,%s\n", $3, ($7->name));
			  fprintf(fp, "JL lb&%d\n", pop(&for_stack));
		  }
		;

FOR_Step: STEP Expr {$$ = $2->name; printf("STEP %s\n", $2->name);}
        | {$$ = "1"; }
		;

FOR_To: TO	{$$ = "TO";}
	  | DOWNTO	{$$ = "DOWNTO";}
	  ;
%%


int main(){
	memset(symtab, 0, sizeof(symtab));
	fp = fopen("asm.txt", "w");
	yyparse();
	fclose(fp);
	return 0;

}

bool isVarArray(char* var){
	for(int i = 0; i < strlen(var); ++i){
		if(var[i] == '[')
			return true;
	}
	return false;
}
void declare(char* buf, int type){
	strcpy(buf, "");
	
	for(int i = 0; i < MAX_LENGTH; ++i){

		bool isArray = false;
		char array_count[MAX_LENGTH] = {};

		if( strcmp(var_name[i], "") !=0 ){

			strcat(buf, "Decalre ");

			// handle var array 
			if(isVarArray(var_name[i])){
				//printf("Is array\n");
				isArray = true;
				int count_start = 0, count_end = 0;

				for(int j = 0; j < strlen(var_name[i]); ++j){
					if(var_name[i][j] == '['){
						count_start = j + 1; 
					}
					if(var_name[i][j] == ']'){
						count_end = j - 1; 
					}
				}
				var_name[i][count_start - 1] = '\0'; // get var name without [...]
				for(int j = 0, k = count_start; k<=count_end; ++j, ++k){
					//printf("%c", var_name[i][k]);
					array_count[j] = var_name[i][k];
					if( k == count_end ){
						array_count[j+1] = '\0'; // append '\0' in end.
					}
				}
			}
			
			strcat(buf, var_name[i]);
			insertSym(var_name[i], type);

			strcat(buf, ", ");
			
		}
		else{
			break;
		}
		if(isArray){
			strcat(buf, (type == 1) ? "Integer_array,":"Float_array,");
			strcat(buf, array_count);
			strcat(buf, "\n");
		}
		else{
			strcat(buf, (type == 1) ? "Integer\n":"Float\n");
		}
	}
	memset(var_name, 0, sizeof(var_name));
}
void inserVarName(char *name){
	for(int i = 0; i < MAX_LENGTH; ++i){
		if( strcmp(var_name[i], "") == 0 ){
			strcpy(var_name[i], name);
			break;
		}
	}
}



struct symtab_struct *creatTmp(int type){
	char tname[MAX_LENGTH] = {};
	sprintf(tname, "T&%d", tmp_var_count++);
	//inserVarName(tname);
	int ind = lookSym(tname);
	symtab[ind].type = type;
	return &symtab[ind];
}

void tmpVarToASM(){
	for(int i=0; i<NSYMS; ++i){
		if(symtab[i].name[0] == 'T' && symtab[i].name[1] == '&'){
			fprintf(fp, "Declare %s, %s\n", symtab[i].name, symtab[i].type==1?"Integer":"Float");
		}
	}
}