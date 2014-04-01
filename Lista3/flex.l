%{
    #include "bison.tab.h"
    #include <stdlib.h>
    void yyerror(char *);
%}

%%

[0-9]+ 	{
			yylval = atoi(yytext);
 		    return INTEGER;
		}

"+"		{ return ADD; }
"-"		{ return SUB; }
"*"		{ return MUL; }
"/"		{ return DIV; }
"^"		{ return POW; }
"("		{ return LBR; }
")"		{ return RBR; }
"\n"	{ return ENDL; }
^\#.*\n	;
[ \t]+  ;
.		yyerror("Unknown character");

%%
    
int yywrap(void) 
{
     return 1;
}