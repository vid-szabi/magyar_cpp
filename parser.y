%{
#include <iostream>
using namespace std;
extern int yylex();
void yyerror(string);
%}

%token SZAM //SZÁM
%token BETU //BETÜ

%%

%%
int main() {
	yyparse();	
}

void yyerror(string s) {
	cout << s << endl;
}
