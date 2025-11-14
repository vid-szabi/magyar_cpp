%{
#include <iostream>
#include <string>
#include <map>

using namespace std;

struct Symbol {
	string type; // type of the variable
	int line; // the line of the declaration
	int col; // the column of the declaration
	bool initialized; // was it initialized
};

map<string, Symbol> symbol_table;

void yyerror(string s);
void semantic_error(string s, int line, int col);
void check_variable_declared(string varname, int line, int col);
void check_variable_redeclared(string varname, int line, int col);
void print_symbol_table();

extern int yylex();
extern int yylineno;
extern int startcol;
%}

%union {
	int egesz_ertek;
	float valos_ertek;
	char betu_ertek;
	std::string* valtozonev;
	std::string* tipus;
}

%token <egesz_ertek> SZAMERTEK
%token <valos_ertek> VALOSERTEK
%token <valtozonev> VALTOZO
%token <valtozonev> KIFEJEZES /* for type checking */
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

%type<tipus> tipus

%left PLUSZ MINUSZ
%left SZOROZ OSZT
%left NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB NEMEGYENLO EGYENLO
%left ES VAGY
%left NEM

%nonassoc AKKOR
%nonassoc KULONBEN

/* The start symbol of the grammar */
%start s

%define parse.error verbose

%%

s: blokk {
	print_symbol_table();
}
;

blokk: /* eps */
	 | program
;

program: utasitas 
       | program utasitas 
       | program error /* general error */
;

utasitas: deklaracio UTASITASVEG
		| ertekadas UTASITASVEG
		| kiir UTASITASVEG
		| beolvas UTASITASVEG
		| elagazas 
		| ciklus
		| error UTASITASVEG /* unfinished statement */
;

deklaracio: tipus VALTOZO {
	string type = *$1;
	string varname = *$2;
	check_variable_redeclared(type, yylineno, startcol);
	Symbol sym;
	sym.type = type;
	sym.line = yylineno;
	sym.col = startcol;
	sym.initialized = false;
	symbol_table[varname] = sym;
	delete $1;
	delete $2;
}
| tipus VALTOZO ERTEKAD kifejezes {
	string type = *$1;
	string varname = *$2;
	check_variable_redeclared(varname, yylineno, startcol);
	Symbol sym;
	sym.type = type;
	sym.line = yylineno;
	sym.col = startcol;
	sym.initialized = true;
	symbol_table[varname] = sym;
	delete $1;
	delete $2;
}
;

tipus: SZAM { $$ = new string("szám"); }
	 | VALOS { $$ = new string("valós"); }
	 | BETU { $$ = new string("betü"); }
	 | LOGIKAI {$$ = new string("vajon"); }
;

ertekadas: VALTOZO ERTEKAD kifejezes {
	string varname = *$1;
	// Just assignment to existing variable
	check_variable_declared(varname, yylineno, startcol);
	symbol_table[varname].initialized = true;
	delete $1;
}
;

kiir: KIIR kifejezes ;

beolvas: BEOLVAS kifejezes ;

elagazas: HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD blokk BLOKKVEG
		| HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD blokk BLOKKVEG KULONBEN BLOKKKEZD blokk BLOKKVEG
;

ciklus: AMIG ZAROJELKEZD kifejezes ZAROJELVEG BLOKKKEZD blokk BLOKKVEG ;

kifejezes: IGAZ
		 | HAMIS
		 | SZAMERTEK
		 | VALOSERTEK
		 | BETUERTEK
		 | VALTOZO
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
		 | NEM kifejezes

%%
int main() {
	yyparse();
}

void yyerror(const string s) {
    cerr << "Syntax error at line " << yylineno
    << ", column " << startcol << ": " << s << endl;
}

void semantic_error(string s, int line, int col) {
	cerr << "Semantic error at line " << line
	<< ", column " << col << ": " << s << endl;
}

void check_variable_declared(string varname, int line, int col) {
	if (symbol_table.find(varname) == symbol_table.end()) {
		semantic_error("Variable '" + varname + "' used before declaration", line, col);
	}
}

void check_variable_redeclared(string varname, int line, int col) {
	if (symbol_table.find(varname) != symbol_table.end()) {
		semantic_error("Variable '" + varname + "' redeclared (first declared at line "
		+ to_string(symbol_table[varname].line) + ", column "
		+ to_string(symbol_table[varname].col) + ")", line, col);
	}
}

void print_symbol_table() {
	cout << endl;
	cout << "=== Symbol Table ===" << endl;
	cout << "Variable\tType\t\tLine:Col\tInitialized" << endl;
	cout << "--------\t----\t\t--------\t-----------" << endl;
	for (auto& symbol : symbol_table) {
		cout << symbol.first << "\t\t" 
		     << symbol.second.type << "\t\t" 
		     << symbol.second.line << ":" << symbol.second.col << "\t\t" 
		     << (symbol.second.initialized ? "Yes" : "No") << endl;
	}
}