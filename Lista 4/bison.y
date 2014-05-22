%{
	
	#include <iostream>
	#include <cstdio>
	#include <sting>
	#include <vector>
	
	#define LLEN 20
	
	#definde SYMBOL_NOT_FOUND -1
	
	typedef struct
	{
		string identifier;
		string value;
		bool type;/*0-normal, 1-constant*/
	}sym;
	
	int symTableLen = 0, outCodeLen = 0;
	
	char* tArray = new char[LLEN];
	
	vector<sym> symTable;
	vector<int> jumpStack;
	vector<string> outCode;

	extern int yylineno;

	int yyerror(char* str)
	{
		sprintf(tArray, "ERROR: At (%d): %s.\n", yylineno, str);
		cout << "ERROR: At (" << yylineno <<"): "<< str << ".\n";
		exit(0); 
	}
	
	int getSymbolIndex(string symbolName)
	{
		for(int i = 0; i < symTableLen; i++
			if(symTable.at(i).identifier == symbolName)
				return i;
		return SYMBOL_NOT_FOUND; 
	}	
%}

%union {
			char* str;
			char* num;
		}
		
%token <str> CONST
%token <str> VAR
%token <str> BEGIN
%token <str> END

%token <str> IF
%token <str> THEN
%token <str> ELSE

%token <str> WHILE
%token <str> DO

%token <str> WRITE
%token <str> READ

%token <str> ASG

%token <str> ADD
%token <str> SUB
%token <str> MUL
%token <str> DIV
%token <str> MOD

%token <str> EQ
%token <str> NE
%token <str> LT
%token <str> GT
%token <str> LE
%token <str> GE

%token <num> NUM
%token <str> IDE

%token <str> SEM

%%

program	:
	| CONST 
	{
		sym nSym = {"symF__", "0", false};
		symTable.push_back(nSym);
		symTableLen += 1;
		
		sprintf(tArray, "SET %d %s", (symTabLen - 1), nSym.value.c_str());
		outCode.push_back(tArray);
		outCodeLen += 1;
	}
	cdeclarations VAR vdeclarations BEGIN commands END
	{
		sprintf(tArray, "HALT");
		outCode.push_back(tArray);
		outCodeLen += 1;
	}
;

cdeclarations : 
		cdeclarations IDE EQ NUM
		{
			if(getSymbolIndex($<str>2) != SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Redeclaration catched.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Redeclaration catched.\n";
				exit(0); 
			}
			else
			{
				sym nSym = {$<str>2, $<num>4, true};
				symTable.push_back(nSym);
				symTableLen += 1;
				//sprintf code
				//add to out code
			}
		}
		|
;

vdeclarations :
		vdeclarations IDE
		{
			if(getSymbolIndex($<str>2) != SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Redeclaration catched.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Redeclaration catched.\n";
				exit(0); 
			}
			else
			{
				sym nSym = {$<str>2, "", false};
				symTable.push_back(nSym);
				symTableLen += 1;
			}
		}
		|
;

commands :
	commands command
	|
; 

command :
	IDE ASG expression SEM
		{
			int symIndex = getSymbolIndex($<str>1);
			if(symIndex == -1)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				if(symTable.at(symIndex).type == true)
				{
					sprintf(tArray, "ERROR: At (%d): Variable is defined as constant.\n", yylineno);
					cout << "ERROR: At (" << yylineno <<"): Variable is defined as constant.\n";
					exit(0); 
				}
				else
				{
					
				}
			}
		}
	| IF
		{
		}
	 condition THEN commands
	 	{
	 	}
	 ELSE commands END
	 	{
	 	}
	| WHILE
		{
		}
	 condition DO commands END
	 	{
	 	}
	| READ identifier SEM
		{
			int symIndex = getSymbolIndex($<str>2);
			if(symIndex == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				if(symTable.at(symIndex).type == true)
				{
					sprintf(tArray, "ERROR: At (%d): Variable is defined as constant.\n", yylineno);
					cout << "ERROR: At (" << yylineno <<"): Variable is defined as constant.\n";
					exit(0); 
				}
				else
				{
					
				}
			}
		}
	| WRITE identifier SEM
		{
			int symIndex = getSymbolIndex($<str>1);
			if(symIndex == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
;

expression :
	NUM
		{
			
		}
	| IDE
		{
			int symIndex = getSymbolIndex($<str>1);
			if(symIndex == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE ADD IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE SUB IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE MUL IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE DIV IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE MOD IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
;

condition :
	IDE EQ IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE NE IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE LT IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE GT IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE LE IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
	| IDE GE IDE
		{
			int symIndex1 = getSymbolIndex($<str>1);
			int symIndex2 = getSymbolIndex($<str>3);
			if(symIndex1 == SYMBOL_NOT_FOUND || symIndex2 == SYMBOL_NOT_FOUND)
			{
				sprintf(tArray, "ERROR: At (%d): Undefined variable.\n", yylineno);
				cout << "ERROR: At (" << yylineno <<"): Undefined variable.\n";
				exit(0); 
			}
			else
			{
				
			}
		}
;	
%%














