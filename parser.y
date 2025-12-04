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

string extract_vector_element_type(const string& type);
bool is_vector_type(const string& type, string& inner);

bool can_convert(string from, string to);
string generate_conversion_code(string from_type, string to_type, string code);
void warn_conversion(string from, string to, int line, int col);

string process_interpolated_string(const string& str, int line, int col);

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

%token VEKTOR SABLONKEZD SABLONVEG INDEXKEZD INDEXVEG VESSZO
%token HOZZAAD KIVESZ HOSSZ

%token LOGIKAI IGAZ HAMIS

%token MINT

%token BEOLVAS KIIR KIIRSOR UJSOR
%token HA KULONBEN
%token AMIG
%token NEMEGYENLO EGYENLO NEM ES VAGY
%token UTASITASVEG
%token BLOKKKEZD BLOKKVEG ZAROJELKEZD ZAROJELVEG
%token PLUSZ MINUSZ SZOROZ OSZT ERTEKAD NAGYOBBEGYENLO KISEBBEGYENLO NAGYOBB KISEBB

%type <tipus> tipus
%type <expr> kifejezes ha_feltetel amig_feltetel
%type <valtozonev> inicializalo_lista

%token SZOVEG
%token <valtozonev> SZOVEGERTEK INTERPOLALT_SZOVEGERTEK


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
		| kiirsor UTASITASVEG
		| ujsor UTASITASVEG
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
| tipus VALTOZO ERTEKAD BLOKKKEZD inicializalo_lista BLOKKVEG {
	string type = *$1;
	string varname = *$2;
	string init_list = *$5;

	check_variable_redeclared(varname, yylineno, startcol);

	string inner;
	if (!is_vector_type(type, inner)) {
		semantic_error("initializer list can only be used with vector types", yylineno, startcol);
	}

	Symbol sym = {type, yylineno, startcol, true};
	symbol_table[varname] = sym;

	generated_code << indent() << map_type_to_cpp(type) << " "
		<< varname << " = {" << init_list << "};" << endl; 
}
;

tipus: SZAM { $$ = new string("szám"); }
	 | VALOS { $$ = new string("valós"); }
	 | BETU { $$ = new string("betü"); }
	 | LOGIKAI { $$ = new string("vajon"); }
	 | SZOVEG { $$ = new string("szöveg"); }
	 | VEKTOR SABLONKEZD tipus SABLONVEG {
		string inner_type = *$3;
		$$ = new string("vektor<" + inner_type + ">");
		delete $3;
	 }
;

inicializalo_lista: kifejezes {
	ExprInfo* expr = $1;
	
	$$ = new string(expr->code);
	
	delete expr;
}
| inicializalo_lista VESSZO kifejezes {
	string* list = $1;
	ExprInfo* expr = $3;
	
	$$ = new string(*list + ", " + expr->code);
	
	delete list;
	delete expr;
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
        
	generated_code << indent() << "wcout << " << expr->code << ";" << endl;

    delete expr;
}
;

kiirsor: KIIRSOR kifejezes {
	ExprInfo* expr = $2;

    generated_code << indent() << "wcout << " << expr->code << " << endl;" << endl;
    
	delete expr;
}

ujsor: UJSOR {
	generated_code << indent() << "wcout << endl;" << endl;
}

beolvas: BEOLVAS kifejezes {
    ExprInfo* expr = $2;
    if (expr->type == "szöveg") {
        // Clear buffer if needed, then read full line
        generated_code << indent() << "if (wcin.peek() == '\\n') wcin.ignore();" << endl;
        generated_code << indent() << "getline(wcin, " << expr->code << ");" << endl;
    } else {
        generated_code << indent() << "wcin >> " << expr->code << ";" << endl;
    }
    delete expr;
}
;

ha_feltetel: HA ZAROJELKEZD kifejezes ZAROJELVEG {
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
| ha_feltetel BLOKKKEZD blokk BLOKKVEG kulonben_kezd BLOKKKEZD blokk BLOKKVEG {
	ExprInfo* condition = $1;
	/* first blokk already generated */
	// kulonben_kezd already wrote "} else {"
	/* second blokk already generated */
	indent_level--;
	generated_code << indent() << "}" << endl;
	delete condition;
}
;

kulonben_kezd: KULONBEN {
	indent_level--;
	generated_code << indent() << "} else {" << endl;
	indent_level++;
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
	| SZOVEGERTEK {
		string value = *$1;
		// Add L prefix for wide string literals
		value = "L" + value;
		$$ = new ExprInfo{value, "szöveg"};
		delete $1;
	}
	| INTERPOLALT_SZOVEGERTEK {
		string str = *$1;
		string processed = process_interpolated_string(str, yylineno, startcol);
		$$ = new ExprInfo{processed, "szöveg"};
		delete $1;
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

		if (vartype == "szöveg") {
			$$ = new ExprInfo{"wstring(1, " + varname + "[" + index->code + "])", "szöveg"};
		}
		else {
			$$ = new ExprInfo{varname + "[" + index->code + "]", element_type};
		}

		delete $1;
		delete index;
	}
	| HOSSZ VALTOZO {
    string varname = *$2;
    check_variable_declared(varname, yylineno, startcol);
    string vartype = get_variable_type(varname);

    // The type of 'hossz' is always szám
    $$ = new ExprInfo{varname + ".size()", "szám"};
    delete $2;
	}
	| ZAROJELKEZD kifejezes MINT tipus ZAROJELVEG {
		ExprInfo* expr = $2;
		string* target_type = $4;

		if (!can_convert(expr->type, *target_type)) {
			semantic_error("cannot convert '" + expr->type + "' to '" +
			*target_type + "'", yylineno, startcol);
		}

		warn_conversion(expr->type, *target_type, yylineno, startcol);

		string result_code = generate_conversion_code(expr->type, *target_type, expr->code);
		$$ = new ExprInfo{result_code, *target_type};
		
		delete expr;
		delete target_type;
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
				   << "#include <vector>" << endl
				   << "#include <vector>" << endl
				   << "#include <locale>" << endl << endl
				   << "using namespace std;" << endl << endl
				   << "int main() {" << endl;
	indent_level++;
	
	// Add Hungarian locale setup
	generated_code << indent() << "locale::global(locale(\"\"));" << endl;
	generated_code << indent() << "wcin.imbue(locale());" << endl;
	generated_code << indent() << "wcout.imbue(locale());" << endl;
	generated_code << endl;

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

    if (is_vector_type(type, inner)) {
		return inner;
	}

	if (type == "szöveg") {
		return "szöveg";
	}
	
	semantic_error("type is not a vector: " + type, yylineno, startcol);
    return "void";
}

string map_type_to_cpp(string type) {
	if (type == "szám") return "int";
	if (type == "valós") return "float";
	if (type == "betü") return "char";
	if (type == "vajon") return "bool";
	if (type == "szöveg") return "wstring";

    string inner;
    if (is_vector_type(type, inner)) {
        return "vector<" + map_type_to_cpp(inner) + ">";
    }

	return "void";
}

bool can_convert(string from, string to) {
    if (from == to) return true;
    
    // Pure numeric types: szám <-> valós
    if ((from == "szám" || from == "valós") &&
        (to == "szám" || to == "valós")) {
        return true;
    }
    
    // Numeric <-> betü (char/ASCII conversions)
    if ((from == "szám" || from == "valós") && to == "betü") {
        return true;
    }
    if (from == "betü" && (to == "szám" || to == "valós")) {
        return true;
    }
    
    // Bool <-> numeric types
    if (from == "vajon" && (to == "szám" || to == "valós")) {
        return true;
    }
    if ((from == "szám" || from == "valós") && to == "vajon") {
        return true;
    }
    
    return false;
}

string generate_conversion_code(string from_type, string to_type, string code) {
    if (from_type == to_type) return code;

    // Convert TO szám (int)
    if (to_type == "szám") {
        if (from_type == "valós")
            return "static_cast<int>(" + code + ")";
        if (from_type == "betü")
            return "static_cast<int>(" + code + ")";  // ASCII value
        if (from_type == "vajon")
            return "(" + code + " ? 1 : 0)";
    }

    // Convert TO valós (float)
    if (to_type == "valós") {
        if (from_type == "szám")
            return "static_cast<float>(" + code + ")";
        if (from_type == "betü")
            return "static_cast<float>(" + code + ")";
        if (from_type == "vajon")
            return "(" + code + " ? 1.0f : 0.0f)";
    }

    // Convert TO betü (char)
    if (to_type == "betü") {
        if (from_type == "szám")
            return "static_cast<char>(" + code + ")";
        if (from_type == "valós")
            return "static_cast<char>( static_cast<int>(" + code + ") )";
        // no conversion from bool -> char
    }

    // Convert TO vajon (bool)
    if (to_type == "vajon") {
        if (from_type == "szám")
            return "(" + code + " != 0)";
        if (from_type == "valós")
            return "(" + code + " != 0.0f)";
        // no conversion from char -> bool
    }

    return code;
}


void warn_conversion(string from, string to, int line, int col) {
    if (from == to) return;

    // valós -> szám loses fractional part
    if (from == "valós" && to == "szám") {
        cerr << "Warning at line " << line << ", column " << col
             << ": converting 'valós' to 'szám' may lose precision" << endl;
    }

    // szám -> betü loses range except 0..255
    if (from == "szám" && to == "betü") {
        cerr << "Warning at line " << line << ", column " << col
             << ": converting 'szám' to 'betü' may lose data (out-of-range to char)" 
             << endl;
    }

    // valós -> betü truncates fractional and range
    if (from == "valós" && to == "betü") {
        cerr << "Warning at line " << line << ", column " << col
             << ": converting 'valós' to 'betü' may lose precision and range"
             << endl;
    }

    // vajon -> szám / valós is safe (bool→numeric)
    // szám/valós -> vajon loses info because nonzero becomes "true"
    if ((from == "szám" || from == "valós") && to == "vajon") {
        cerr << "Warning at line " << line << ", column " << col
             << ": converting numeric value to boolean loses magnitude information" 
             << endl;
    }

    // betü -> szám / valós, safe ASCII mapping: no warning

    // numeric widening valós <- szám — no warning
}

string process_interpolated_string(const string& str, int line, int col) {
    // Remove leading and trailing quotes
    string content = str.substr(1, str.length() - 2);
    string result = "wstring(L\"";
    
    size_t pos = 0;
    
    while (pos < content.length()) {
        size_t start = content.find("${", pos);
        
        if (start == string::npos) {
            // No more interpolations, add the rest of the string
            result += content.substr(pos);
            break;
        }
        
        // Add the string part before the interpolation
        if (start > pos) {
            result += content.substr(pos, start - pos);
        }
        result += "\") + ";
        
        // Find the end of the interpolation
        size_t end = content.find("}", start);
        if (end == string::npos) {
            semantic_error("unclosed interpolation in string", line, col);
            return "L\"\"";
        }
        
        // Extract the variable name/expression
        string varname = content.substr(start + 2, end - start - 2);
        
        // Remove whitespace
        varname.erase(0, varname.find_first_not_of(" \t\n\r"));
        varname.erase(varname.find_last_not_of(" \t\n\r") + 1);
        
        if (varname.empty()) {
            semantic_error("empty interpolation in string", line, col);
            return "L\"\"";
        }
        
        // Check if the variable exists
        check_variable_declared(varname, line, col);
        string vartype = get_variable_type(varname);
        
        // Convert to wstring based on type
        if (vartype == "szöveg") {
            result += varname;
        } else if (vartype == "szám") {
            result += "to_wstring(" + varname + ")";
        } else if (vartype == "valós") {
            result += "to_wstring(" + varname + ")";
        } else if (vartype == "betü") {
            result += "wstring(1, " + varname + ")";
        } else if (vartype == "vajon") {
            result += "(" + varname + " ? L\"igaz\" : L\"hamis\")";
        } else {
            semantic_error("type '" + vartype + "' cannot be interpolated into string", line, col);
        }
        
        result += " + wstring(L\"";
        pos = end + 1;
    }
    
    result += "\")";
    return result;
}