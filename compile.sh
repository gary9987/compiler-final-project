yacc -d final.y &&
lex final.l &&
gcc y.tab.c lex.yy.c -ly -lfl