%{
	#include <stdio.h>
	#include <string.h>
	
	typedef struct
	{
		char name[20];
		float value;
		bool isConstant;
	}Variable;