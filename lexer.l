%{
#include <iostream>
#include <fstream>
#include <string>
#include "parser.tab.h"

using namespace std;

int colno = 1; // column number
int startcol = 1;
ofstream out("lexer.output");

// We need this because of the Hungarian accents
int utf8_strlen(const string& str) {
    int len = 0;
    for (unsigned char c : str) {
        if ((c & 0xC0) != 0x80) len++;
    }
    return len;
}
%}

/* noyywrap disables the need of a yywrap function */
/* yylineno enables Flex to automatically track line numbers */
/* yyleng is the length of the current matched token */
%option noyywrap
%option yylineno

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
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
    return SZAM;
    }

"valós" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
    return VALOS;
}

"betü" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
    return BETU;
}

"vajon" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Típus: " << yytext << endl;
    return LOGIKAI;
}

    /* Values for bool */
"igaz" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai érték: "  << yytext << endl;
    return IGAZ;
}

"hamis" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai érték: " << yytext << endl;
    return HAMIS;
}

    /* IO functions */
"beolvas" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Bemeneti-kimeneti parancs: " << yytext << endl;
    return BEOLVAS;
}

"kiír" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Bemeneti-kimeneti parancs: " << yytext << endl;
    return KIIR;
}

    /* Conditional statement if-then-else */
"ha" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << yytext << endl;
    return HA;
}

"akkor" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << yytext << endl;
    return AKKOR;
}

"különben" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << yytext << endl;
    return KULONBEN;
}

    /* Loop statement */
"amíg" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Ciklus kezdő: " << yytext << endl;
    return AMIG;
}

    /* Logical statements */
"nem egyenlő" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
    return NEMEGYENLO;
}

"egyenlő" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
    return EGYENLO;
}

"nem" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
    return NEM;
}

"és" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
    return ES;
}

"vagy" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Logikai kifejezés: " << yytext << endl;
    return VAGY;
}

    /* Statement end */
";" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Utasítás vége: " << yytext << endl;
    return UTASITASVEG;
}

    /* Block start */
"{" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Blokk kezdő: " << yytext << endl;
    return BLOKKKEZD;
}

    /* Block end */
"}" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Blokk vége: " << yytext << endl;
    return BLOKKVEG;
}

    /* Parentheses start */
"(" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Zárójel kezdő: " << yytext << endl;
    return ZAROJELKEZD;
}

    /* Parentheses end */
")" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Zárójel vége: " << yytext << endl;
    return ZAROJELVEG;
}

    /* Assignment operator */
    /* TODO: legyen */
"=" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return ERTEKAD;
}

    /* Addition */
"+" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return PLUSZ;
}

    /* Subtraction */
"-" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return MINUSZ;
}

    /* Multiplication */
"*" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return SZOROZ;
}

    /* Division */
"/" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return OSZT;
}

    /* Greater than or equal to */
">=" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return NAGYOBBEGYENLO;
}

    /* Less than or equal to */
"<=" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return KISEBBEGYENLO;
}

    /* Greater than */
">" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return NAGYOBB;
}

    /* Less than */
"<" {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Operátor: " << yytext << endl;
    return KISEBB;
}

    /* Token types */
    /* Variable name */
    /* TODO: [a-zA-Z_áÁéÉíÍóÓöÖőŐúÚüÜűŰ][a-zA-Z0-9_áÁéÉíÍóÓöÖőŐúÚüÜűŰ]* */
[a-zA-Z_][a-zA-Z0-9_]* {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Változó: " << yytext << endl;
    yylval.valtozonev = new string(yytext);
    return VALTOZO;
}

    /* Real number */
[+-]?(?:\d*\.\d+|\d+\.\d*) {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Valós szám: " << yytext << endl;
    yylval.valos_ertek = atof(yytext);
    return VALOSERTEK;
}

    /* Integer number */
[+-]?[0-9]+ {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Egész szám: " << yytext << endl;
    yylval.egesz_ertek = atoi(yytext);
    return SZAMERTEK;
}

    /* Character literal */
'(\\\\.|[^\\\\'])' {
    startcol = colno;
    int charlen = utf8_strlen(yytext);
    colno += charlen;
    out << "[sor: " << yylineno << ", oszlop: " << startcol << ", hossz: " << charlen << "] " << "Karakterlánc: " << yytext << endl;
    yylval.betu_ertek = yytext[0];
    return BETUERTEK;
}

    /* End of file */
<<EOF>> { out.close(); yyterminate(); }

    /* Anything else */
. {
    startcol = colno;
    colno += yyleng;
    out << "[sor: " << yylineno << ", oszlop: " << startcol
        << ", hossz: " << yyleng << "] " << "Lexikális hiba, ismeretlen szimbólum: " << yytext << endl;
}
%%
/* int main(){
    yylex();
} */