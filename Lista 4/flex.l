%opiton noyywrap
%option yylineno

%{
	#include "bison.tab.h"
%}

%x COMMENT

%%

"(*"			BEGIN(COMMENT)		;
<COMMENT>		[^*\n]*				;
<COMMENT>		"*"+[^*\n]*			;
<COMMENT>		\n					;
<COMMENT>		"*"+")" 			BEGIN(INITIAL); 

[\t\r\n]+		{ ; }
CONST			{ return(CONST); 	}
VAR				{ return(VAR);		}
BEGIN			{ return(BEGIN);	}
END				{ return(END);		}
WHILE			{ return(WHILE);	}
DO				{ return(DO);		}
IF				{ return(IF);		}
THEN			{ return(THEN);		}
ELSE			{ return(ELSE);		}
WRITE			{ return(WRITE);	}
READ			{ return(READ);		}

":="			{ return(ASSIGN);	}
"=="			{ return(EQUALS);	}
"<"				{ return(LESS_T);	}
">"				{ return(GREAT_T);	}
"<="			{ return(L_EQUAL);	}
">="			{ return(G_EQUAL);	}
"!="			{ return(DIFFER);	}
"+"				{ return(ADD);		}
"-"				{ return(SUB);		}
"*"				{ return(MUL);		}
"/"				{ return(DIV);		}
"%"				{ return(MOD);		}

[0-9]+			{
					yylval.num = (char*) strdup(yytext);
					return(NUM);
				}
[_a-z]+			{
					yylval.str = (char*)strdup(yytext);
					return(ID);
				}
";"				{ return(SCNL);		}
.				{ ; }

%%
