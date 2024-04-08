%{
#include "tree.h"

#include "tpc.tab.h"

int lineno = 1;
int colno = 1;
#define YY_USER_ACTION colno+=yyleng;
%}

%option noinput
%option nounput
%option noyywrap

%x COMMENT_SIMPLE
%x COMMENT_MULTILINES

%%

"="|"!"|";"|","|"("|")"|"{"|"}"|"["|"]"   { return yytext[0]; }

          
\'"\\"[ntrs]\'  { yylval.byte = yytext[2]; return CHARACTER; }     
'.'        { return CHARACTER; } 

[0-9]+     {yylval.num = atoi(yytext); return NUM; }


if         { return IF; }
else       { return ELSE; }
return     { return RETURN; }
while      { return WHILE; }

int|char   {strcpy(yylval.type, yytext); return TYPE; }
void       { return VOID; }

"=="|"!="  {strcpy(yylval.comp, yytext); return EQ; }
"<"|">"|"<="|">=" { strcpy(yylval.comp, yytext); return ORDER; }
"+"|"-"    { yylval.byte = yytext[0]; return ADDSUB; }   
"*"|"/"|"%" { yylval.byte = yytext[0]; return DIVSTAR; }
"||"       { return OR; }
"&&"       { return AND; }
[a-zA-Z]   { yylval.ident[0] = yytext[0]; yylval.ident[1] = '\0'; return IDENT; } //pour accepter une lettre 
[_a-zA-Z][_a-zA-Z0-9]* { strcpy(yylval.ident, yytext);  return IDENT; }


\n        { lineno++; colno = 1; }
[ \r\t]+                         ;
.        { return yytext[0]; }


"//" { BEGIN COMMENT_SIMPLE; }
<COMMENT_SIMPLE>. ;
<COMMENT_SIMPLE>\n { BEGIN INITIAL; lineno++; colno = 1; }

"/*" { BEGIN COMMENT_MULTILINES; }
<COMMENT_MULTILINES>\n { lineno++; colno = 1; }
<COMMENT_MULTILINES>. ;
<COMMENT_MULTILINES>"*/" { BEGIN INITIAL; }

%%