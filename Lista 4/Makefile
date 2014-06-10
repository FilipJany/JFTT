program:
	bison -d bison.y
	flex flex.l
	gcc -o program lex.yy.c bison.tab.c -lfl

clean:
	rm -f bison.tab.c bison.tab.h lex.yy.c program
	
interpreter:
	g++ -o interpreter interpreter.cc