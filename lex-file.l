%option noyywrap
%{
 
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}
 
LETTER [A-Za-z]
DIGIT [0-9]

IF "if"
ELSE "else"
WHILE "while"
FOR "for"
DO "do"
SWITCH "switch"
CASE "case"
DEFAULT "default"

 
%%
{LETTER} {strcpy(yylval.id,yytext);
return LETTER;}
{DIGIT}+"."{DIGIT}+ {strcpy(yylval.id,yytext);
return FLOAT;}
{DIGIT}+ {strcpy(yylval.id,yytext);
return INTEGER;}

{IF} {return IF;}
{FOR} {return FOR;}
{ELSE} {return ELSE;}
{WHILE} {return WHILE;}
{DO} {return DO;}
{SWITCH} {return SWITCH;}
{CASE} {return CASE;}
{DEFAULT} {return DEFAULT;}
[ \n\t]* ;
. {return yytext[0];}
%%
