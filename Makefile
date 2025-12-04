CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wno-unused-function
CXXFLAGS_UTF8 = -std=c++11 -Wall -O2 -finput-charset=UTF-8 -fexec-charset=UTF-8
all: compiler

lex.yy.c: lexer.l
	flex lexer.l

parser.tab.c parser.tab.h: parser.y
	bison -dvt parser.y

compiler: lex.yy.c parser.tab.c
	$(CXX) $(CXXFLAGS) -o compiler lex.yy.c parser.tab.c

clean:
	rm -f *.o lex.yy.c parser.tab.* parser.output compiler lexer.output

buildcode:
ifndef INPUT
	$(error You must specify an INPUT file, e.g. 'make buildcode INPUT=example.txt')
endif
	./compiler < $(INPUT)
	$(CXX) $(CXXFLAGS_UTF8) -o program code.cpp

.PHONY: all clean buildcode