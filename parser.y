%{
#include <iostream>
#include <string>

using namespace std;

void yyerror(string s);
extern int yylex();
%}

%union {
	int egesz_ertek;
	float valos_ertek;
	string valtozonev;
}

%token <egesz_ertek> SZAM
%token <valos_ertek> VALOS
%token <valtozonev> VALTOZO
%token <valtozonev> BETU
%token IGAZ HAMIS
%token BEOLVAS KIIR
%token HA AKKOR KULONBEN
%token AMIG
%token NEMEGYENLO EGYENLO NEM ES VAGY
%token PONTOSVESSZO
%token BLOKKKEZD BLOKKVEG ZAROJELKEZD ZAROJELVEG
%token PLUSZ MINUSZ SZOROZ OSZT ERTEKAD NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB

%left PLUSZ MINUSZ
%left SZOROZ OSZT
%left NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB NEMEGYENLO EGYENLO
%left ES VAGY
%left NEM

/* The start symbol of the grammar */
%start s

%left '+' '-'
%left '*' '/'
%left '>' '<' '='
%left VAGY ES
%left NEM

%error-verbose

%%

%%
int main() {
	yyparse();
}

void yyerror(string s) {
	cout << s << endl;
}
