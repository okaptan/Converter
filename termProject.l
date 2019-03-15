%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int linenum;
%}
%%
"#!/bin/sh" {yylval.string = strdup(yytext); return SHIDE;}
"echo" return ECHO;
"#".* {yylval.string = strdup(yytext); return COMMENT;}
"while" return WHILE;
"do" return DO;
"done" return DONE;
"if" {yylval.string = strdup(yytext); return IF;}
"then" return THEN;
"fi" return FI;
"-gt" {yylval.string = strdup(yytext); return GREATER;};
"-ge" {yylval.string = strdup(yytext); return GREATEROREQ;}
"-eq" {yylval.string = strdup(yytext); return EQUAL;}
"-lt" {yylval.string = strdup(yytext); return LESSER;}
"-le" {yylval.string = strdup(yytext); return LESSEROREQ;}
"elif" return ELSEIF;
"else" return ELSE;
[A-Za-z]([A-Za-z]|[0-9])* {yylval.string = strdup(yytext); return VARIABLE;}
[0-9]+ {yylval.number = atoi(yytext); return INTEGER;}
(\"([^"])*\")|(\'([^']).*\') {yylval.string = strdup(yytext); return STRING;}
"$" return DOLLAR;
"=" return ASSIGNOP;
"(" return OPENPAR;
")" return CLOSEPAR;
"[" return OPENBRA;
"]" return CLOSEBRA;
"+" {yylval.string = strdup(yytext); return ADD;}
"/" {yylval.string = strdup(yytext); return DIV;}
"*" {yylval.string = strdup(yytext); return MULT;}
"-" {yylval.string = strdup(yytext); return SUB;}
\n    {linenum++;}
[ \t]+
%%
