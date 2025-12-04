# Magyar C++

A compiler for a Hungarian variant of C++ built using **Flex** (lexical analyzer) and **Bison** (parser generator). This project implements a complete lexical and syntactic analysis pipeline for a programming language with Hungarian keywords and syntax.

## Language Features

### Data Types

- **szám** - Integer type
- **valós** - Floating-point type
- **betü** - Character type
- **vajon** - Boolean type

### Keywords & Operations

- **Variable Declaration & Assignment**: `szám x = 5;`
- **I/O Operations**: `beolvas` (input), `kiír` (output)
- **Control Flow**:
  - `ha-akkor-különben` (if-then-else)
  - `amíg` (while loops)
- **Boolean Values**: `igaz` (true), `hamis` (false)
- **Operators**:
  - Arithmetic: meg (`+`), mínusz (`-`), szorozva (`*`), osztva (`/`)
  - Comparison: egyenlő (`==`), nem egyenlő (`!=`), `<`, `>`, `<=`, `>=`
  - Logical: `és` (and), `vagy` (or), `nem` (not)

### Example Program

```magyar
szám fibo0 = 0;
szám fibo1 = 1;
szám count = 5;
count = count - 1;

amíg (count > 0)
{
    szám current = fibo0 + fibo1;
    fibo0 = fibo1;
    fibo1 = current;
    count = count - 1;
}
kiír fibo1;
```

## Project Structure

```text
├── lexer.l              # Flex lexical analyzer specification
├── parser.y             # Bison parser specification
├── fibonacci.hun        # Example program in Magyar C++
├── fibonacci.cpp        # Equivalent C++ reference implementation
├── lex.yy.c             # Generated C code from Flex
├── parser.tab.c/.h      # Generated parser code from Bison
```

## Building & Running

### Prerequisites

- **Flex** - Lexical analyzer generator
- **Bison** - Parser generator
- **G++** - C++ compiler

### Build Instructions

```bash
# Generate lexer from Flex specification
flex lexer.l

# Generate parser from Bison specification
bison -dvt parser.y

# Compile everything together
g++ lex.yy.c parser.tab.c -o magyar_cpp

# Run with input
./magyar_cpp < fibonacci.hun
```

### Build with Diagnostic Output

```bash
# Generate parser with detailed output and counterexamples
bison -dvt -Wcounterexamples parser.y
```

This produces:

- `parser.output` - Detailed parser state machine information
- `lexer.output` - Lexer analysis output

## Files Overview

| File              | Purpose                                                   |
| ----------------- | --------------------------------------------------------- |
| `lexer.l`         | Defines tokens and lexical rules for the Hungarian syntax |
| `parser.y`        | Defines grammar rules and syntax validation               |
| `lex.yy.c`        | Auto-generated lexer implementation (don't edit)          |
| `parser.tab.c/.h` | Auto-generated parser implementation (don't edit)         |
| `fibonacci.hun`   | Example program demonstrating language features           |

## Key Implementation Details

- **UTF-8 Support**: Properly handles Hungarian accented characters (áÁ, éÉ, íÍ, óÓ, öÖ, őŐ, úÚ, üÜ, űŰ)
- **Line & Column Tracking**: Detailed error reporting with position information
- **Operator Precedence**: Correct precedence for arithmetic, comparison, and logical operators
- **Comment Support**: Both `//` single-line and `/* */` multi-line comments
- **Detailed Output**: Lexer produces detailed analysis output with token positions

## Current Status

This is a compiler project for compiler construction coursework, implementing:

- Lexical analysis (tokenization)
- Syntactic analysis (parsing)
- Basic syntax validation
- Semantic anaylsis
- C++ code generation

### Vector Feature Additions

#### Vector Type Declaration

- `vektor<tipus>` now supported
- Example: `vektor<szám> tomb;`

#### Element Access & Assignment

- Can access element: `tomb[0]`
- Can assign value to element: `tomb[0] legyen 12;`
- Type checked against vector element type

#### Vector Operations

- `hozzáad tomb 674;` → adds element (`push_back`)
- `kivesz tomb;` → removes last element (`pop_back`)
- `hossz tomb` → gets size of vector (`size()`)

#### Semantic Checks

- Variable must be declared
- Index must be numeric
- Assigned value must match element type

#### Code Generation

- Generates proper C++ STL code (`push_back`, `pop_back`, `size`, array access)
- Tracks initialization in symbol table

#### Expression Integration

- Vector elements can be used in expressions: `kiír tomb[0];`
- Vector length can be used in expressions or assigned to variables: `szám tombhossz legyen hossz tomb;`

## Future enhancements

- improve vector semantic analysis
- add Hungarian accents to variables names
- type conversion (and giving error for possible value loss)
- string interpolation
