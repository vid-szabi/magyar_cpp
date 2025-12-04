# Magyar C++

A compiler for a Hungarian variant of C++ built using **Flex** (lexical analyzer) and **Bison** (parser generator). This project implements a complete lexical and syntactic analysis pipeline for a programming language with Hungarian keywords and syntax.

## Language Features

### Data Types

- **szám** - Integer type
- **valós** - Floating-point type
- **betü** - Character type
 - **betü** - Character type (single character — only non-accented characters are accepted)
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
├── cipher.hun           # Cipher example in Magyar C++
├── elagazas.hun         # Small if/else example
├── code.cpp             # Generated C++ output (emitted by the compiler)
├── lex.yy.c             # Generated C code from Flex
├── parser.tab.c/.h      # Generated parser code from Bison
├── lexer.output         # Lexer diagnostic output (generated)
├── parser.output        # Parser diagnostic output (generated)
```

## Building & Running

### Prerequisites

- **Flex** - Lexical analyzer generator
- **Bison** - Parser generator
- **G++** - C++ compiler

## Build Instructions

### 1. Build the Compiler

To generate the lexer, parser, and compile the `compiler` executable:

```bash
make
```

or

```bash
make all
```

### 2. Generate and Compile C++ Code from an Input File

Use the buildcode target to run the compiler on a Magyar C++ source file and automatically compile the generated C++ code:

```bash
make buildcode INPUT=example.hun
```

## Alternative: Build Instructions

```bash
# Generate lexer from Flex specification
flex lexer.l

# Generate parser from Bison specification
bison -dvt parser.y

# Compile everything together
g++ lex.yy.c parser.tab.c -o compiler

# Run with input
./compiler < fibonacci.hun

# Compile generated code
g++ code.cpp -o program

# Run program
./program
```

> Note: running the compiler or the build targets will generate several files (lexer/parser artifacts and generated C++). Typical generated files: `lex.yy.c`, `parser.tab.c`, `parser.tab.h`, `parser.output`, `lexer.output`, and `code.cpp`. Consider adding these to `.gitignore` if you don't intend to commit generated artifacts.

### Build with Diagnostic Output

```bash
# Generate parser with detailed output and counterexamples
bison -dvt -Wcounterexamples parser.y
```

This produces:

- `parser.output` - Detailed parser state machine information
- `lexer.output` - Lexer analysis output

## Files Overview

| File            | Purpose                                                   |
| --------------- | --------------------------------------------------------- |
| `lexer.l`       | Defines tokens and lexical rules for the Hungarian syntax |
| `parser.y`      | Defines grammar rules and syntax validation               |
| Makefile        | Contains pre-written building rules                       |
| `fibonacci.hun` | Example program demonstrating language features           |
| `cipher.hun`    | Cipher example demonstrating `vektor<szöveg>` usage       |
| `elagazas.hun`  | Small example demonstrating `ha...különben` flow          |
| `code.cpp`      | Generated C++ code emitted by the compiler                |
| `lexer.output`  | Lexer diagnostic output (token positions)                 |
| `parser.output` | Parser diagnostic output (states / conflicts)             |

## Key Implementation Details

- **UTF-8 Support**: Properly handles Hungarian accented characters (áÁ, éÉ, íÍ, óÓ, öÖ, őŐ, úÚ, üÜ, űŰ)
- **Line & Column Tracking**: Detailed error reporting with position information
- **Operator Precedence**: Correct precedence for arithmetic, comparison, and logical operators
- **Comment Support**: Both `//` single-line and `/* */` multi-line comments
- **Detailed Output**: Lexer produces detailed analysis output with token positions
- **Wide-string & locale support**: Generated C++ uses `wstring`, `L"..."` literals and configures the locale (via `locale::global`) so `wcin`/`wcout` correctly handle Hungarian characters.
- **Generated artifacts**: The compiler emits helper files such as `code.cpp`, `lexer.output` and `parser.output` during analysis and code generation.

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
- Initializer lists supported: `vektor<szám> v = {1, 2, 3};` (parsed as an initializer list)

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
- Indexing into a `szöveg` (string) returns a single-character `wstring` (code generation emits an expression that produces a `wstring` of length 1 for string indexing).

## Future enhancements

- string interpolation
