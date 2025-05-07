#ifndef HEADER_H
#define HEADER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Structure for three address code
typedef struct ThreeAddressCode {
    char* op;
    char* arg1;
    char* arg2;
    char* result;
    struct ThreeAddressCode* next;
} ThreeAddressCode;

// Structure for symbol table entry
typedef struct {
    char* name;
    int value;
} Symbol;

// Global variables
extern FILE* yyin;
extern int yylex();
extern int yyparse();
extern void yyerror(const char* s);
extern Symbol symbols[100];
extern int symbol_count;
extern ThreeAddressCode* code_head;
extern int temp_var_counter;

// Function declarations
char* new_temp_var();
void add_three_address_code(char* op, char* arg1, char* arg2, char* result);
void print_three_address_code();
int get_symbol_value(char* name);
void set_symbol_value(char* name, int value);

#endif