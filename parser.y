%{
#include "header.h"

Symbol symbols[100];
int symbol_count = 0;
ThreeAddressCode* code_head = NULL;
int temp_var_counter = 0;

void yyerror(const char* s);
%}

%union {
    int num;
    char* id;
    struct {
        char* code;
        char* addr;
    } expr;
}

%token <num> NUMBER
%token <id> ID
%token PLUS MINUS MULT DIV
%token ASSIGN EQ LT GT
%token IF ELSE FOR
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON

%type <expr> expr stmt stmt_list if_stmt for_stmt

%%

program: stmt_list
       ;

stmt_list: stmt
        | stmt_list stmt
        ;

stmt: ID ASSIGN expr SEMICOLON {
        add_three_address_code("=", $3.addr, "", $1);
    }
    | if_stmt
    | for_stmt
    ;

if_stmt: IF LPAREN expr RPAREN LBRACE stmt_list RBRACE {
        char* label = new_temp_var();
        add_three_address_code("ifFalse", $3.addr, label, "");
    }
    | IF LPAREN expr RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE {
        char* label1 = new_temp_var();
        char* label2 = new_temp_var();
        add_three_address_code("ifFalse", $3.addr, label1, "");
        add_three_address_code("goto", "", "", label2);
        add_three_address_code("label", "", "", label1);
    }
    ;

for_stmt: FOR LPAREN ID ASSIGN expr SEMICOLON expr SEMICOLON ID ASSIGN expr RPAREN LBRACE stmt_list RBRACE {
        char* start_label = new_temp_var();
        char* end_label = new_temp_var();
        add_three_address_code("=", $5.addr, "", $3);
        add_three_address_code("label", "", "", start_label);
        add_three_address_code("ifFalse", $7.addr, end_label, "");
        add_three_address_code("=", $11.addr, "", $9);
        add_three_address_code("goto", "", "", start_label);
        add_three_address_code("label", "", "", end_label);
    }
    ;

expr: NUMBER {
        char temp[20];
        sprintf(temp, "%d", $1);
        $$.addr = strdup(temp);
    }
    | ID {
        $$.addr = $1;
    }
    | expr PLUS expr {
        $$.addr = new_temp_var();
        add_three_address_code("+", $1.addr, $3.addr, $$.addr);
    }
    | expr MINUS expr {
        $$.addr = new_temp_var();
        add_three_address_code("-", $1.addr, $3.addr, $$.addr);
    }
    | expr MULT expr {
        $$.addr = new_temp_var();
        add_three_address_code("*", $1.addr, $3.addr, $$.addr);
    }
    | expr DIV expr {
        $$.addr = new_temp_var();
        add_three_address_code("/", $1.addr, $3.addr, $$.addr);
    }
    | expr LT expr {
        $$.addr = new_temp_var();
        add_three_address_code("<", $1.addr, $3.addr, $$.addr);
    }
    | expr GT expr {
        $$.addr = new_temp_var();
        add_three_address_code(">", $1.addr, $3.addr, $$.addr);
    }
    | expr EQ expr {
        $$.addr = new_temp_var();
        add_three_address_code("==", $1.addr, $3.addr, $$.addr);
    }
    | LPAREN expr RPAREN {
        $$.addr = $2.addr;
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}

char* new_temp_var() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", temp_var_counter++);
    return temp;
}

void add_three_address_code(char* op, char* arg1, char* arg2, char* result) {
    ThreeAddressCode* code = malloc(sizeof(ThreeAddressCode));
    code->op = strdup(op);
    code->arg1 = strdup(arg1);
    code->arg2 = strdup(arg2);
    code->result = strdup(result);
    code->next = NULL;

    if (code_head == NULL) {
        code_head = code;
    } else {
        ThreeAddressCode* current = code_head;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = code;
    }
}