%{
#include <stdio.h>
#include <stdlib.h>
#include "header/ast.h"

ASTNode* program = NULL;

int yylex(void);
void yyerror(const char *s);
%}

%token <ival> INTEGER
%token <sval> IDENTIFIER
%token <sval> STRING
%token ASSIGN PLUS INPUT OUTPUT SEMICOLON

%code requires {
    #include "header/ast.h"
}

%union {
    int ival;
    char* sval;
    ASTNode* node;
}

%type <node> program statement_list statement declaration_statement initialization_statement input_statement output_statement addition_statement expression term

%%

program:
    statement_list
    {
        program = $1; //originally $$
    }
    ;

statement_list:
    statement
    {
        $$ = $1;
    }
    | statement_list statement
    {
        addChild($1, $2);
        $$ = $1;
    }
    ;

statement:
    declaration_statement
    {
        $$ = $1;
    }
    | initialization_statement
    {
        $$ = $1;
    }
    | input_statement
    {
        $$ = $1;
    }
    | output_statement
    {
        $$ = $1;
    }
    | addition_statement
    {
        $$ = $1;
    }
    ;

declaration_statement:
    IDENTIFIER SEMICOLON
    {
        $$ = createASTNode("declaration", $1);
        free($1);
    }
    ;

initialization_statement:
    IDENTIFIER ASSIGN INTEGER SEMICOLON
    {
        char value[20];
        sprintf(value, "%d", $3);  // Convert integer to string
        $$ = createASTNode("initialization", $1);
        addChild($$, createASTNode("integer", value));
        free($1);
    }
    ;

input_statement:
    INPUT expression SEMICOLON
    {
        $$ = createASTNode("output", "");
        free($2);
    }

output_statement:
    OUTPUT expression SEMICOLON
    {
        $$ = createASTNode("output", "");
        addChild($$, $2);
    };


expression:
    term
    {
        $$ = $1;
    }
    | expression PLUS term
    {
        $$ = createASTNode("addition", "");
        addChild($$, $1);  // Left side of the addition
        addChild($$, $3);  // Right side of the addition
    }
    ;

term:
    IDENTIFIER
    {
        $$ = createASTNode("identifier", $1);
        free($1);
    }
    | INTEGER
    {
        char value[20];
        sprintf(value, "%d", $1);
        $$ = createASTNode("integer", value);
    }
    | STRING
    {
        $$ = createASTNode("string", $1);
        free($1);
    }
    ;

addition_statement:
    IDENTIFIER ASSIGN IDENTIFIER PLUS IDENTIFIER SEMICOLON
    {
        $$ = createASTNode("addition", $1);
        addChild($$, createASTNode("identifier", $3));
        addChild($$, createASTNode("identifier", $5));
        free($1);
        free($3);
        free($5);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
