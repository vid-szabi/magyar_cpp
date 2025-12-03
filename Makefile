CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wno-unused-function

all: compiler

lex.yy.c: lexer.l
	flex lexer.l

parser.tab.c parser.tab.h: parser.y
	bison -dvt parser.y

compiler: lex.yy.c parser.tab.c
	$(CXX) $(CXXFLAGS) -o compiler lex.yy.c parser.tab.c

clean:
	rm -f *.o lex.yy.c parser.tab.* parser.output compiler lexer.output

.PHONY: all clean