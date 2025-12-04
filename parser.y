%code requires {
#include <string>

struct ExprInfo {
	std::string code; // Generated code
	std::string type; // Type for semantic checking
};

// Forward declaration for vector helper
std::string extract_vector_element_type(const std::string& type);
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
extern bool has_error;
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
%token SZAM VALOS BETU

%token VEKTOR SABLONKEZD SABLONVEG INDEXKEZD INDEXVEG
%token HOZZAAD KIVESZ HOSSZ

%token LOGIKAI IGAZ HAMIS
%token BEOLVAS KIIR
%token HA AKKOR KULONBEN
%token AMIG
%token NEMEGYENLO EGYENLO NEM ES VAGY
%token UTASITASVEG
%token BLOKKKEZD BLOKKVEG ZAROJELKEZD ZAROJELVEG
%token PLUSZ MINUSZ SZOROZ OSZT ERTEKAD NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB

%type <tipus> tipus
%type <expr> kifejezes ha_feltetel amig_feltetel

%left PLUSZ MINUSZ
%left SZOROZ OSZT
%left NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB NEMEGYENLO EGYENLO
%left ES VAGY
%left NEM

%start s

%define parse.error verbose

%%

s: blokk
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
		| vektor_muvelet
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
	 | VEKTOR SABLONKEZD tipus SABLONVEG {
		string inner_type = *$3;
		$$ = new string("vektor<" + inner_type + ">");
		delete $3;
	 }
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
| VALTOZO INDEXKEZD kifejezes INDEXVEG ERTEKAD kifejezes {
	string varname = *$1;
	ExprInfo* index = $3;
	ExprInfo* expr = $6;
	
	check_variable_declared(varname, yylineno, startcol);
	string vartype = get_variable_type(varname);

	string element_type = extract_vector_element_type(vartype);
	check_type_compatibility(element_type, expr->type, yylineno, startcol);
	
	if (index->type != "szám") {
		semantic_error("vector index must be numeric type", yylineno, startcol);
	}
	
	generated_code << indent() << varname << "[" << index->code 
					<< "] = " << expr->code << ";" << endl;
	
    symbol_table[varname].initialized = true;

	delete $1;
	delete index;
	delete expr;
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

ha_feltetel: HA ZAROJELKEZD kifejezes ZAROJELVEG AKKOR {
	ExprInfo* condition = $3;
	generated_code << indent() << "if (" << condition->code << ") {" << endl;
	indent_level++;
	$$ = condition;
}
;

elagazas: ha_feltetel BLOKKKEZD blokk BLOKKVEG { 
	ExprInfo* condition = $1;
	/* blokk already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
}
| ha_feltetel BLOKKKEZD blokk BLOKKVEG KULONBEN BLOKKKEZD blokk BLOKKVEG {
	ExprInfo* condition = $1;
	/* blokk already generated */
	indent_level--;
	generated_code << indent() << "} else {" << endl;
	indent_level++;
	/* second blokk already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
}
;

amig_feltetel: AMIG ZAROJELKEZD kifejezes ZAROJELVEG {
	ExprInfo* condition = $3;
	generated_code << indent() << "while (" << condition->code << ") {" << endl;
	indent_level++;
	$$ = condition;
}
;

ciklus: amig_feltetel BLOKKKEZD blokk BLOKKVEG {
	ExprInfo* condition = $1;
	/* blokk already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
}
;

vektor_muvelet: HOZZAAD VALTOZO kifejezes UTASITASVEG {
	string varname = *$2;
	ExprInfo* expr = $3;

	check_variable_declared(varname, yylineno, startcol);
	string vartype = get_variable_type(varname);
	string element_type = extract_vector_element_type(vartype);
	check_type_compatibility(element_type, expr->type, yylineno, startcol);

	generated_code << indent() << varname << ".push_back(" << expr->code << ");" << endl;

	delete $2;
	delete expr;
}
| KIVESZ VALTOZO UTASITASVEG {
	string varname = *$2;

	check_variable_declared(varname, yylineno, startcol);

	generated_code << indent() << varname << ".pop_back();" << endl;

	delete $2;
}
| HOSSZ VALTOZO UTASITASVEG {
	string varname = *$2;

	check_variable_declared(varname, yylineno, startcol);

	generated_code << indent() << varname << ".length();" << endl;

	delete $2;
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
	| VALTOZO INDEXKEZD kifejezes INDEXVEG {
		string varname = *$1;
		ExprInfo* index = $3;

		check_variable_declared(varname, yylineno, startcol);
		string vartype = get_variable_type(varname);

		// Extract element type from vektor<type>
		string element_type = extract_vector_element_type(vartype);

		if (index->type != "szám") {
			semantic_error("vector index must be numeric type", yylineno, startcol);
		}

		$$ = new ExprInfo{varname + "[" + index->code + "]", element_type};
		delete $1;
		delete index;
	}
	| HOSSZ VALTOZO {
    string varname = *$2;
    check_variable_declared(varname, yylineno, startcol);
    string vartype = get_variable_type(varname);

    string element_type = extract_vector_element_type(vartype); // Actually you may not need this
    // The type of 'hossz' is always szám
    $$ = new ExprInfo{varname + ".size()", "szám"};
    delete $2;
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
	generated_code << "#include <iostream>" << endl
				   << "#include <vector>" << endl << endl
				   << "using namespace std;" << endl << endl
				   << "int main() {" << endl;
	indent_level++;

	yyparse();

	generated_code << endl << indent() << "return 0;" << endl << "}";
	indent_level--;
	if (!has_error) {
		print_symbol_table();
		print_generated_code(); /* Only generate code if no errors */
	}
	else {
		cerr << "No code generated because of errors" << endl;
	}
}

void yyerror(const string s) {
	has_error = true;
    cerr << "Syntax error at line " << yylineno
         << ", column " << startcol << ": " << s << endl;
}

void semantic_error(string s, int line, int col) {
	has_error = true;
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

bool is_vector_type(const string& type, string& inner) {
    const string prefix = "vektor<";
    const string suffix = ">";
    if (type.size() >= prefix.size() + suffix.size() &&
        type.compare(0, prefix.size(), prefix) == 0 &&
        type.compare(type.size() - suffix.size(), suffix.size(), suffix) == 0) 
    {
        inner = type.substr(prefix.size(), type.size() - prefix.size() - suffix.size());
        return true;
    }
    return false;
}

string extract_vector_element_type(const string& type) {
    string inner;
    if (is_vector_type(type, inner)) return inner;
    semantic_error("type is not a vector: " + type, yylineno, startcol);
    return "void";
}

string map_type_to_cpp(string type) {
	if (type == "szám") return "int";
	if (type == "valós") return "float";
	if (type == "betü") return "char";
	if (type == "vajon") return "bool";

    string inner;
    if (is_vector_type(type, inner)) {
        return "vector<" + map_type_to_cpp(inner) + ">";
    }

	return "void";
}