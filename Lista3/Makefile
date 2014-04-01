program: bison.y flex.l
		bison -d bison.y
		flex flex.l
		gcc -o program -L"../../flex-2.5.37/" bison.tab.c lex.yy.c -lfl
		
clean:
	rm -f bison.tab.c bison.tab.h lex.yy.c program