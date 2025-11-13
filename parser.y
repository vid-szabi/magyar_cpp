%{
#include <iostream>
#include <string>

using namespace std;

void yyerror(string s);
extern int yylex();
extern int yylineno;
extern int startcol;
%}

%union {
	int egesz_ertek;
	float valos_ertek;
	char betu_ertek;
	std::string* valtozonev;
}

%token <egesz_ertek> SZAMERTEK
%token <valos_ertek> VALOSERTEK
%token <valtozonev> VALTOZO
%token <betu_ertek> BETUERTEK
%token SZAM VALOS BETU LOGIKAI
%token IGAZ HAMIS
%token BEOLVAS KIIR
%token HA AKKOR KULONBEN
%token AMIG
%token NEMEGYENLO EGYENLO NEM ES VAGY
%token UTASITASVEG
%token BLOKKKEZD BLOKKVEG ZAROJELKEZD ZAROJELVEG
%token PLUSZ MINUSZ SZOROZ OSZT ERTEKAD NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB

%left PLUSZ MINUSZ
%left SZOROZ OSZT
%left NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB NEMEGYENLO EGYENLO
%left ES VAGY
%left NEM

/* The start symbol of the grammar */
%start s

%define parse.error verbose

%%

s: /* eps */
   program
;

program: /* eps */
	  	 utasitas 
	   | error
       | program utasitas 
       | program utasitas error
;

utasitas: /* eps */
		  deklaracio UTASITASVEG
		| ertekadas UTASITASVEG
		| kiir UTASITASVEG
		| beolvas UTASITASVEG
		| elagazas 
		| ciklus
;

deklaracio: /* eps */
			SZAM VALTOZO
		  | SZAM ertekadas
		  | VALOS VALTOZO
		  | VALOS ertekadas
		  | BETU VALTOZO
		  | BETU ertekadas
		  | LOGIKAI VALTOZO
		  | LOGIKAI ertekadas
;

ertekadas: /* eps */
		   VALTOZO ERTEKAD kifejezes
;

kiir: /* eps */
	  KIIR kifejezes
;

beolvas: /* eps */
	     BEOLVAS kifejezes
;

elagazas: /* eps */
		  HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD program BLOKKVEG
		| HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD program BLOKKVEG KULONBEN BLOKKKEZD program BLOKKVEG
;

ciklus: /* eps */
	    AMIG ZAROJELKEZD kifejezes ZAROJELVEG BLOKKKEZD BLOKKVEG
;

kifejezes: /* eps */
		   SZAM
		 | VALOS
		 | BETU
		 | IGAZ
		 | HAMIS
		 | SZAMERTEK
		 | VALOSERTEK
		 | BETUERTEK
		 | kifejezes PLUSZ kifejezes
		 | kifejezes MINUSZ kifejezes
		 | MINUSZ kifejezes
		 | kifejezes SZOROZ kifejezes
		 | kifejezes OSZT kifejezes
		 | kifejezes EGYENLO kifejezes
		 | kifejezes NEMEGYENLO kifejezes
		 | kifejezes NAGYOBBEGYENLO kifejezes
		 | kifejezes KISEBBEGYENLO kifejezes
		 | kifejezes NAGYOBB kifejezes
		 | kifejezes KISEBB kifejezes
		 | ZAROJELKEZD kifejezes ZAROJELVEG
		 | kifejezes ES kifejezes
		 | kifejezes VAGY kifejezes
		 | kifejezes NEM kifejezes
		 | NEM kifejezes

%%
int main() {
	yyparse();
}

void yyerror(const string s) {
    cerr << "Syntax error at line " << yylineno
              << ", column " << startcol << ": " << s << endl;
}