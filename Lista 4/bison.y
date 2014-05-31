%{
#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	#define MAX_STACK 999
	#define MAX_LINE 40
	
	typedef struct
	{
		char* name;
		char* value;
		int isConstant;
		int _register;
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
	
	void initSym(Sym *,char*,char*, int);
	void pushSymbol(Sym);
	Sym popSymbol(SymStack);
	int getSymbolIndex(char*);
	int getSymbolRegister(char *); 
	
	void pushCode(char*);
	void pushCodeWithInt(char*, int);
	char* popCode();
	int getCodeIndex(char*);
	int getCodeLength();
	void addCodeLine(char*);
	void printCode(char*);
	
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
	| CONST cdeclarations VAR vdeclarations BEG commands END
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
						initSym(&s, $<str>2, $<str>4, 1);
pushSymbol(s);
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
						initSym(&s, $<str>2, "0", 0);
pushSymbol(s);
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
							pushCodeWithInt("STORE", getSymbolRegister($<str>1));
							printf("STORE %d", getSymbolRegister($<str>1));
							printf("\n");
						}
					}
				}
		|IF condition
			{
				pushToJumpStack(codeTable->top);
				pushCode("JUMP");
				//printf("IF\n");
			}
		THEN commands 
			{
				pushToJumpStack(codeTable->top);
				pushCode("JUMP");
				fillCodeWithInt(getAt(jumpStack->top - 2), codeStack->top);
				//printf("THEN\n");
			}
		ELSE commands END
			{
				fillCodeWithInt(getAt(jumpStack->top - 1), codeStack->top);
				popFromJumpStack();
				popFromJumpStack();
				//printf("ELSE\n");
			}
			
		|WHILE 
			{
				pushToJumpStack(codeTable->top);
				//printf("WHILE\n");
			}
		condition
			{
				pushToJumpStack(codeTable->top);	
				pushCode("JZ");
			}
DO commands END
			{
				pushCodeWithInt("JUMP", getAt(jumpStack->top - 2));
				fillCodeWithInt(getAt(jumpStack->top - 1), codeStack->top);
				popFromJumpStack();
				popFromJumpStack();
				//printf("DO\n");
			}
		|READ IDE SEM
			{
				//printf("READ\n");
				int symIndex = getSymbolIndex($<str>2);
				if(symIndex == -1)
				{
					printf("Blad: NIezadeklarowana zmienna\n");
					exit(1);
				}
				else
				{
					if(symbolTable->stack[symIndex].isConstant == 1)
					{
						printf("Blad: %s jest stala!\n",(char *)$<str>2);
					}
					else
					{
						pushCodeWithInt("SCAN", getSymbolRegister($<str>2));
						printf("SCAN %d", getSymbolRegister($<str>2));
						printf("\n");
					}
				}
			}
		|WRITE IDE SEM
			{
				//printf("WRITE\n");
				int symIndex = getSymbolIndex($<str>2);
				if(symIndex == -1)
				{
					printf("Blad: Niezadeklarowana zmienna");
				}
				else
				{
					if(symbolTable->stack[symIndex].isConstant == 1)
					{
						printf("Blad: Nie wolno zmieniac wartosci stalej!\n");
						exit(0);
					}
					else	
					{
						pushCodeWithInt("PRINT", getSymbolRegister($<str>2));
						printf("PRINT %d", getSymbolRegister($<str>2));
						printf("\n");
					}
				}
			}
;
expression	: NUM
			{
				//IMPLEMENT ME 
				//printf("NUM\n");
				//numer zapisany do a
			}
		|IDE			
			{
				//printf("IDE\n");
				int symIndex = getSymbolIndex($<str>1);
				if(symIndex == -1)
				{
					printf("ERROR\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					printf("LOAD %d", getSymbolRegister($<str>1));
					printf("\n");
				}
			}
		|IDE ADD IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					pushCodeWithInt("ADD", getSymbolRegister($<str>3));
				}
				//printf("ADD: (Indexes: %d and %d)\n", symIndex1, symIndex2);
			}
		|IDE SUB IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					pushCodeWithInt("SUB", getSymbolRegister($<str>3));
				}
				//printf("SUB: (Indexes: %d and %d)\n", symIndex1, symIndex2);
			}
		|IDE MUL IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister(&<str>1));
					pushCodeWithInt("STORE", 1);
					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));
					pushCodeWithInt("STORE", 2);

					int currentCodeAmount = codeTable->top;
					pushCode("ZERO");								//0
					pushCodeWithInt("STORE", 0);					//1

					pushCodeWithInt("LOAD", 1);						//2
					pushCodeWithInt("JZ", currentCodeAmount + 17);	//3
					pushCodeWithInt("JODD", currentCodeAmoun+12);	//4
					
					pushCode("SHR");								//5
					pushCodeWithInt("STORE", 1);					//6
					pushCodeWithInt("LOAD", 2);						//7
					pushCode("SHL");								//8
					pushCodeWithInt("STORE", 2);					//9
					pushCodeWithInt("LOAD", 1);						//10
					pushCodeWithInt("JG", currentCodeAmount + 2);	//11
	
					pushCodeWithInt("LOAD", 0);						//12
					pushCodeWithInt("ADD", 2);						//13
					pushCodeWithInt("STORE", 0);					//14
					pushCodeWithInt("LOAD", 1)						//15
					pushCodeWithInt("JUMP", currentCodeAmount + 5); //16
					
					pushCodeWithInt("LOAD", 0);						//17
				}
				//printf("MUL\n");
			}
		|IDE DIV IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister(&<str>1));
					pushCodeWithInt("STORE", 1);
					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));
					pushCodeWithInt("STORE", 2);

					int currentCodeAmount = codeTable->top;
	
					pushCode("ZERO");								//0
					pushCodeWithInt("STORE", 0);					//1
					pushCodeWithInt("LOAD", 2);						//2
					pushCodeWithInt("JZ", currentCodeAmount + 14);	//3

					pushCodeWithInt("LOAD", 2);						//4
					pushCodeWithInt("SUB", 1);						//5
					pushCodeWithInt("JG", currentCodeAmount+14);	//6

					pushCodeWithInt("LOAD", 1);						//7
					pushCodeWithInt("SUB", 2);						//8
					pushCodeWithInt("STORE", 1);					//9
					pushCodeWithInt("LOAD", 0);						//10
					pushCode("INC");								//11
					pushCodeWithInt("STORE", 0);					//12
					pushCodeWithInt("JUMP", currentCodeAmount+4);	//13

					pushCodeWithInt("LOAD", 0);						//14

				}
				//printf("MUL: (Indexes: %d and %d)\n", symIndex1, symIndex2);
			}
		|IDE MOD IDE	
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister(&<str>1));
					pushCodeWithInt("STORE", 1);
					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));
					pushCodeWithInt("STORE", 2);

					int currentCodeAmount = codeTable->top;
	
					pushCode("ZERO");								//0
					pushCodeWithInt("STORE", 0);					//1
					pushCodeWithInt("LOAD", 2);						//2
					pushCodeWithInt("JZ", currentCodeAmount + 14);	//3

					pushCodeWithInt("LOAD", 2);						//4
					pushCodeWithInt("SUB", 1);						//5
					pushCodeWithInt("JG", currentCodeAmount+14);	//6

					pushCodeWithInt("LOAD", 1);						//7
					pushCodeWithInt("SUB", 2);						//8
					pushCodeWithInt("STORE", 1);					//9
					pushCodeWithInt("LOAD", 0);						//10
					pushCode("INC");								//11
					pushCodeWithInt("STORE", 0);					//12
					pushCodeWithInt("JUMP", currentCodeAmount+4);	//13

					pushCodeWithInt("LOAD", 1);						//14
}
				//printf("MOD: (Indexes: %d and %d)\n", symIndex1, symIndex2);
}
;
condition	: IDE EQ IDE
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					pushCodeWithInt("STORE", 1);
					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));
					pushCodeWithInt("STORE", 2);
					
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
				//printf("EQ\n");
			}
		|IDE NE IDE		
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					pushCodeWithInt("STORE", 1);
					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));
					pushCodeWithInt("STORE", 2);

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
				//printf("NE\n");
			}
		|IDE LT IDE		
			{
int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));
					pushCodeWithInt("SUB", getSymbolRegister($<str>1));
				}
				//printf("LT\n");
			}
		|IDE GT IDE		
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					pushCodeWithInt("SUB", getSymbolRegister($<str>3));
				}
				//printf("GT\n");
			}
		|IDE LE IDE		
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					int currentCodeAmount = codeTable->top;

					pushCodeWithInt("LOAD", getSymbolRegister($<str>1));
					pushCodeWithInt("SUB", getSymbolRegister($<str>3));
					pushCodeWithInt("JZ",currentCodeAmount + 5);		//2
					pushCode("ZERO");						//3
					pushCodeWithInt("JUMP", currentCodeAmount + 6);	//4
					pushCode("INC");						//5
				}
				//printf("LE\n");
			}
		|IDE GE IDE		
			{
				int symIndex1 = getSymbolIndex($<str>1);
				int symIndex2 = getSymbolIndex($<str>3);
				if(symIndex1 == -1 || symIndex2 == -1)
				{
					printf("Nie ma takiej zmiennej\n");
				}
				else
				{
					int currentCodeAmount = codeTable->top;

					pushCodeWithInt("LOAD", getSymbolRegister($<str>3));	//0
					pushCodeWithInt("SUB", getSymbolRegister($<str>1));	//1
					pushCodeWithInt("JZ",currentCodeAmount + 5);		//2
					pushCode("ZERO");						//3
					pushCodeWithInt("JUMP", currentCodeAmount + 6);	//4
					pushCode("INC");						//5
				}
				//printf("GE\n");
			}
;
%%

void initSym(Sym *s,char* name, char* value, int isConstant) {
s->name = name;
s->value = value;
s->isConstant = isConstant;
s->_register = symbolTable->top + 3;
}

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
int getSymbolRegister(char *symName) 
{
	return symbolTable->stack[getSymbolIndex(symName)]._register;
}
void initSymbolTable()
{
	symbolTable = (SymStack *)malloc(sizeof(SymStack));
	symbolTable->top = 0;
}

void pushCode(char* str)
{
	char* temp = (char*)malloc(strlen(str)+1);
	strcpy(temp, str);
	codeTable->array[codeTable->top] = temp;
	codeTable->top++;
}
void pushCodeWithInt(char* str, int num)
{
	char* temp = (char*)malloc(strlen(str) + 5);
	sscanf(temp, "%s %d", str, num);
	codeTable->array[codeTable->top] = temp;
	codeTable->top++;
}
void fillCodeWithInt(int command, int val);
{
	char **temp = &(codeTable->array[command]);
	*temp = realloc(*temp, strlen(*temp) + 5);
	sscanf(*temp, “%s %d”, *temp, val);
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
		fprintf(fp, codeTable->array[i]);
}
void initCodeTable()
{
	codeTable = (CodeStack*)malloc(sizeof(CodeStack));
	codeTable->top = 0;
}

void freeAll()
{
	int i;
	free(symbolTable);
	for(i = 0; i < codeTable->top; i++)
		free(codeTable->array[i]);
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

#define DIGIT 48	//0 w kodzie ascii, przesunięcie między reprezentacją cyfry a jej wartością

//ASSERT: dec to liczba zapisana w BIG_ENDIAN, tj. jak leci podczas odczytywania.
//	Innymi słowy, zachowując liczbę 123 w dec otrzymamy: dec[0] == 1, dec[2]  == 3, dec[3] == ‘\0’
char *decToBin(char *dec) {
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
while (i < dec_len) {
		r = 0;
		for (j = i; j < dec_len; ++j) {
			digit = dec[j] - DIGITS;
			r_temp = digit & 0x01;
			digit = digit / 2;
			if (r)
				digit += 5;
			dec[i] = digit + DIGITS;
			r = r_temp;
		}
		bin[k++] = r + DIGITS;
		if (dec[i]==’0’)
			++i;
}
bin[k] = ‘\0’;	//na tym etapie liczba binarna jest odwrócona, robimy lustro

out = malloc(k+1);
if (!out) {
		free(bin);
	return NULL;
}

for (i = 0; i < k; ++i)
		out[i] = bin[k-1-i];
out[k] = ‘\0’;	//teraz l.binarna jest zapisana jak na kartce: np.6 wyrażone w out={‘1’,’1’,’0’,‘\0’}
free(bin);

return out;
} 


void generateNumber(char* number)
{
	char *bin = decToBin(number);
	int limit = strlen(bin);
int i;
for(i = limit-1; i >= 0; i--)
{
	if(bin[i] == ‘1’)
		pushCode(”INC”);
	pushCode(“SHL”);
}
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
