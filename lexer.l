%{
#include <iostream>
#include <fstream>
using namespace std;

int colno = 1; // column number
ofstream out("lexer_output.txt");
%}

%option noyywrap
%option yylineno
/* noyywrap disables the need of a yywrap function */
/* yylineno enables Flex to automatically track line numbers */
/* yyleng is the length of the current matched token */
%%
"//".* { /* single-line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* multi-line comment */ }

[ \t\r] { /* ignore whitespace */ }

\n { colno = 1; }

    /* Valid string literals in the language */
    /* Types */
"szám" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
    }

"valós" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"betü" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"vajon" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Values for bool */
"igaz" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"hamis" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* IO functions */
"beolvas" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"kiír" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Conditional statement if-then-else */
"ha" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"akkor" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"különben" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Loop statement */
"amíg" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Logical statements */
"nem egyenlő" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"egyenlő" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"nem" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"és" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

"vagy" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Block start */
"{" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Block end */
"}" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Parentheses start */
"(" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Parentheses end */
")" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Assignment operator */
"=" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Addition */
"+" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Subtraction */
"-" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Multiplication */
"*" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Division */
"/" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Greater than or equal to */
">=" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Less than or equal to */
"<=" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Greater than */
">" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Less than */
"<" {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Token types */
    /* Variable name */
[a-zA-Z_][a-zA-Z0-9_]* {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Integer number */
[+-]?[0-9]+ {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Real number */
[+-]?(?:\d*\.\d+|\d+\.\d*) {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* Character */
'(\\.|[^\\'])' {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << yyleng << "] " << yytext << endl;
}

    /* End of file */
<<EOF>> { out.close(); return 0; }

    /* Anything else */
. {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol
        << ", hossz: " << yyleng << "] " << " Unknown symbol:" << yytext << endl;
}
%%
int main(){
    yylex();
}