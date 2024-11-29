# A compiler for C

## Objective

This is a compiler for C, written in C++. It compiles C code to x86-64 assembly code. This is an educational project, and it is not intended to be used in production.

## Requirements

You need to have OCaml, Menhir, CMake, and a C++ compiler installed on your machine.

## How to use

To compile a C file, run the following command:

```bash
./compile-cpp.sh <input-file>
```

This will generate an executable file with the same name as the input file.

You can also run `./compile-gcc.sh <input-file>` to compile with gcc (for comparison).

To run an assembly file, run the following command:

```bash
gcc <input-file> -o <output-file> && ./<output-file>
```

or the `gcc <input-file> && ./a.out` if you don't want to specify an output file.


## How it works

The compiler is divided into tow main parts: the lexing and parsing part, and the code generation part.

### Lexing and parsing

The lexing and parsing part is implemented using OCamllex and Menhir. 
The code is in the `parser` directory. The lexer is in `lexer.mll` and the parser is in `parser.mly`. The file `ast.ml` contains the definition of the grammar.

### Code generation

The code generation part is implemented in C++. The code generation part is divided into differents parts.

- `JSON.cpp` : reads the AST
- `token.cpp` : convert JSON to tokens. Tokens are available in the `subclasses` directory.
- `assembly` directory : contains the assembly code for each token
- `compiler.hpp` : contains the main function to compile the code

## Features

#### Supported
- Variables (local and global)
- Arithmetic and logical operations
- If else statements
- For and while loops
- Functions and recursion
- Pointers
- Arrays
- Static arrays

#### Addition to C language
- `bool.h` is included in all files
- `print_int` and `print_char` functions

#### Not supported
- strings
- structs
- advanced char features
- Dynamic memory allocation