%{
#include <iostream>
#include <iomanip>
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
void check_type_compatibility(string type1, string type2, int line, int col);
string get_variable_type(string varname);
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

%type <tipus> tipus
%type <tipus> kifejezes

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
	check_variable_redeclared(varname, yylineno, startcol);
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
	string exprtype = *$4;

	check_variable_redeclared(varname, yylineno, startcol);

	// Type validation at initialization
	check_type_compatibility(type, exprtype, yylineno, startcol);

	Symbol sym;
	sym.type = type;
	sym.line = yylineno;
	sym.col = startcol;
	sym.initialized = true;
	symbol_table[varname] = sym;
	delete $1;
	delete $2;
	delete $4;
}
;

tipus: SZAM { $$ = new string("szám"); }
	 | VALOS { $$ = new string("valós"); }
	 | BETU { $$ = new string("betü"); }
	 | LOGIKAI {$$ = new string("vajon"); }
;

ertekadas: VALTOZO ERTEKAD kifejezes {
	string varname = *$1;
	string exprtype = *$3;
	
	/* Just assignment to existing variable */
	check_variable_declared(varname, yylineno, startcol);
	string vartype = get_variable_type(varname);
	check_type_compatibility(vartype, exprtype, yylineno, startcol);

	symbol_table[varname].initialized = true;
	delete $1;
	delete $3;
}
;

kiir: KIIR kifejezes ;

beolvas: BEOLVAS kifejezes ;

elagazas: HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD blokk BLOKKVEG
		| HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD blokk BLOKKVEG KULONBEN BLOKKKEZD blokk BLOKKVEG
;

ciklus: AMIG ZAROJELKEZD kifejezes ZAROJELVEG BLOKKKEZD blokk BLOKKVEG ;

kifejezes: IGAZ { $$ = new string("vajon"); }
	| HAMIS { $$ = new string("vajon"); }
	| SZAMERTEK { $$ = new string("szám"); }
	| VALOSERTEK { $$ = new string("valós"); }
	| BETUERTEK { $$ = new string("betü"); }
	| VALTOZO {
	string varname = *$1;
	check_variable_declared(varname, yylineno, startcol);
	$$ = new string(get_variable_type(varname));
	delete $1;
	}
	| kifejezes PLUSZ kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 != "szám" && exprtype1 != "valós") {
		semantic_error("arithmetic operation requires numeric type", yylineno, startcol);
	}
	$$ = $1;
	delete $3;
	}
	| kifejezes MINUSZ kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 != "szám" && exprtype1 != "valós") {
		semantic_error("arithmetic operation requires numeric type", yylineno, startcol);
	}
	$$ = $1;
	delete $3;
	}
	| MINUSZ kifejezes {
	string exprtype = *$2;
	if (exprtype != "szám" && exprtype != "valós") {
		semantic_error("unary minus requires numeric type", yylineno, startcol);
	}
	$$ = $2;
	}
	| kifejezes SZOROZ kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 != "szám" && exprtype1 != "valós") {
		semantic_error("arithmetic operation requires numeric type", yylineno, startcol);
	}
	$$ = $1;
	delete $3;
	}
	| kifejezes OSZT kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 != "szám" && exprtype1 != "valós") {
		semantic_error("arithmetic operation requires numeric type", yylineno, startcol);
	}
	$$ = $1;
	delete $3;
	}
	| kifejezes EGYENLO kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| kifejezes NEMEGYENLO kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| kifejezes NAGYOBBEGYENLO kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 == "vajon") {
		semantic_error("relational comparison not allowed on boolean type", yylineno, startcol);
	}
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| kifejezes KISEBBEGYENLO kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 == "vajon") {
		semantic_error("relational comparison not allowed on boolean type", yylineno, startcol);
	}
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| kifejezes NAGYOBB kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 == "vajon") {
		semantic_error("relational comparison not allowed on boolean type", yylineno, startcol);
	}
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| kifejezes KISEBB kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	check_type_compatibility(exprtype1, exprtype2, yylineno, startcol);
	if (exprtype1 == "vajon") {
		semantic_error("relational comparison not allowed on boolean type", yylineno, startcol);
	}
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| ZAROJELKEZD kifejezes ZAROJELVEG {
	string exprtype = *$2;
	$$ = $2;
	}
	| kifejezes ES kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	if (exprtype1 != "vajon" || exprtype2 != "vajon") {
		semantic_error("logical operation requires boolean type", yylineno, startcol);
	}
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| kifejezes VAGY kifejezes {
	string exprtype1 = *$1;
	string exprtype2 = *$3;
	if (exprtype1 != "vajon" || exprtype2 != "vajon") {
		semantic_error("logical operation requires boolean type", yylineno, startcol);
	}
	$$ = new string("vajon");
	delete $1;
	delete $3;
	}
	| NEM kifejezes {
	string exprtype = *$2;
	if (exprtype != "vajon") {
		semantic_error("negation requires boolean type", yylineno, startcol);
	}
	$$ = $2;
	}

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
		semantic_error("variable '" + varname + "' used before declaration", line, col);
	}
}

void check_variable_redeclared(string varname, int line, int col) {
	if (symbol_table.find(varname) != symbol_table.end()) {
		semantic_error("variable '" + varname + "' redeclared (first declared at line "
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
	cout << endl;
}

void check_type_compatibility(string type1, string type2, int line, int col) {
	if (type1 != type2) {
		semantic_error("type mismatch: expected '" + type1
		+ "' but got '" + type2 + "' instead", line, col);
	}
}

string get_variable_type(string varname) {
	if (symbol_table.find(varname) != symbol_table.end()) {
		return symbol_table[varname].type;
	}
	return "";
}