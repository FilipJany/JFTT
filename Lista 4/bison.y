%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	#define MAX_STACK 999
	#define MAX_LINE 40
	
	typedef struct
	{
		char* name;
		int value;
		int isConstant;
	}Sym;
	
	typedef struct
	{
		Sym stack[MAX_STACK];
		int top;
	}SymStack;
	
	typedef struct
	{
		char* array[MAX_STACK];
		int top;
	}CodeStack;
	
	typedef struct
	{
		int array[MAX_STACK];
		int top;
	}JumpStack;
	
	void pushSymbol(Sym);
	Sym popSymbol(SymStack);
	int getSymbolIndex(char*);
	
	void pushCode(char*);
	char* popCode();
	int getCodeIndex(char*);
	int getCodeLength();
	void addCodeLine(char*);
	
	void pushToJumpStack(int);
	int popFromJumpStack();
	int getAt(int);
	
	SymStack* symbolTable;
	CodeStack* codeTable;
	JumpStack* jumpStack;
	
	char* tArray[MAX_LINE];
	
	int yylex();
	int yylineno;
	int yyerror(char* str)
	{
		printf("Error: %s at line %d\n", str, yylineno);
		return 1;
	}
%}

%union {
			char* str;
			int num;
		}
		
%token <str> CONST
%token <str> VAR
%token <str> BEG
%token <str> END

%token <str> IF
%token <str> THEN
%token <str> ELSE

%token <str> WHILE
%token <str> DO

%token <str> WRITE
%token <str> READ

%token <str> ASG
%token <str> NC

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
			
		} 
	  cdeclarations VAR vdeclarations BEG commands END
	  {
	  
	  }
;
cdeclarations : cdeclarations IDE NC NUM
				{
					if(getSymbolIndex($<str>2) != -1)
					{
						printf("Error: Taka stala juz istnieje!\n");
						exit(1);
					}
					else
					{
						Sym s;
						s.name = $<str>2;
						s.value = $<num>4;
						s.isConstant = 1;
						pushSymbol(s);
						//printf("pushSymboled new constant(name: %s, value: %d) into stack\n", s.name, s.value);
						//printf("New stack top = %d\n", symbolTable->top);
					}
				}
				|
;
vdeclarations	: vdeclarations IDE
				{
					if(getSymbolIndex($<str>2) != -1)
					{
						printf("Error: Taka zmienna juz istnieje!\n");
						exit(1);
					}
					else
					{
						Sym s;
						s.name = $<str>2;
						s.value = 0;
						s.isConstant = 0;
						pushSymbol(s);
						//printf("pushSymboled new variable(name: %s, value: %d) into stack\n", s.name, s.value);
						//printf("New stack top = %d\n", symbolTable->top);
					}
				}
				|
;
commands	: commands command
				|
;
command	: IDE ASG expression SEM
				{
					int symIndex = getSymbolIndex($<str>1);
					if(symIndex == -1)
					{
						printf("Error: Nie ma takiej zmiennej\n");
						exit(1);
					}
					else
					{
						if(symbolTable->stack[symIndex].isConstant == 1)
						{
							printf("Error: Nie mozna przypisac nowej wartosci do zmiennej\n");
							exit(1);
						}
						else
						{
							//sprintf(tArray, "STORE %d", symIndex);
						}
					}
				}
		|IF 
			{
				printf("IF\n");
			}
		condition THEN commands 
			{
				printf("THEN\n");
			}
		ELSE commands END
			{
				printf("ELSE\n");
			}
			
		|WHILE 
			{
				printf("WHILE\n");
			}
		condition DO commands END
			{
				printf("DO\n");
				
			}
		|READ IDE SEM
			{
				printf("READ\n");
				
			}
		|WRITE IDE SEM
			{
				printf("WRITE\n");
				
			}
;
expression	: NUM
				{
					printf("NUM\n");
				}
		|IDE			
			{
				printf("IDE\n");
				
			}
		|IDE ADD IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				printf("ADD: (Indexes: %d and %d)\n", symIndex1, symIndex2);
				
			}
		|IDE SUB IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				printf("SUB: (Indexes: %d and %d)\n", symIndex1, symIndex2);
				
			}
		|IDE MUL IDE	
			{
				printf("MUL\n");
				
			}
		|IDE DIV IDE	
			{
				printf("DIV\n");
				
			}
		|IDE MOD IDE	
			{
				printf("MOD\n");
			}
;
condition	: IDE EQ IDE
				{
					printf("EQ\n");
					
				}
		|IDE NE IDE		
			{
				printf("NE\n");
				
			}
		|IDE LT IDE		
			{
				printf("LT\n");
				
			}
		|IDE GT IDE		
			{
				printf("GT\n");
				
			}
		|IDE LE IDE		
			{
				printf("LE\n");
				
			}
		|IDE GE IDE		
			{
				printf("GE\n");
				
			}
;
%%

void pushSymbol(Sym i)
{
	symbolTable->stack[symbolTable->top] = i;
	symbolTable->top++;
}
Sym popSymbol()
{
	symbolTable->top--;
	return symbolTable->stack[symbolTable->top + 1];
}
int getSymbolIndex(char* symName)
{
	int i;
	for(i = 0; i < symbolTable->top; i++)
		if(!strcmp(symbolTable->stack[i].name, symName))
			return i;
	return -1;
}
void initSymbolTable()
{
	symbolTable = (SymStack *)malloc(sizeof(SymStack));
	symbolTable->top = 0;
}

void pushCode(char* str)
{
	codeTable->array[codeTable->top] = str;
	codeTable->top++;
}
char* popCode()
{
	codeTable->top--;
	return codeTable->array[codeTable->top + 1];
}
int getCodeIndex(char* str)
{
	//to chyba nie bedzie mi potrzebne
	return 0;
}
int getCodeLength()
{
	return codeTable->top;
}
char* codeAt(int i)
{
	return codeTable->array[i];
}
void initCodeTable()
{
	codeTable = (CodeStack*)malloc(sizeof(CodeStack));
	codeTable->top = 0;
}

void freeAll()
{
	free(symbolTable);
	free(codeTable);
}

void pushToJumpStack(int i)
{
	jumpStack->array[jumpStack->top] = i;
	jumpStack->top++;
}
int popFromJumpStack()
{
	jumpStack->top--;
	return jumpStack->array[jumpStack->top + 1];
}
int getAt(int i)
{
	return jumpStack->array[i];
}
void initJumpStack()
{
	jumpStack = (JumpStack*)malloc(sizeof(JumpStack));
	jumpStack->top = 0;
}


int main()
{
	initSymbolTable();
	initCodeTable();
	initJumpStack();
	
	yyparse();
	
	freeAll();
	return 0;
}