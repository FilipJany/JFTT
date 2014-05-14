%option noyywrap
%option yylineno
%{
    #include <stdlib.h>
    #include "bison.tab.h"
    int yylex();
    
%}
%x comment

%%

"(*"                    BEGIN(comment);
<comment>[^*\n]*        ;
<comment>"*"+[^*)\n]*   ;
<comment>\n             ;
<comment>"*"+")"        BEGIN(INITIAL);

[ \t\r\n]+              {}
CONST                   { return(CONST);    }
VAR                     { return(VAR);      }
BEGIN                   { return(BEGIN);    }
END                     { return(END);      }

":="                    { return(ASG);      }
IF                      { return(IF);       }
THEN                    { return(THEN);     }
ELSE                    { return(ELSE);     }
WHILE                   { return(WHILE);    }
DO                      { return(DO);       }
WRITE                   { return(WRITE);    }
READ                    { return(READ);     }

"=="                    { return(EQ);       }
"<"                     { return(LT);       }
">"                     { return(GT);       }
"<="                    { return(LE);       }
">="                    { return(GE);       }
"!="                    { return(NE);       }

"+"                     { return(ADD);      }
"-"                     { return(SUB);      }
"*"                     { return(MUL);      }
"/"                     { return(DIV);      }
"%"                     { return(MOD);      }

[0-9]+                  { yylval.num = atoi(yytext);
                            return(NUM); }
[_a-z]+                 { yylval.str = (char *) strdup(yytext);
                            return(IDE); }

";"                     { return(SEM);      }
.	;

%%
