%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
void yyerror(char *);
int yylex(void);
extern FILE *yyin;
extern int linenum;
char writeBuffer[6000];
FILE *outputFile;
void openFile(char*);
void writeLinetoFile(char*);
void closeFile();
%}
%union
{
char *string;
int number;
}
%token ECHO WHILE DO DONE THEN FI ELSEIF ELSE DOLLAR ASSIGNOP OPENPAR CLOSEPAR OPENBRA CLOSEBRA
%token <string> SHIDE VARIABLE COMMENT ADD DIV MULT SUB IF GREATER GREATEROREQ EQUAL LESSER LESSEROREQ STRING
%token <number> INTEGER
%type <string> statement statements assign_statement print_statement conditional_statement comment_statement terms ops elseif_statements compare expressions shell_check
%%

begin:
    statements
    {sprintf(writeBuffer,"%s",$1);writeLinetoFile(writeBuffer);}

statements:
    statement statements
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($2)+10));
    sprintf($$,"%s%s", $1,$2);}
    |
    statement
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    ;

statement:
    shell_check
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    comment_statement
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s\n", $1);}
    |
    assign_statement
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    conditional_statement
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    print_statement
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    ;

shell_check:
    SHIDE
    {sprintf($$,"\n");}
    ;

comment_statement:
    COMMENT
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s\n", $1);}
    ;

print_statement:
    ECHO STRING
    {$$=malloc(sizeof(char)*(strlen($2)+100));
    sprintf($$,"print %s . \"\\n\"; \n", $2);}
    |
    ECHO terms
    {$$=malloc(sizeof(char)*(strlen($2)+100));
    sprintf($$,"print %s . \"\\n\"; \n", $2);}
    |
    ECHO DOLLAR OPENPAR OPENPAR expressions CLOSEPAR CLOSEPAR
    {$$=malloc(sizeof(char)*(strlen($5)+100));
    sprintf($$,"print %s . \"\\n\"; \n", $5);}
terms:
    INTEGER
    {$$=malloc(sizeof(int)*7);
    sprintf($$,"%d", $1);}
    |
    VARIABLE
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"$%s", $1);}
    |
    DOLLAR VARIABLE
    {$$=malloc(sizeof(char)*(strlen($2)+10));
    sprintf($$,"$%s", $2);}
    ;
expressions:
    terms
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    expressions ops expressions
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+10));
    sprintf($$,"%s%s%s", $1, $2, $3);}
    |
    OPENPAR expressions ops expressions CLOSEPAR
    {$$=malloc(sizeof(char)*(strlen($2)+strlen($3)+strlen($4)+10));
    sprintf($$,"(%s%s%s)", $2, $3, $4);}
    ;
ops:
    ADD
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    SUB
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    MULT
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    |
    DIV
    {$$=malloc(sizeof(char)*(strlen($1)+10));
    sprintf($$,"%s", $1);}
    ;
conditional_statement:
    IF OPENBRA terms compare terms CLOSEBRA THEN statements FI
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($3)+strlen($4)+strlen($5)+strlen($8)+50));
    sprintf($$,"%s (%s %s %s){\n%s} \n", $1, $3, $4, $5, $8);}
    |
    IF OPENBRA terms compare terms CLOSEBRA THEN statements ELSE statements FI
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($3)+strlen($4)+strlen($5)+strlen($8)+strlen($10)+50));
    sprintf($$,"%s (%s %s %s){\n%s} else {\n%s}\n", $1, $3, $4, $5, $8, $10);}
    |
    IF OPENBRA terms compare terms CLOSEBRA THEN statements elseif_statements FI
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($3)+strlen($4)+strlen($5)+strlen($8)+strlen($9)+50));
    sprintf($$,"%s (%s %s %s){\n%s} %s \n", $1, $3, $4, $5, $8, $9);}
    |
    IF OPENBRA terms compare terms CLOSEBRA THEN statements elseif_statements ELSE statements FI
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($3)+strlen($4)+strlen($5)+strlen($8)+strlen($9)+strlen($11)+50));
    sprintf($$,"%s (%s %s %s){\n%s} %s else {\n %s} \n", $1, $3, $4, $5, $8, $9, $11);}
    ;

elseif_statements:
    ELSEIF OPENBRA terms compare terms CLOSEBRA THEN statements
    {$$=malloc(sizeof(char)*(strlen($3)+strlen($4)+strlen($5)+strlen($8)+50));
    sprintf($$,"elsif (%s %s %s) {\n %s} ", $3, $4, $5, $8);}
    |
    ELSEIF OPENBRA terms compare terms CLOSEBRA THEN statements elseif_statements
    {$$=malloc(sizeof(char)*(strlen($3)+strlen($4)+strlen($5)+strlen($8)+strlen($9)+50));
    sprintf($$,"elsif (%s %s %s) {\n%s} %s \n", $3, $4, $5, $8, $9);}
    ;
compare:
    GREATER
    {sprintf($$,">");}
    |
    GREATEROREQ
    {sprintf($$,">=");}
    |
    EQUAL
    {sprintf($$,"==");}
    |
    LESSER
    {sprintf($$,"<");}
    |
    LESSEROREQ
    {sprintf($$,"<=");}
    ;
assign_statement:
    VARIABLE ASSIGNOP terms
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($3)+10));
    sprintf($$,"$%s=%s;\n", $1,$3);}
    |
    VARIABLE ASSIGNOP DOLLAR OPENPAR OPENPAR expressions CLOSEPAR CLOSEPAR
    {$$=malloc(sizeof(char)*(strlen($1)+strlen($6)+10));
    sprintf($$,"$%s=%s;\n", $1,$6);}
    ;
%%

void openFile(char* fileName){
  outputFile=fopen(fileName,"w");
}

void writeLinetoFile(char* str){
  fprintf(outputFile,"%s",str);
}

void closeFile(){
  fclose(outputFile);
}

void yyerror(char *s){
  fprintf(stderr,"Error at line: %d\n",linenum);
}
int yywrap(){
  return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    openFile("out.pl");
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    closeFile();
    return 0;
}