%{
    #include <stdio.h>
    #include <math.h>
    void yyerror(char *);
    int yylex(void);
%}

%token INTEGER
%token ADD SUB MUL DIV POW
%token LBR RBR
%token ENDL
 
%left ADD SUB
%left MUL DIV
%left UMIN
%right POW

%%

program:
        program expression ENDL			{ printf("Wynik: %d\n", $2); }
		| /* NULL */ ;
expression:
        INTEGER							{ $$ = $1; 	}
        | SUB expression %prec UMIN		{ $$ = -$2;	}
		| expression ADD expression		{ $$ = $1 + $3; }
        | expression SUB expression		{ $$ = $1 - $3;	}
        | expression MUL expression		{ $$ = $1 * $3;	}
        | expression DIV expression		{ $$ = $1 / $3;	}
        | expression POW expression		{ $$ = pow( $1, $3); }
        | LBR expression RBR			{ $$ = $2; }
        ;
%%
void yyerror(char *s) 
{
    fprintf(stderr, "%s\n", s);
}

int main(void) 
{
    yyparse();
}