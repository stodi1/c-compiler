%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE* yyin;
FILE *out, *tmp;
extern int yylineno;
extern int yycolno;
extern char* yytext;
	int err = 0, quadline = 0, whileCPT = 0, forCPT = 0;
	int tCPT = 0, temp = 0, nbTab, ff, nbTMP = 0;
	int quadM1[100], quadF1[100], forTAB[100];
	char T[100][100], jmpFOR[100][100], buffer;
	char bufferint[255], filename[100];
int backcount(FILE* file, char c){
	int cpt = 1;
	fseek(file, -1, SEEK_CUR);
	while(fgetc(file) != c){
		fseek(file, -2, SEEK_CUR); cpt++;
	}
	fseek(file, 0, SEEK_END); return cpt;
	}
%}
%union {char *id; int num; char *flt;}
%type<id> ID
%type<num> NUM
%type<flt> FLT
%token INT FLOAT FOR WHILE IF ELSE NUM FLT DO IFELSE
%token ID IE SE EG NG IS SS
%right '='
%left IE SE EG NG IS SS
%left '+' '-'
%left '*' '/'
%left UMINUS UPLUS
%nonassoc rule
%nonassoc ELSE

%%

Function:	Type ID '(' ArgList ')' CompoundStmt
		;

ArgList: ArgList ',' Arg
		| Arg
		|
		;

Arg	:	Type ID
		;

Declaration:	Type 	IdentList ';'			
		;

IdentList:	ID ',' IdentList
		| ID
		;

Type:		INT			
		| FLOAT			
		;

Stmt:		ForStmt
		| WhileStmt
		| Expr ';'  
		| IfStmt
		| CompoundStmt
		| Declaration
		| ';'
		| error {fprintf(stderr, "expected 'Stmt'");}
		;

ForStmt : FOR '(' Expr ';' F0 OptExpr F1 ';' OptExpr F2 ')' Stmt F3
		;

F0:		{
			quadF1[forCPT++] = quadline-nbTMP;
		}
		;

F1:		{
			nbTab = quadline + 3;
			fprintf(out,"\n%d 		|	JZ	|			|			|	!", quadline-nbTMP);
			while ( ( nbTab = nbTab / 10) != 0 )
				fprintf(out,"\t");
			fprintf(out," \t\t|");
			quadline++;
			ff = 1;
		}
		;

F2:		{
			ff = 0;
		}
		;

F3:		{
			sprintf(filename, "tmp.%d", forCPT);
			tmp = fopen(filename,"a");
			fclose(tmp);
			tmp = fopen(filename,"r");
			while( (buffer = fgetc(tmp)) != EOF ) {
				if( buffer == '\n' ){
					fprintf(out, "%c", buffer);
					while ( (buffer = fgetc(tmp)) != ' ' ){

					}
					fprintf(out, "%d ", quadline - nbTMP);
					nbTMP--;
				} else
					fprintf(out, "%c", buffer);
			}
			fclose(tmp);
			remove(filename);
			fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline, quadF1[--forCPT]);
			quadline++;
			fseek(out, -backcount(out, '!'), SEEK_CUR);
			fprintf(out,"%d", quadline);
			fseek(out, 0, SEEK_END);
		}
		;

OptExpr:	Expr
		| 			
		;
WhileStmt:	WHILE M1 '(' Expr ')' M2 Stmt M3
		|	DO M1 Stmt WHILE '(' Expr ')' M4
		;

M1:		{
			quadM1[whileCPT++] = quadline-nbTMP;
		}
		;

M2:		{
			nbTab = quadline + 3;
			fprintf(out,"\n%d 		|	JZ	|			|			|	$", quadline-nbTMP);
			while ( ( nbTab = nbTab / 10) != 0 )
				fprintf(out,"\t");
			fprintf(out," \t\t|");
			quadline++;
		}
		;

M3:		{
			fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline-nbTMP, quadM1[--whileCPT]);
			quadline++;
			fseek(out, -backcount(out, '$'), SEEK_CUR);
			fprintf(out,"%d", quadline);
			fseek(out, 0, SEEK_END);
		}
		;

M4:		{
			fprintf(out,"\n%d 		|	JNZ	|			|			|	%d		|", quadline-nbTMP, quadM1[--whileCPT]);
			quadline++;
		}
		;

IfStmt	:	IF '(' Expr ')'	S1 Stmt ElsePart
		|	IFELSE '(' Expr S11 ';' Stmt ';' S2 Stmt ')' E3	
		;

E3:		{
			fseek(out, -backcount(out, '@'), SEEK_CUR);
			fprintf(out,"%d", quadline);
			fseek(out, 0, SEEK_END);
		}
		;

S1:		{
			nbTab = quadline + 3;
			fprintf(out,"\n%d 		|	JZ	|			|			|	#", quadline-nbTMP);
			while ( ( nbTab = nbTab / 10) != 0 )
				fprintf(out,"\t");
			fprintf(out," \t\t|");
			quadline++;
		}
		;

S11:		{
			nbTab = quadline + 3;
			fprintf(out,"\n%d 		|	JNZ	|			|			|	#", quadline-nbTMP);
			while ( ( nbTab = nbTab / 10) != 0 )
				fprintf(out,"\t");
			fprintf(out," \t\t|");
			quadline++;
		}
		;

S2:		{
			nbTab = quadline + 3;
			fprintf(out,"\n%d 		|	JMP	|			|			|	@", quadline-nbTMP);
			while ( ( nbTab = nbTab / 10) != 0 )
				fprintf(out,"\t");
			fprintf(out," \t\t|");
			quadline++;

			fseek(out, -backcount(out, '#'), SEEK_CUR);
			fprintf(out,"%d", quadline-nbTMP);
			fseek(out, 0, SEEK_END);
		}
		;

ElsePart: ELSE S2 Stmt 	{
							fseek(out, -backcount(out, '@'), SEEK_CUR);
							fprintf(out,"%d", quadline);
							fseek(out, 0, SEEK_END);
						}
		| %prec rule	{
							fseek(out, -backcount(out, '#'), SEEK_CUR);
							fprintf(out,"%d", quadline);
							fseek(out, 0, SEEK_END);
						}
		;

CompoundStmt:	'{' StmtList '}'
		;

StmtList:	StmtList Stmt
		| 
		; 

Expr:	ID '=' Expr		{
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								fprintf(tmp,"\n%d 		|	=	|	%s		|			|	%s 		|", quadline,T[--tCPT], $1);
								quadline++;
								fclose(tmp);
							}
							else{
								fprintf(out,"\n%d 		|	=	|	%s   	|			|	%s 		|", quadline-nbTMP,T[--tCPT], $1);
								quadline++;
							}
						}	
		| Expr IE Expr	{
							temp++;
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								fprintf(tmp,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(tmp,"\n%d 		|	JG	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(tmp,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
								fclose(tmp);
							} else {
								fprintf(out,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(out,"\n%d 		|	JG	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(out,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(out,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
							}
							tCPT--;
							sprintf(T[tCPT], "t%d", temp);
							tCPT++;
							quadline++;
						}
		| Expr SE Expr	{
							temp++;
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								fprintf(tmp,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(tmp,"\n%d 		|	JL	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(tmp,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
								fclose(tmp);
							} else {
								fprintf(out,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(out,"\n%d 		|	JL	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(out,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(out,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
							}
							tCPT--;
							sprintf(T[tCPT], "t%d", temp);
							tCPT++;
							quadline++;
						}
		| Expr EG Expr	{
							temp++;
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								fprintf(tmp,"\n%d 		|	-	|	%s		|	%s		|	t%d 		|", quadline++, T[tCPT-=2], T[++tCPT], temp);
								fprintf(tmp,"\n%d 		|	JZ	|			|			|	%d		|", quadline++, quadline+2-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline++, temp);
								fprintf(tmp,"\n%d 		|	JMP	|			|			|	%d		|", quadline++, quadline+1-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline, temp);
								fclose(tmp);
							} else {
								fprintf(out,"\n%d 		|	-	|	%s		|	%s		|	t%d 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT], temp);
								fprintf(out,"\n%d 		|	JZ	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(out,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(out,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline-nbTMP, temp);
							}
							tCPT--;
							sprintf(T[tCPT], "t%d", temp);
							tCPT++;
							quadline++;
						}
		| Expr NG Expr	{
							temp++;
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								fprintf(tmp,"\n%d 		|	-	|	%s		|	%s		|	t%d 		|", quadline++, T[tCPT-=2], T[++tCPT], temp);
								fprintf(tmp,"\n%d 		|	JZ	|			|			|	%d		|", quadline++, quadline+1-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline, temp);
								fclose(tmp);
							} else {
								fprintf(out,"\n%d 		|	-	|	%s		|	%s		|	t%d 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT], temp);
								fprintf(out,"\n%d 		|	JZ	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(out,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline-nbTMP, temp);
							}
							tCPT--;
							sprintf(T[tCPT], "t%d", temp);
							tCPT++;
							quadline++;
						}
		| Expr IS Expr	{
							temp++;
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								fprintf(tmp,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(tmp,"\n%d 		|	JGE	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(tmp,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
								fclose(tmp);
							} else {
								fprintf(out,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(out,"\n%d 		|	JGE	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(out,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(out,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
							}
							tCPT--;
							sprintf(T[tCPT], "t%d", temp);
							tCPT++;
							quadline++;
						}
		| Expr SS Expr	{
							temp++;
							if (ff){
								nbTMP++;
								sprintf(filename, "tmp.%d", forCPT);
								tmp = fopen(filename,"a");
								
								fprintf(tmp,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(tmp,"\n%d 		|	JLE	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(tmp,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(tmp,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
								fclose(tmp);
							} else {
								fprintf(out,"\n%d 		|	CMP	|	%s		|	%s		|	 		|", quadline++-nbTMP, T[tCPT-=2], T[++tCPT]);
								fprintf(out,"\n%d 		|	JLE	|			|			|	%d		|", quadline++-nbTMP, quadline+2-nbTMP);
								fprintf(out,"\n%d 		|	=	|	1		|			|	t%d 		|", quadline++-nbTMP, temp);
								fprintf(out,"\n%d 		|	JMP	|			|			|	%d		|", quadline++-nbTMP, quadline+1-nbTMP);
								fprintf(out,"\n%d 		|	=	|	0		|			|	t%d 		|", quadline-nbTMP, temp);
							}
							tCPT--;
							sprintf(T[tCPT], "t%d", temp);
							tCPT++;
							quadline++;
						}
		
		| Expr '+' Expr		{
								temp++;
								if (ff){
									nbTMP++;
									sprintf(filename, "tmp.%d", forCPT);
									tmp = fopen(filename,"a");
									fprintf(tmp,"\n%d 		|	+	|	%s		|	%s		|	t%d 		|", quadline, T[tCPT-=2], T[++tCPT], temp);
									fclose(tmp);
								} else
									fprintf(out,"\n%d 		|	+	|	%s		|	%s		|	t%d 		|", quadline-nbTMP, T[tCPT-=2], T[++tCPT], temp);
								tCPT--;
								sprintf(T[tCPT], "t%d", temp);
								tCPT++;
								quadline++;
							}
		| Expr '-' Expr		{
								temp++;
								if (ff){
									nbTMP++;
									sprintf(filename, "tmp.%d", forCPT);
									tmp = fopen(filename,"a");
									fprintf(tmp,"\n%d 		|	-	|	%s		|	%s		|	t%d 		|", quadline, T[tCPT-=2], T[++tCPT], temp);
									fclose(tmp);
								} else
									fprintf(out,"\n%d 		|	-	|	%s		|	%s		|	t%d 		|", quadline-nbTMP, T[tCPT-=2], T[++tCPT], temp);
								tCPT--;
								sprintf(T[tCPT], "t%d", temp);
								tCPT++;
								quadline++;
							}	
		| Expr '*' Expr		{
								temp++;
								if (ff){
									nbTMP++;
									sprintf(filename, "tmp.%d", forCPT);
									tmp = fopen(filename,"a");
									fprintf(tmp,"\n%d 		|	*	|	%s		|	%s		|	t%d 		|", quadline, T[tCPT-=2], T[++tCPT], temp);
									fclose(tmp);
								} else
									fprintf(out,"\n%d 		|	*	|	%s		|	%s		|	t%d 		|", quadline-nbTMP, T[tCPT-=2], T[++tCPT], temp);
								tCPT--;
								sprintf(T[tCPT], "t%d", temp);
								tCPT++;
								quadline++;
							}
		| Expr '/' Expr		{
								temp++;
								if (ff){
									nbTMP++;
									sprintf(filename, "tmp.%d", forCPT);
									tmp = fopen(filename,"a");
									fprintf(tmp,"\n%d 		|	/	|	%s		|	%s		|	t%d 		|", quadline, T[tCPT-=2], T[++tCPT], temp);
									fclose(tmp);
								} else
									fprintf(out,"\n%d 		|	/	|	%s		|	%s		|	t%d 		|", quadline-nbTMP, T[tCPT-=2], T[++tCPT], temp);
								tCPT--;
								sprintf(T[tCPT], "t%d", temp);
								tCPT++;
								quadline++;
							}
		| '(' Expr ')'
		| '+' Expr %prec UPLUS		{
								temp++;
								if (ff){
									nbTMP++;
									sprintf(filename, "tmp.%d", forCPT);
									tmp = fopen(filename,"a");
									fprintf(tmp,"\n%d 		| UPLUS	|	%s		|			|	t%d 		|", quadline, T[tCPT-=1], temp);
									fclose(tmp);
								} else
									fprintf(out,"\n%d 		| UPLUS	|	%s		|			|	t%d 		|", quadline-nbTMP, T[tCPT-=1], temp);
								sprintf(T[tCPT], "t%d", temp);
								tCPT++;
								quadline++;
							}
		| '-' Expr %prec UMINUS		{
								temp++;
								if (ff){
									nbTMP++;
									sprintf(filename, "tmp.%d", forCPT);
									tmp = fopen(filename,"a");
									fprintf(tmp,"\n%d 		| UMINUS|	%s		|			|	t%d 		|", quadline, T[tCPT-=1], temp);
									fclose(tmp);
								} else
									fprintf(out,"\n%d 		| UMINUS|	%s		|			|	t%d 		|", quadline-nbTMP, T[tCPT-=1], temp);
								sprintf(T[tCPT], "t%d", temp);
								tCPT++;
								quadline++;
							}
		| ID			{ strcpy(T[tCPT++], $1); }
		| NUM			{ sprintf(T[tCPT], "%d", $1); tCPT++; }
		| FLT			{ strcpy(T[tCPT++], $1); }
		;
%%

int main(void) {
	yyin = fopen("fichier.in","r");
	out = fopen("fichier.out","w+");
	fprintf(out,"#	#	#	#	#	#	#	#	#	#	#	#	#	#");
	fprintf(out,"\n# 													#");
	fprintf(out,"\n#     ECOLE NATIONALE SUPERIEUR D'INFORMATIQUE!		#");
	fprintf(out,"\n#      TP COMPILE - Génerateur des quadruplets		#");
	fprintf(out,"\n#                  12 Janvier 2017					#");
	fprintf(out,"\n# 													#");
	fprintf(out,"\n#	#	#	#	#	#	#	#	#	#	#	#	#	#");
	/*fprintf(out,"\n\nCode mini-C:");
	fprintf(out,"\n-	-	-	-	-	-	-	-	-	-	-	-	-	-\n");
	while( (buffer = fgetc(yyin)) != EOF )
		fprintf(out, "%c", buffer);
	fclose(yyin);
	yyin = fopen("fichier.in","r");
	fprintf(out,"\n-	-	-	-	-	-	-	-	-	-	-	-	-	-");*/
	fprintf(out,"\n\nCode trois adresses (en forme des quadruplets) :");
	fprintf(out,"\n		-	-	-	-	-	-	-	-	-	-	-	-");
	fprintf(out,"\n		|	OP	|	Arg 1	|	Arg 2	|	 ADR	|");
	fprintf(out,"\n		_	_	_	_	_	_	_	_	_	_	_	_");
	yyparse();
	fprintf(out,"\n%d 		|	FIN	|			|			|			|", quadline);
	fprintf(out,"\n		-	-	-	-	-	-	-	-	-	-	-	-");
	fprintf(out,"\n\n#	#	#	#	#	#	#	#	#	#	#	#	#	#");
	fprintf(out,"\n# 													#");
	fprintf(out,"\n# 	       ABDDERRAHMANE ABADA © 2CS-SIL			#");
	fprintf(out,"\n# 													#");
	fprintf(out,"\n#	#	#	#	#	#	#	#	#	#	#	#	#	#");
	fclose(yyin);
	close(out);
	if (!err)
		printf("Compilation reussi!\nCode intermédiaire généré.\n");
	else {
		remove("fichier.out");
		out = fopen("fichier.out","w+");
		close(out);
	}
	return 0;
}
int yyerror(void){
	fprintf(stderr, "Erreur de compilation! '%s' trouvé. Ligne: %d, colonne: %d\n",yytext, yylineno,yycolno);
	err = 1;
	return 1;
}
int yywrap(void){
	return 1;
}