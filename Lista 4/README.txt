Projekt kompilatora na kurs: JFiTT 2014
Autor: Filip Jany
Nr indexu: 194208

Zasada kompilacji kompilatora:
-wykonac plik Makefile poleceniem:
 	*'make program' w celu kompilacji plikow potrzebnych do uruchomienia kompilatora
 	*'make clean' bu usunac pliki wykonane poleceniem powyzej
 	*'make interpreter' aby skompilowac plik interpretera
 	
Zasada uruchomienia programu kompilatora:
Po wczesniejszym wykonaniu polecenia 'make' kompilator nalezy uruchomic w nastepujacy sposob:
	*./program < <plik wejsciowy> <plik wyjsciowy>
	*np.	'./program < test.txt out.txt' spowoduje uruchomienie kompilatora dla pliku 'test.txt' natomiast 'out.txt' bedzie plikiem wyjsciowym
