%{
#include "y.tab.h"
#include <stdlib.h> 
#include <stdio.h> 
extern YYSTYPE yylval;
%}

%%

\%\%.*
[0-9]+	{ yylval.dec = atoi(yytext); printf("Match token of NUMBER %d\n", yylval.dec); return NUMBER; }
[ \t]	;		/* ignore white space */
"+"      {   printf("Match token of +.\n"); return yytext[0];}
"-"      {   printf("Match token of -.\n"); return yytext[0];}


[Ii][Nn][Tt][Ee][Gg][Ee][Rr]    {yylval.type = 1; printf("Match token of Integer\n"); return TYPE;}
[Ff][Ll][Oo][Aa][Tt]            {yylval.type = 2; printf("Match token of Float\n"); return TYPE;}
[Pp][Rr][Oo][Gg][Rr][Aa][Mm]    {return PROGRAM;}
[Bb][Ee][Gg][Ii][Nn]    {return Begin;}
[Ee][Nn][Dd]    {return END;}
[Dd][Ee][Cc][Ll][Aa][Rr][Ee]    {return DECLARE;}
[Aa][Ss]    {return AS;}

[A-Za-z][A-Za-z0-9]*(\[[1-9][0-9]*\])*    {yylval.str = yytext; printf("Match token of VarName %s\n", yytext); return VarName;}
\n
\r
.	return yytext[0];

%%