# Compiler Final Project Simple

## Folder Structure
```bash
compiler-final-project/
├── a.out
├── asm.txt
├── compile.sh
├── final.l # lex code
├── final.y # yacc code
├── lex.yy.c
├── LICENSE.md
├── Program_Exercise_yacc_2021.pdf
├── README.md
├── stack.c # custom stack
├── stack.h # custom stack
├── symtab.c # symbol table
├── symtab.h # symbol table
├── testP   # test program
├── y.tab.c
└── y.tab.h
```

## Run
```bash=
sh compile.sh
./a.out < testP
cat asm.txt
```

- The asm code will be output to `asm.txt` file.

### `testP` content
```
%%the beginning of an test data for Micro/Ex

Program testP

Begin

 declare I, J[100], k[20] as integer;

 declare A,B,C,D, LLL[100] as float;

End
```

### `asm.txt` content
```
START testP
Decalre I, Integer
Decalre J, Integer_array,100
Decalre k, Integer_array,20
Decalre A, Float
Decalre B, Float
Decalre C, Float
Decalre D, Float
Decalre LLL, Float_array,100
```