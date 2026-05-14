%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STR_LEN 1024

char string_buf[MAX_STR_LEN + 1];
int  string_len;
int  string_error;

int br_integera = 0;
int br_stringova = 0;
int line_comment = 0;
int mline_comment = 0;   /* ukupan broj multiline komentara */
int comment_depth = 0;   /* trenutna dubina ugnjezdavanja  */
%}

%x STRING
%x LINE_COMMENT
%x MLINE_COMMENT

%%

[0-9]+  {
            br_integera++;
            printf("INT_CONST: %s\n", yytext);
        }

"\""    {
            // Pocetak stringa
            string_len   = 0;
            string_error = 0;
            BEGIN(STRING);
        }

"--"    {
            // Pepoznat komentar u jednoj liniji
            BEGIN(LINE_COMMENT);
        }      

"(*"    {
            comment_depth = 0;
            BEGIN(MLINE_COMMENT);
        }

(?i:class)      { printf("CLASS\n"); }
(?i:else)       { printf("ELSE\n"); }
(?i:fi)         { printf("FI\n"); }
(?i:if)         { printf("IF\n"); }
(?i:in)         { printf("IN\n"); }
(?i:inherits)   { printf("INHERITS\n"); }
(?i:isvoid)     { printf("ISVOID\n"); }
(?i:let)        { printf("LET\n"); }
(?i:loop)       { printf("LOOP\n"); }
(?i:pool)       { printf("POOL\n"); }
(?i:then)       { printf("THEN\n"); }
(?i:while)      { printf("WHILE\n"); }
(?i:case)       { printf("CASE\n"); }
(?i:esac)       { printf("ESAC\n"); }
(?i:new)        { printf("NEW\n"); }
(?i:of)         { printf("OF\n"); }
(?i:not)        { printf("NOT\n"); }
t(?i:rue)       { printf("BOOL_CONST: true\n"); }
f(?i:alse)      { printf("BOOL_CONST: false\n"); }


<STRING>{
    "\""      {
                // Kraj stringa
                BEGIN(INITIAL);
                if (!string_error) {
                    string_buf[string_len] = '\0';
                    br_stringova++;
                    printf("STR_CONST: \"%s\"\n", string_buf);
                }
            }

    <<EOF>> {
                
                BEGIN(INITIAL);
                if (!string_error)
                    printf("ERROR: EOF in string constant\n");
            }

    "\n"      {
                // Kraj stringa, ako nemamo znaka navoda onda greska
                BEGIN(INITIAL);
                if (!string_error)
                    printf("ERROR: Unterminated string constant\n");
            }

    "\\\n"    {
                // U pravilima imamo skevencu kada ubacimo \ i posle njega treba
                // u stringu da ide novi red, to je legalno, u rezultat se samo
                // ubaci novi red i tjt
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = '\n';
                    }
                }
            }

    "\\b"     {
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = '\b';
                    }
                }
            }
    "\\t"     {
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = '\t';
                    }
                }
            }
    "\\n"     {
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = '\n';
                    }
                }
            }
    "\\f"     {
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = '\f';
                    }
                }
            }
    "\\0"     {
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = '0';
                    }
                }
            }

    \\.     {
                // Pretstavlja sekvencu \c, gdje je c neki karakter
                // Onda se u finalnom stringu samo zamijeni sa ovim karakterom
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = yytext[1];
                    }
                }
            }

    "\0"      {
                // Ako naidje na null karakter pretvara ga u gresku
                if (!string_error) {
                    string_error = 1;
                    printf("ERROR: String contains null character\n");
                }
            }

    .       {
                if (!string_error) {
                    if (string_len >= MAX_STR_LEN) {
                        string_error = 1;
                        printf("ERROR: String constant too long\n");
                    } else {
                        string_buf[string_len++] = yytext[0];
                    }
                }
            }
}

<LINE_COMMENT>{
        "\n"    {
                    // ako naidjemo na novi red dodajemo terminacioni na kraj i stampa
                    BEGIN(INITIAL);
                    line_comment++;
                }
        <<EOF>> {
                    // ako je na kraju eof, slicna prica kao prije
                    BEGIN(INITIAL);
                    line_comment++;
                }

        .       {
                
                }

              }

<MLINE_COMMENT>{
        "(*"     { comment_depth++; }
        "*)"     {
                    if (comment_depth > 0)
                        comment_depth--;
                    else {
                        BEGIN(INITIAL);
                        mline_comment++;
                    }
                 }
        <<EOF>>  {
                    BEGIN(INITIAL);
                    printf("ERROR: EOF in comment\n");
                 }
        "\n"     { }
        .        { }
               }


[A-Z][a-zA-Z0-9_]*  { printf("TYPEID: %s\n", yytext); }
[a-z][a-zA-Z0-9_]*  { printf("OBJECTID: %s\n", yytext); }

"<-"    { printf("ASSIGN\n"); }
"<="    { printf("LE\n"); }
"=>"    { printf("DARROW\n"); }
"+"     { printf("PLUS\n"); }
"-"     { printf("MINUS\n"); }
"*"     { printf("MULT\n"); }
"/"     { printf("DIV\n"); }
"~"     { printf("NEG\n"); }
"<"     { printf("LT\n"); }
"="     { printf("EQ\n"); }
"."     { printf("DOT\n"); }
"@"     { printf("AT\n"); }
","     { printf("COMMA\n"); }
";"     { printf("SEMI\n"); }
":"     { printf("COLON\n"); }
"("     { printf("LPAREN\n"); }
")"     { printf("RPAREN\n"); }
"{"     { printf("LBRACE\n"); }
"}"     { printf("RBRACE\n"); }

"*)"    { printf("ERROR: Unmatched *)\n"); }

[ \t\n\r\f\v]   { }

.   { printf("ERROR: invalid character '%s'\n", yytext); }

%%

int main(){
    yylex();
    printf("Broj integera: %d\n", br_integera);
    printf("Broj stringova: %d\n", br_stringova);
    printf("Broj komentara u jednoj liniji je %d\n", line_comment);
    printf("Broj multi line komentara: %d\n", mline_comment);
    return 0;
}
