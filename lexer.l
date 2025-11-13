%{
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int colno = 1; // column number
ofstream out("lexer_output.txt");

// We need this because of the Hungarian accents
int utf8_strlen(const std::string& str) {
    int len = 0;
    for (unsigned char c : str) {
        if ((c & 0xC0) != 0x80) len++;
    }
    return len;
}
%}

%option noyywrap
%option yylineno
/* noyywrap disables the need of a yywrap function */
/* yylineno enables Flex to automatically track line numbers */
/* yyleng is the length of the current matched token */
%%
"//".* { /* single-line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* multi-line comment */ }

    /* ignore whitespace */
[ \t\r] {
    colno += yyleng;
}

\n { colno = 1; }

    /* Valid string literals in the language */
    /* Types */
"szám" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
    }

"valós" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
}

"betü" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
}

"vajon" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
}

    /* Values for bool */
"igaz" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai érték: "  << yytext << endl;
}

"hamis" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai érték: " << yytext << endl;
}

    /* IO functions */
"beolvas" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Bemeneti-kimeneti parancs: " << yytext << endl;
}

"kiír" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Bemeneti-kimeneti parancs: " << yytext << endl;
}

    /* Conditional statement if-then-else */
"ha" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << yytext << endl;
}

"akkor" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << yytext << endl;
}

"különben" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << yytext << endl;
}

    /* Loop statement */
"amíg" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Ciklus kezdő: " << yytext << endl;
}

    /* Logical statements */
"nem egyenlő" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
}

"egyenlő" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
}

"nem" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
}

"és" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
}

"vagy" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
}

    /* Statement end */
";" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Utasítás vége: " << yytext << endl;
}

    /* Block start */
"{" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Blokk kezdő: " << yytext << endl;
}

    /* Block end */
"}" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Blokk vége: " << yytext << endl;
}

    /* Parentheses start */
"(" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Zárójel kezdő: " << yytext << endl;
}

    /* Parentheses end */
")" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Zárójel vége: " << yytext << endl;
}

    /* Assignment operator */
"=" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Addition */
"+" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Subtraction */
"-" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Multiplication */
"*" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Division */
"/" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Greater than or equal to */
">=" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Less than or equal to */
"<=" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Greater than */
">" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Less than */
"<" {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
}

    /* Token types */
    /* Variable name */
    /* TODO: [a-zA-Z_áÁéÉíÍóÓöÖőŐúÚüÜűŰ][a-zA-Z0-9_áÁéÉíÍóÓöÖőŐúÚüÜűŰ]* */
[a-zA-Z_][a-zA-Z0-9_]* {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Változó: " << yytext << endl;
}

    /* Real number */
[+-]?(?:\d*\.\d+|\d+\.\d*) {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Valós szám: " << yytext << endl;
}

    /* Integer number */
[+-]?[0-9]+ {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Egész szám: " << yytext << endl;
}

    /* Character literal */
'(\\\\.|[^\\\\'])' {
    int startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Karakterlánc: " << yytext << endl;
}

    /* End of file */
<<EOF>> { out.close(); yyterminate(); }

    /* Anything else */
. {
    int startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol
        << ", hossz: " << yyleng << "] " << "Lexikális hiba, ismeretlen szimbólum: " << yytext << endl;
}
%%
int main(){
    yylex();
}