%union{
	float f;
	int dec;
	char* str;
	int type;
}

%token PROGRAM Begin END DECLARE AS TYPE VarName NUMBER
%token <str> VarName
%token <type> TYPE

%{	
	#define MAX_LENGTH 100
	#include <stdio.h>
	extern int yylex();
	// ================ var ======================
	FILE *fp;
	char var_name[MAX_LENGTH][MAX_LENGTH] = {};
	char buf[MAX_LENGTH];
	// ================ function =================
	void declare(char* buf, int type);
	void inserVarName(char *name);

%}

%%
Start: PROGRAM VarName {fprintf(fp,"START %s\n", $2);} Begin Stmt_List ';' END	
	 ; 

Stmt_List: Stmt
		 | Stmt_List ';' Stmt 
		 ;

Stmt: DECLARE VarList AS TYPE	{	printf("Match DECLARE VarList AS TYPE\n"); declare(buf, $4); fprintf(fp, "%s", buf); }
	;

VarList: VarName				{	printf("Match VarName\n"); inserVarName($1); } 
	   | VarList ',' VarName    {	printf("VarList , VarName\n"); inserVarName($3); } 
	   ;

%%

#include <stdlib.h> 
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

int main(){
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