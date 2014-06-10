%{
    #include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	#define MAX_STACK 999
	#define MAX_LINE 40
	#define DIGIT 48
	
	typedef struct
	{
		char* name;
		char* value;
		int isConstant;
		int _register;
	}Identifier;
	
	typedef struct
	{
		Identifier stack[MAX_STACK];
		int top;
	}IdentifierStack;
	
	typedef struct
	{
		char* stack[MAX_STACK];
		int top;
	}CodeStack;
	
	typedef struct
	{
		int stack[MAX_STACK];
		int top;
	}JumpStack;
	
	void initIdentifier(Identifier *,char*,char*, int);
	void pushIdentifier(Identifier);
	Identifier popIdentifier();
	int getIdentifierIndex(char*);
	int getIdentifierRegister(char *);
	
	void pushCode(char*);
	void pushCodeWithInt(char*, int);
	void fillCodeWithInt(int, int);
	char* popCode();
	int getCodeLength();
	void addCodeLine(char*);
	void printCode(char*);
	
	void pushToJumpStack(int);
	int popFromJumpStack();
	int getAt(int);
    
    void generateNumber(char *);
	
	IdentifierStack* IdentifierTable;
	CodeStack* codeTable;
	JumpStack* jumpStack;
	
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
| CONST cdeclarations VAR vdeclarations BEG commands END
{
    pushCode("HALT");
}
;
cdeclarations : cdeclarations IDE NC NUM
{
    if(getIdentifierIndex($<str>2) != -1)
    {
        printf("Error <line %d>: Stala <%s> juz istnieje!\n", yylineno, $<str>2);
        exit(1);
    }
    else
    {
        Identifier s;
        initIdentifier(&s, $<str>2, $<str>4, 1);
        pushIdentifier(s);
        generateNumber($<str>4);
        pushCodeWithInt("STORE", getIdentifierRegister($<str>2));
    }
}
|
;
vdeclarations	: vdeclarations IDE
{
    if(getIdentifierIndex($<str>2) != -1)
    {
        printf("Error <line %d>: Zmienna <%s> juz istnieje!\n", yylineno, $<str>2);
        exit(1);
    }
    else
    {
        Identifier s;
        initIdentifier(&s, $<str>2, "0", 0);
        pushIdentifier(s);
    }
}
|
;
commands	: commands command
|
;
command	: IDE ASG expression SEM
{
    int IdentifierIndex = getIdentifierIndex($<str>1);
    if(IdentifierIndex == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>2);
        exit(1);
    }
    else
    {
        if(IdentifierTable->stack[IdentifierIndex].isConstant == 1)
        {
           printf("Error <line %d>: <%s> jest stala, nie mozna zmienic jej wartosci!\n", yylineno, $<str>2);
        exit(1);
        }
        else
        {
            pushCodeWithInt("STORE", getIdentifierRegister($<str>1));
        }
    }
}
|IF condition
{
    pushToJumpStack(codeTable->top);
    pushCode("JZ");
}
THEN commands
{
    pushToJumpStack(codeTable->top);
    pushCode("JUMP");
    fillCodeWithInt(getAt(jumpStack->top - 2), codeTable->top);
}
ELSE commands END
{
    fillCodeWithInt(getAt(jumpStack->top - 1), codeTable->top);
    popFromJumpStack();
    popFromJumpStack();
}

|WHILE
{
    pushToJumpStack(codeTable->top);
}
condition
{
    pushToJumpStack(codeTable->top);
    pushCode("JZ");
}
DO commands END
{
    pushCodeWithInt("JUMP", getAt(jumpStack->top - 2));
    fillCodeWithInt(getAt(jumpStack->top - 1), codeTable->top);
    popFromJumpStack();
    popFromJumpStack();
}
|READ IDE SEM
{
    int IdentifierIndex = getIdentifierIndex($<str>2);
    if(IdentifierIndex == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>2);
        exit(1);
    }
    else
    {
        if(IdentifierTable->stack[IdentifierIndex].isConstant == 1)
        {
           printf("Error <line %d>: <%s> jest stala, nie mozna zmienic jej wartosci!\n", yylineno, $<str>2);
        	exit(1);
        }
        else
        {
            pushCodeWithInt("SCAN", getIdentifierRegister($<str>2));
        }
    }
}
|WRITE IDE SEM
{
	int IdentifierIndex = getIdentifierIndex($<str>2);
    if(IdentifierIndex == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>2);
        exit(1);
    }
    else
    {
        pushCodeWithInt("PRINT", getIdentifierRegister($<str>2));
    }
}
;
expression	: NUM
{
	generateNumber($<str>1);
}
|IDE
{
    int IdentifierIndex = getIdentifierIndex($<str>1);
    if(IdentifierIndex == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
    }
}
|IDE ADD IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("ADD", getIdentifierRegister($<str>3));
    }
}
|IDE SUB IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("SUB", getIdentifierRegister($<str>3));
    }
}
|IDE MUL IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("STORE", 1);
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));
        pushCodeWithInt("STORE", 2);
        
        int currentCodeAmount = codeTable->top;
        pushCode("ZERO");								//0
        pushCodeWithInt("STORE", 0);					//1
        pushCodeWithInt("JUMP", currentCodeAmount + 8);	//2
        
        pushCodeWithInt("LOAD", 0);						//3
        pushCodeWithInt("ADD", 2);						//4
        pushCodeWithInt("STORE", 0);					//5
        pushCodeWithInt("LOAD", 1);						//6
        pushCodeWithInt("JUMP", currentCodeAmount + 11);//7
        
        pushCodeWithInt("LOAD", 1);						//8
        pushCodeWithInt("JZ", currentCodeAmount + 18);	//9
        pushCodeWithInt("JODD", currentCodeAmount + 3); //10
        
        pushCode("SHR");								//11
        pushCodeWithInt("STORE", 1);					//12
        pushCodeWithInt("LOAD", 2);						//13
        pushCode("SHL");								//14
        pushCodeWithInt("STORE", 2);					//15
        pushCodeWithInt("LOAD", 1);						//16
        pushCodeWithInt("JG", currentCodeAmount + 8);	//17
        
        pushCodeWithInt("LOAD", 0);						//18
    }
}
|IDE DIV IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
    	int currentCodeAmount = codeTable->top;
    	
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("STORE", 1);
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));
        pushCodeWithInt("JZ", currentCodeAmount + 59);
        pushCodeWithInt("STORE", 2);
        
        int fr = IdentifierTable->stack[IdentifierTable->top-1]._register+1;

        pushCode("ZERO");
        pushCodeWithInt("STORE", fr); 
        pushCode("INC");
        pushCodeWithInt("STORE", 0); 

        currentCodeAmount = codeTable->top;
        
        pushCode("LOAD 1");
		pushCodeWithInt("JODD", currentCodeAmount + 9);
		pushCodeWithInt("JZ", currentCodeAmount + 16);
        
        pushCode("SHR");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 0);
		pushCode("SHL");
		pushCodeWithInt("STORE", 0);
		pushCodeWithInt("JUMP", currentCodeAmount);
        
        pushCode("SHR");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 0);
        pushCode("SHL");
        pushCode("INC");
        pushCodeWithInt("STORE", 0);
        pushCodeWithInt("JUMP", currentCodeAmount);
        
        pushCodeWithInt("LOAD", 0);
        pushCode("DEC");
        pushCodeWithInt("JZ", currentCodeAmount + 51);
        pushCode("INC");
		pushCodeWithInt("JODD", currentCodeAmount + 30);
		
        pushCode("SHR");
		pushCodeWithInt("STORE", 0);
		pushCodeWithInt("LOAD", 1);
		pushCode("SHL");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 2);
		pushCodeWithInt("SUB", 1);
		pushCodeWithInt("JG", currentCodeAmount + 47);
        pushCodeWithInt("JZ", currentCodeAmount + 39);
        
        pushCode("SHR");
		pushCodeWithInt("STORE", 0);
		pushCodeWithInt("LOAD", 1);
		pushCode("SHL");
		pushCode("INC");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 2);
		pushCodeWithInt("SUB", 1);
		pushCodeWithInt("JG", currentCodeAmount + 47);
        
        pushCodeWithInt("LOAD", 1);
		pushCodeWithInt("SUB", 2);
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", fr);
		pushCode("SHL");
		pushCode("INC");
		pushCodeWithInt("STORE", fr);
		pushCodeWithInt("JUMP", currentCodeAmount + 16);
        
        pushCodeWithInt("LOAD", fr);
		pushCode("SHL");
		pushCodeWithInt("STORE", fr);
		pushCodeWithInt("JUMP", currentCodeAmount + 16);
        
        pushCodeWithInt("LOAD", fr);
        
    }
}
|IDE MOD IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        int currentCodeAmount = codeTable->top;
        
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("STORE", 1);
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));
        pushCodeWithInt("JZ", currentCodeAmount + 52);
        pushCodeWithInt("STORE", 2);
        
        pushCode("ZERO");
        pushCode("INC");
        pushCodeWithInt("STORE", 0);
        
        currentCodeAmount = codeTable->top;
		
		pushCode("LOAD 1");
		pushCodeWithInt("JODD", currentCodeAmount + 9);
		pushCodeWithInt("JZ", currentCodeAmount + 16);
        
		pushCode("SHR");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 0);
		pushCode("SHL");
		pushCodeWithInt("STORE", 0);
		pushCodeWithInt("JUMP", currentCodeAmount);
        
		pushCode("SHR");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 0);
        pushCode("SHL");
        pushCode("INC");
        pushCodeWithInt("STORE", 0);
        pushCodeWithInt("JUMP", currentCodeAmount);
        
        pushCodeWithInt("LOAD", 0);
        pushCode("DEC");
        pushCodeWithInt("JZ", currentCodeAmount + 43);
        pushCode("INC");
		pushCodeWithInt("JODD", currentCodeAmount + 30);
		
		pushCode("SHR");
		pushCodeWithInt("STORE", 0);
		pushCodeWithInt("LOAD", 1);
		pushCode("SHL");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 2);
		pushCodeWithInt("SUB", 1);
		pushCodeWithInt("JG", currentCodeAmount + 16);
        pushCodeWithInt("JZ", currentCodeAmount + 39);
        
		pushCode("SHR");
		pushCodeWithInt("STORE", 0);
		pushCodeWithInt("LOAD", 1);
		pushCode("SHL");
		pushCode("INC");
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("LOAD", 2);
		pushCodeWithInt("SUB", 1);
		pushCodeWithInt("JG", currentCodeAmount + 16);
        
		pushCodeWithInt("LOAD", 1);
		pushCodeWithInt("SUB", 2);
		pushCodeWithInt("STORE", 1);
		pushCodeWithInt("JUMP", currentCodeAmount + 16);
        
        pushCodeWithInt("LOAD", 1);
    }
}
;
condition	: IDE EQ IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("STORE", 0);
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));
        pushCodeWithInt("STORE", 1);
        
        int currentCodeAmount = codeTable->top;
        
        pushCodeWithInt("LOAD", 0);				//0
        pushCodeWithInt("SUB", 1);					//1
        pushCodeWithInt("JG", currentCodeAmount + 8);		//2
        
        pushCodeWithInt("LOAD", 1);				//3
        pushCodeWithInt("SUB", 0);					//4
        pushCodeWithInt("JG", currentCodeAmount + 8);		//5
        pushCode("INC");						//6
        pushCodeWithInt("JUMP", currentCodeAmount + 9);	//7
        pushCode("ZERO");						//8
    }
}
|IDE NE IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("STORE", 0);
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));
        pushCodeWithInt("STORE", 1);
        
        int currentCodeAmount = codeTable->top;
        
        pushCodeWithInt("LOAD", 0);				//0
        pushCodeWithInt("SUB", 1);					//1
        pushCodeWithInt("JG", currentCodeAmount + 8);		//2
        
        pushCodeWithInt("LOAD", 1);				//3
        pushCodeWithInt("SUB", 0);					//4
        pushCodeWithInt("JG", currentCodeAmount + 8);		//5
        pushCode("ZERO");						//6
        pushCodeWithInt("JUMP", currentCodeAmount + 9);	//7
        
        pushCode("INC");						//8
    }
}
|IDE LT IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));
        pushCodeWithInt("SUB", getIdentifierRegister($<str>1));
    }
}
|IDE GT IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("SUB", getIdentifierRegister($<str>3));
    }
}
|IDE LE IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        int currentCodeAmount = codeTable->top;
        
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>1));
        pushCodeWithInt("SUB", getIdentifierRegister($<str>3));
        pushCodeWithInt("JZ",currentCodeAmount + 5);		//2
        pushCode("ZERO");						//3
        pushCodeWithInt("JUMP", currentCodeAmount + 6);	//4
        pushCode("INC");						//5
    }
}
|IDE GE IDE
{
    int IdentifierIndex1 = getIdentifierIndex($<str>1);
    int IdentifierIndex2 = getIdentifierIndex($<str>3);
    if(IdentifierIndex1 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>1);
        exit(1);
    }
    else if(IdentifierIndex2 == -1)
    {
        printf("Error <line %d>: Zmienna <%s> nie jest zdefiniowana!\n", yylineno, $<str>3);
        exit(1);
    }
    else
    {
        int currentCodeAmount = codeTable->top;
        
        pushCodeWithInt("LOAD", getIdentifierRegister($<str>3));	//0
        pushCodeWithInt("SUB", getIdentifierRegister($<str>1));	//1
        pushCodeWithInt("JZ",currentCodeAmount + 5);		//2
        pushCode("ZERO");						//3
        pushCodeWithInt("JUMP", currentCodeAmount + 6);	//4
        pushCode("INC");						//5
    }
}
;
%%

void initIdentifier(Identifier *s,char* name, char* value, int isConstant) 
{
    s->name = name;
    s->value = value;
    s->isConstant = isConstant;
    s->_register = IdentifierTable->top + 3;
}

void pushIdentifier(Identifier i)
{
	IdentifierTable->stack[IdentifierTable->top] = i;
	IdentifierTable->top++;
}
Identifier popIdentifier()
{
	IdentifierTable->top--;
	return IdentifierTable->stack[IdentifierTable->top + 1];
}
int getIdentifierIndex(char* IdentifierName)
{
	int i;
	for(i = 0; i < IdentifierTable->top; i++)
    if(!strcmp(IdentifierTable->stack[i].name, IdentifierName))
    return i;
	return -1;
}
int getIdentifierRegister(char *IdentifierName)
{
	return IdentifierTable->stack[getIdentifierIndex(IdentifierName)]._register;
}
void initIdentifierTable()
{
	IdentifierTable = (IdentifierStack *)malloc(sizeof(IdentifierStack));
	IdentifierTable->top = 0;
}

void pushCode(char* str)
{
	char* temp = (char*)malloc(strlen(str)+1);
	strcpy(temp, str);
	codeTable->stack[codeTable->top] = temp;
	codeTable->top++;
}
void pushCodeWithInt(char* str, int num)
{
	char* temp = (char*)malloc(strlen(str) + 5);
	sprintf(temp, "%s %d", str, num);
	codeTable->stack[codeTable->top] = temp;
	codeTable->top++;
}
void fillCodeWithInt(int command, int val)
{
	char **temp = &(codeTable->stack[command]);
	*temp = realloc(*temp, strlen(*temp) + 5);
	sprintf(*temp, "%s %d", *temp, val);
}

char* popCode()
{
	codeTable->top--;
	return codeTable->stack[codeTable->top + 1];
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
	return codeTable->stack[i];
}
void printCode(char* outFileName)
{
	FILE* fp = fopen(outFileName, "w");
	if(fp == NULL)
	{
		printf("Blad: Nie  mozna otworzyc/stworzyc pliku %s!\n", outFileName);
		exit(2);
	}
	int i;
	for(i = 0; i < codeTable->top; i++)
        fprintf(fp, "%s\n", codeTable->stack[i]);
    
    fclose(fp);
}
void initCodeTable()
{
	codeTable = (CodeStack*)malloc(sizeof(CodeStack));
	codeTable->top = 0;
}

void freeAll()
{
	int i;
	free(IdentifierTable);
	for(i = 0; i < codeTable->top; i++)
    free(codeTable->stack[i]);
	free(codeTable);
}

void pushToJumpStack(int i)
{
	jumpStack->stack[jumpStack->top] = i;
	jumpStack->top++;
}
int popFromJumpStack()
{
	jumpStack->top--;
	return jumpStack->stack[jumpStack->top + 1];
}
int getAt(int i)
{
	return jumpStack->stack[i];
}
void initJumpStack()
{
	jumpStack = (JumpStack*)malloc(sizeof(JumpStack));
	jumpStack->top = 0;
}

char *decToBin(char *dec) 
{
    char digit, r, r_temp;
    int i, j, k;
    int dec_len = strlen(dec);
    int bin_len = 0;
	
    char *out;
    char *bin = (char*)malloc(4*dec_len*sizeof(char)+1);
	if (!bin)
    return NULL;
    
	i = 0;
    k = 0;
    while (i < dec_len) 
    {
		r = 0;
		for (j = i; j < dec_len; ++j) 
		{
			digit = dec[j] - DIGIT;
			r_temp = digit & 0x01;
			digit = digit / 2;
			if (r)
                digit += 5;
			dec[j] = digit + DIGIT;
			r = r_temp;
		}
		bin[k++] = r + DIGIT;
		if (dec[i]=='0')
            ++i;
    }
    bin[k] = '\0';
    
    out = malloc(k+1);
    if (!out) 
    {
		free(bin);
        return NULL;
    }
    
    for (i = 0; i < k; ++i)
    out[i] = bin[k-1-i];
    out[k] = '\0';
    free(bin);
    
    return out;
} 


void generateNumber(char* number)
{
    char *bin = decToBin(number);
	int limit = strlen(bin);
	int i;
    pushCode("ZERO");
    
	for(i = 0; i < limit; ++i)
	{
		if(bin[i] == '1')
		{
			pushCode("INC");
		}
		if(i < (limit - 1))
	        pushCode("SHL");
	}
    
    free(bin);
}

void argManager(int argv, char* argc[])
{
	if(argv < 2)
	{
		printf("Aby poprawnie uruchomic ten program zapoznaj sie z plikiem README\n");
	}
	else
	{
		initIdentifierTable();
		initCodeTable();
		initJumpStack();
	
		yyparse();
	
    	printCode(argc[1]);
    
		freeAll();
	}
}

int main(int argv, char* argc[])
{
	argManager(argv, argc);
	return 0;
}