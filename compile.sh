yacc -d final.y &&
lex final.l &&
gcc stack.c symtab.c y.tab.c lex.yy.c -ly -lfl