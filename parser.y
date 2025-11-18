%code requires {
#include <string>

struct ExprInfo {
	std::string code; // Generated code
	std::string type; // Type for semantic checking
};
}

%{
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <string>
#include <map>

using namespace std;

struct Symbol {
	string type;
	int line;
	int col;
	bool initialized;
};

map<string, Symbol> symbol_table;

/* Better than using a string because that would copy many times */
ostringstream generated_code;
ofstream code_out("code.cpp");
int indent_level = 0;

void yyerror(string s);

void semantic_error(string s, int line, int col);
void check_variable_declared(string varname, int line, int col);
void check_variable_redeclared(string varname, int line, int col);
void check_type_compatibility(string type1, string type2, int line, int col);
void check_numeric_types(string type1, string type2, int line, int col);
void check_boolean_types(string type1, string type2, int line, int col);
void check_relational_operand_type(string type, int line, int col);
string get_variable_type(string varname);
void print_symbol_table();

void print_generated_code();
string indent();
string map_type_to_cpp(string type);

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
	ExprInfo* expr;
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
%type <expr> kifejezes

%left PLUSZ MINUSZ
%left SZOROZ OSZT
%left NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB NEMEGYENLO EGYENLO
%left ES VAGY
%left NEM

%nonassoc AKKOR
%nonassoc KULONBEN

%start s

%define parse.error verbose

%%

s: blokk {
	print_symbol_table();
	generated_code << endl << "return 0;" << endl << endl << "}";
	print_generated_code(); /* Only generate code if no errors */
}
;

blokk: /* eps */
	 | program
;

program: utasitas 
       | program utasitas 
       | program error
;

utasitas: deklaracio UTASITASVEG
		| ertekadas UTASITASVEG
		| kiir UTASITASVEG
		| beolvas UTASITASVEG
		| elagazas 
		| ciklus
		| error UTASITASVEG
;

deklaracio: tipus VALTOZO {
	string type = *$1;
	string varname = *$2;
	check_variable_redeclared(varname, yylineno, startcol);
	Symbol sym = {type, yylineno, startcol, false};
	symbol_table[varname] = sym;

	generated_code << indent() << map_type_to_cpp(type)
				   << " " << varname << ";" << endl;

	delete $1;
	delete $2;
}
| tipus VALTOZO ERTEKAD kifejezes {
	string type = *$1;
	string varname = *$2;
	ExprInfo* expr = $4;

	check_variable_redeclared(varname, yylineno, startcol);
	check_type_compatibility(type, expr->type, yylineno, startcol);

	Symbol sym = {type, yylineno, startcol, true};
	symbol_table[varname] = sym;

	generated_code << indent() << map_type_to_cpp(type) << " "
				   << varname << " = " << expr->code << ";" << endl;

	delete $1;
	delete $2;
	delete expr;
}
;

tipus: SZAM { $$ = new string("szám"); }
	 | VALOS { $$ = new string("valós"); }
	 | BETU { $$ = new string("betü"); }
	 | LOGIKAI { $$ = new string("vajon"); }
;

ertekadas: VALTOZO ERTEKAD kifejezes {
	string varname = *$1;
	ExprInfo* expr = $3;
	
	check_variable_declared(varname, yylineno, startcol);
	string vartype = get_variable_type(varname);
	check_type_compatibility(vartype, expr->type, yylineno, startcol);

	symbol_table[varname].initialized = true;

	generated_code << indent() << varname << " = " << expr->code << ";" << endl;

	delete $1;
	delete $3;
}
;

kiir: KIIR kifejezes {
	ExprInfo* expr = $2;
	generated_code << indent() << "cout << " << expr->code << " << endl;" << endl;
	delete expr;
}
;

beolvas: BEOLVAS kifejezes {
	ExprInfo* expr = $2;
	generated_code << indent() << "cin >> " << expr->code << ";" << endl;
	delete expr;
}
;

elagazas: HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD blokk BLOKKVEG { 
	ExprInfo* condition = $3;
	generated_code << indent() << "if (" << condition->code << ") {" << endl;
	indent_level++;
	/* blokk statements are already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
} %prec AKKOR
| HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR BLOKKKEZD blokk BLOKKVEG KULONBEN BLOKKKEZD blokk BLOKKVEG{
	ExprInfo* condition = $3;
	generated_code << indent() << "if (" << condition->code << ") {" << endl;
	indent_level++;
	/* first blokk statements are already generated */
	indent_level--;
	generated_code << indent() << "} else {" << endl;
	indent_level++;
	/* second blokk statements are already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
}
;

ciklus: AMIG ZAROJELKEZD kifejezes ZAROJELVEG BLOKKKEZD blokk BLOKKVEG{
	ExprInfo* condition = $3;
	generated_code << indent() << "while (" << condition->code << ") {" << endl;
	indent_level++;
	/* blokk statements are already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
}
;

kifejezes: IGAZ { $$ = new ExprInfo{"true", "vajon"}; }
	| HAMIS { $$ = new ExprInfo{"false", "vajon"}; }
	| SZAMERTEK {
		string value = to_string($1);
		$$ = new ExprInfo{value, "szám"}; 
	}
	| VALOSERTEK {
		string value = to_string($1);
		$$ = new ExprInfo{value, "valós"};
	}
	| BETUERTEK {
		string value = to_string($1);
		$$ = new ExprInfo{value, "betü"};
	}
	| VALTOZO {
		string varname = *$1;
		check_variable_declared(varname, yylineno, startcol);
		string vartype = get_variable_type(varname);
		$$ = new ExprInfo{varname, vartype};
		delete $1;
	}
	| kifejezes PLUSZ kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_numeric_types(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " + " + expr2->code + ")", expr1->type};
		delete expr1;
		delete expr2;
	}
	| kifejezes MINUSZ kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_numeric_types(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " - " + expr2->code + ")", expr1->type};
		delete expr1;
		delete expr2;
	}
	| MINUSZ kifejezes {
		ExprInfo* expr = $2;
		if (expr->type != "szám" && expr->type != "valós") {
			semantic_error("unary minus requires numeric type", yylineno, startcol);
		}
		$$ = new ExprInfo{"(-" + expr->code + ")", expr->type};
		delete expr;
	}
	| kifejezes SZOROZ kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_numeric_types(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " * " + expr2->code + ")", expr1->type};
		delete expr1;
		delete expr2;
	}
	| kifejezes OSZT kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_numeric_types(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " / " + expr2->code + ")", expr1->type};
		delete expr1;
		delete expr2;
	}
	| kifejezes NEMEGYENLO kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_type_compatibility(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " != " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| kifejezes EGYENLO kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_type_compatibility(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " == " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| kifejezes NAGYOBBEGYENLO kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_type_compatibility(expr1->type, expr2->type, yylineno, startcol);
		check_relational_operand_type(expr1->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " >= " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| kifejezes KISEBBEGYENLO kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_type_compatibility(expr1->type, expr2->type, yylineno, startcol);
		check_relational_operand_type(expr1->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " <= " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| kifejezes NAGYOBB kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_type_compatibility(expr1->type, expr2->type, yylineno, startcol);
		check_relational_operand_type(expr1->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " > " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| kifejezes KISEBB kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_type_compatibility(expr1->type, expr2->type, yylineno, startcol);
		check_relational_operand_type(expr1->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " < " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| ZAROJELKEZD kifejezes ZAROJELVEG {
		$$ = $2;
	}
	| kifejezes ES kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_boolean_types(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " && " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| kifejezes VAGY kifejezes {
		ExprInfo* expr1 = $1;
		ExprInfo* expr2 = $3;
		check_boolean_types(expr1->type, expr2->type, yylineno, startcol);
		$$ = new ExprInfo{"(" + expr1->code + " || " + expr2->code + ")", "vajon"};
		delete expr1;
		delete expr2;
	}
	| NEM kifejezes {
		ExprInfo* expr = $2;
		if (expr->type != "vajon") {
			semantic_error("negation requires boolean type", yylineno, startcol);
		}
		$$ = new ExprInfo{"(!" + expr->code + ")", "vajon"};
		delete expr;
	}
;

%%

int main() {
	generated_code << "#include <iostream>" << endl << endl << "using namespace std;"
	               << endl << endl << "int main() {" << endl;
	
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

void check_type_compatibility(string type1, string type2, int line, int col) {
	if (type1 != type2) {
		semantic_error("type mismatch: expected '" + type1
		               + "' but got '" + type2 + "' instead", line, col);
	}
}

void check_numeric_types(string type1, string type2, int line, int col) {
	check_type_compatibility(type1, type2, line, col);
	if (type1 != "szám" && type1 != "valós") {
		semantic_error("arithmetic operation requires numeric type", line, col);
	}
}

void check_boolean_types(string type1, string type2, int line, int col) {
	if (type1 != "vajon" || type2 != "vajon") {
		semantic_error("logical operation requires boolean type", line, col);
	}
}

void check_relational_operand_type(string type, int line, int col) {
	if (type == "vajon") {
		semantic_error("relational comparison not allowed on boolean type", line, col);
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

string get_variable_type(string varname) {
	if (symbol_table.find(varname) != symbol_table.end()) {
		return symbol_table[varname].type;
	}
	return "";
}

void print_generated_code() {
	cout << "=== Generated C++ Code ===" << endl;
	string generated_code_string = generated_code.str();
	cout << generated_code_string << endl;
	code_out << generated_code_string << endl;
}

string indent() {
	return string(indent_level * 4, ' ');
}

string map_type_to_cpp(string type) {
	if (type == "szám") return "int";
	if (type == "valós") return "float";
	if (type == "betü") return "char";
	if (type == "vajon") return "bool";
	return "void";
}