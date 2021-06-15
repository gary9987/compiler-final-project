%union{
	float f;
	int dec;
	char str[100];
	int type;
	struct symtab *symp;
}

%token PROGRAM Begin END DECLARE AS IF THEN ELSE ENDIF Assign_Op PRINT WHILE ENDWHILE FOR TO ENDFOR
%token L_OP LE_OP EQ_OP NE_OP S_OP SE_OP
%token <str> VarName
%token <type> TYPE
%token <dec> NUMBER
%token <f> FNUMBER
%type <f> E T F Expr FN


%{	
	#define MAX_LENGTH 100
	#include "symtab.h"
	#include <stdio.h>
	extern int yylex();
	// ================ var ======================
	FILE *fp;
	char var_name[MAX_LENGTH][MAX_LENGTH] = {};
	char buf[MAX_LENGTH];
	int tmp_var_count = 1;
	int global_type = 1;
	// ================ function =================
	void declare(char* buf, int type);
	void inserVarName(char *name);
	void yyerror(char *msg);
	void assignToASM(char *name, float value);

%}

%%
Start: PROGRAM VarName {fprintf(fp,"START %s\n", $2);} Begin Stmt_List END {printSym();}
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

Expr: E {printf("Match Expr, %f\n", $1);}
	| EN {printf("Match EN\n");}
	;
E: E '+' T	{$$ = $1 + $3;}
 | E '-' T	{$$ = $1 - $3;}
 | T	{$$ = $1;}
 ;
T: T '*' T	{$$ = $1 * $3;}
 | T '/' T	{ if($3==0){yyerror("devide by zero\n");} $$ = $1 / $3;}
 | F	{$$ = $1;}
 ;

F: '(' E ')'	{$$ = $2;}
 | '-' F	{$$ = -$2;}
 | NUMBER	{$$ = $1;}
 | FNUMBER	{$$ = $1;}
 ;

EN: EN '+' TN
  | EN '-' TN
  | TN
  ;
TN: {fprintf(fp, "%s ", global_type==1?"I_MUL":"F_MIL");} TN '*' TN	
  | TN '/' TN	
  FN
  ;

FN: '(' EN ')' 
  |  '-' 
  	{
		if(global_type == 1)
			fprintf(fp, "I_UMINUS ");
		if(global_type == 2)
			fprintf(fp, "F_UMINUS ");
	}
	  	FN
  | VarName	{ 
				fprintf(fp,"%s, T&%d\n", $1, tmp_var_count++);
			}
  ;

PRINT_Stmt: PRINT '(' PRINT_List ')' ';'
		  ;
PRINT_List: Expr {printf("print_list expr\n");}
	      | PRINT_List ',' Expr
		  ;

Assign_Stmt: VarName {global_type = getType($1);} Assign_Op Expr ';' { printf("%s %f\n", $1, $4); assignSym($1, $4); assignToASM($1, $4); }
		   ;
Condition: Expr ConOp Expr	{printf("Match Condition\n");}
		 ;
ConOp: L_OP | LE_OP | EQ_OP | NE_OP | S_OP | SE_OP
	 ;

IF_Stmt: IF '(' Condition ')' THEN Stmt_List ELSE_Stmt ENDIF
	   ;
ELSE_Stmt: ELSE Stmt_List	{printf("Match ELSE_Stmt\n");}
		 |
		 ;

WHILE_Stmt: WHILE '(' Condition ')' Stmt_List ENDWHILE	{printf("Match WHILE\n");}
	      ;

FOR_Stmt: FOR '(' VarName Assign_Op NUMBER TO NUMBER ')' Stmt_List ENDFOR	{printf("Match FOR\n");}
		;
%%

#include <stdlib.h> 
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

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

void assignToASM(char *name, float value){
	int type = getType(name);
	if(type == 1){
		fprintf(fp, "I_STORE %s,%d\n", name, (int)value);
	}
	if(type == 2){
		fprintf(fp, "F_STORE %s,%f\n", name, value);
	}
}