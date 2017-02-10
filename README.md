# c-compiler
A compiler for mini-C language using YACC and LEX and generation of intermediate code.

# How to use (With OS X Sierra. You may do some changes with the other operating systems)
1- compile the miniC.y file with the command : yacc -d miniC.y
2- compile the miniC.l file using : lex miniC.l
3- compile the .c files : gcc lex.yy.c y.tab.c -o miniC
4- run the executable : ./miniC

# Result
an error message if the compilation of the code in the file "fichier.in" has failed or, a new file named "fichier.out" containing the generated intermediate code for the mini-C code in the input file (fichier.in).

# Contact me
For any other information, feel free to contact me at da_abada@esi.dz
