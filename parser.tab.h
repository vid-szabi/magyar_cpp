/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 1 "parser.y"

#include <string>

struct ExprInfo {
	std::string code; // Generated code
	std::string type; // Type for semantic checking
};

#line 58 "parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    SZAMERTEK = 258,               /* SZAMERTEK  */
    VALOSERTEK = 259,              /* VALOSERTEK  */
    VALTOZO = 260,                 /* VALTOZO  */
    BETUERTEK = 261,               /* BETUERTEK  */
    SZAM = 262,                    /* SZAM  */
    VALOS = 263,                   /* VALOS  */
    BETU = 264,                    /* BETU  */
    LOGIKAI = 265,                 /* LOGIKAI  */
    IGAZ = 266,                    /* IGAZ  */
    HAMIS = 267,                   /* HAMIS  */
    BEOLVAS = 268,                 /* BEOLVAS  */
    KIIR = 269,                    /* KIIR  */
    HA = 270,                      /* HA  */
    AKKOR = 271,                   /* AKKOR  */
    KULONBEN = 272,                /* KULONBEN  */
    AMIG = 273,                    /* AMIG  */
    NEMEGYENLO = 274,              /* NEMEGYENLO  */
    EGYENLO = 275,                 /* EGYENLO  */
    NEM = 276,                     /* NEM  */
    ES = 277,                      /* ES  */
    VAGY = 278,                    /* VAGY  */
    UTASITASVEG = 279,             /* UTASITASVEG  */
    BLOKKKEZD = 280,               /* BLOKKKEZD  */
    BLOKKVEG = 281,                /* BLOKKVEG  */
    ZAROJELKEZD = 282,             /* ZAROJELKEZD  */
    ZAROJELVEG = 283,              /* ZAROJELVEG  */
    PLUSZ = 284,                   /* PLUSZ  */
    MINUSZ = 285,                  /* MINUSZ  */
    SZOROZ = 286,                  /* SZOROZ  */
    OSZT = 287,                    /* OSZT  */
    ERTEKAD = 288,                 /* ERTEKAD  */
    NAGYOBBEGYENLO = 289,          /* NAGYOBBEGYENLO  */
    KISEBBEGYENLO = 290,           /* KISEBBEGYENLO  */
    NAGYOBB = 291,                 /* NAGYOBB  */
    KISEBB = 292                   /* KISEBB  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 55 "parser.y"

	int egesz_ertek;
	float valos_ertek;
	char betu_ertek;
	std::string* valtozonev;
	std::string* tipus;
	ExprInfo* expr;

#line 121 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
