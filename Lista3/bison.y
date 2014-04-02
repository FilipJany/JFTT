%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    void yyerror(char *);
    int yylex(void);
%}

%token INTEGER
%token ADD SUB MUL DIV POW
%token LBR RBR
%token ENDL
 
%left ADD SUB
%left MOD
%left MUL DIV
%left UMIN
%right POW

%%

program:
        program expression ENDL			{ printf("\nWynik: %d\n", $2); }
		| /* NULL */ ;
expression:
        INTEGER							{ $$ = $1; printf(" %d ", $1); }
        | SUB expression %prec UMIN		{ $$ = -$2;	printf(" -"); }
		| expression ADD expression		{ $$ = $1 + $3; printf(" + "); }
        | expression SUB expression		{ $$ = $1 - $3;	printf(" - "); }
        | expression MOD expression		{ 
        									if($3 >0)
        									{
        										$$ = $1 % $3; 
        										printf(" %% "); 
        									}
        									else
        										yyerror("Error: Modulo must be greater than 0!");
        								}
        | expression MUL expression		{ $$ = $1 * $3;	printf(" * "); }
        | expression DIV expression		{ 
        									if($3 != 0)	
        									{
        										$$ = $1 / $3;
        										printf(" / "); 
        									}
        									else
        									{
        										printf(" / ");
        										yyerror("Error: You can't divide by 0!");
        									}
        								}
        | expression POW expression		{ $$ = pow( $1, $3); printf(" ^ "); }
        | LBR expression RBR			{ $$ = $2; }
        ;
%%
void yyerror(char *s) 
{
    fprintf(stderr, "%s\n", s);
    printf("\n");
    exit(1);
}

int main(void) 
{
    yyparse();
}