/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    PROGRAM = 258,
    Begin = 259,
    END = 260,
    DECLARE = 261,
    AS = 262,
    IF = 263,
    THEN = 264,
    ELSE = 265,
    ENDIF = 266,
    Assign_Op = 267,
    PRINT = 268,
    WHILE = 269,
    ENDWHILE = 270,
    FOR = 271,
    TO = 272,
    ENDFOR = 273,
    L_OP = 274,
    LE_OP = 275,
    EQ_OP = 276,
    NE_OP = 277,
    S_OP = 278,
    SE_OP = 279,
    VarName = 280,
    TYPE = 281,
    NUMBER = 282,
    FNUMBER = 283
  };
#endif
/* Tokens.  */
#define PROGRAM 258
#define Begin 259
#define END 260
#define DECLARE 261
#define AS 262
#define IF 263
#define THEN 264
#define ELSE 265
#define ENDIF 266
#define Assign_Op 267
#define PRINT 268
#define WHILE 269
#define ENDWHILE 270
#define FOR 271
#define TO 272
#define ENDFOR 273
#define L_OP 274
#define LE_OP 275
#define EQ_OP 276
#define NE_OP 277
#define S_OP 278
#define SE_OP 279
#define VarName 280
#define TYPE 281
#define NUMBER 282
#define FNUMBER 283

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 1 "final.y"

	float f;
	int dec;
	char str[100];
	int type;
	struct symtab_struct *symp;
	char* constchar;

#line 122 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
