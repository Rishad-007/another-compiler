#include "header.h"

void print_three_address_code() {
    ThreeAddressCode* current = code_head;
    printf("\nThree Address Code:\n");
    printf("------------------\n");
    while (current != NULL) {
        if (strcmp(current->op, "label") == 0) {
            printf("%s:\n", current->result);
        } else if (strcmp(current->op, "goto") == 0) {
            printf("goto %s\n", current->result);
        } else if (strcmp(current->op, "ifFalse") == 0) {
            printf("if %s == false goto %s\n", current->arg1, current->arg2);
        } else if (strcmp(current->op, "=") == 0) {
            printf("%s = %s\n", current->result, current->arg1);
        } else {
            printf("%s = %s %s %s\n", current->result, current->arg1, current->op, current->arg2);
        }
        current = current->next;
    }
}

int get_symbol_value(char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            return symbols[i].value;
        }
    }
    return 0;
}

void set_symbol_value(char* name, int value) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            symbols[i].value = value;
            return;
        }
    }
    symbols[symbol_count].name = strdup(name);
    symbols[symbol_count].value = value;
    symbol_count++;
}

int main() {
    // Open input file
    FILE* input = fopen("input.txt", "r");
    if (!input) {
        printf("Error: Cannot open input.txt\n");
        return 1;
    }
    yyin = input;

    // Parse input
    yyparse();

    // Print three address code
    print_three_address_code();

    // Cleanup
    fclose(input);
    return 0;
}