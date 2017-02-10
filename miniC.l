%{
#include "y.tab.h"
int yycolno = 0;
%}

%%
"int"	{ yycolno+=yyleng; return INT; }
"float" { yycolno+=yyleng; return FLOAT; }
"for" 	{ yycolno+=yyleng; return FOR;}
"while"	{ yycolno+=yyleng; return WHILE;}
"if"	{ yycolno+=yyleng; return IF;}
"else"	{ yycolno+=yyleng; return ELSE;}
"do"    { yycolno+=yyleng; return DO;}
"ifnelse"    { yycolno+=yyleng; return IFELSE;}
[0-9]+[.][0-9]+  { yylval.flt=strdup(yytext); yycolno+=yyleng; return FLT; }
[0-9]+  { yylval.num=atoi(yytext); yycolno+=yyleng; return NUM; }
[a-zA-Z]([a-zA-Z]|[0-9])*	{ yylval.id=strdup(yytext); yycolno+=yyleng; return ID;}
"<="    { yycolno+=yyleng; return IE;}
">="    { yycolno+=yyleng; return SE;}
"=="    { yycolno+=yyleng; return EG;}
"!="    { yycolno+=yyleng; return NG;}
">"	    { yycolno+=yyleng; return SS;}
"<"	    { yycolno+=yyleng; return IS;}
[ \t]   { yycolno+=yyleng; }
[\n]    { ++yylineno; yycolno=0; }
.       { yycolno+=yyleng; return yytext[0];}
%%