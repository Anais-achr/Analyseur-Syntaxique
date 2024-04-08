%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int lineno, colno;

extern int yylex();
void yyerror(const char *msg); 
#include "tree.h"

Node *tree;
%}

%union {
    Node *node;
    char byte;
    int num;
    char ident[64];
    char comp[3];
    char type[30];
}

%type <node> Prog DeclVars DeclFoncts DeclFonct EnTeteFonct Parametres ListTypVar Corps SuiteInstr Instr Exp TB FB M E T F LValue Arguments ListExp Declarateurs
%token <byte> CHARACTER ADDSUB DIVSTAR
%token <num> NUM
%token <ident> IDENT
%token <comp> ORDER EQ
%token <type> TYPE
%token OR
%token AND
%token WHILE RETURN IF ELSE VOID
%expect 4

%%
Prog:  DeclVars DeclFoncts{
    $$ = makeNode(programme);
    Node* var = makeNode(variables);
    Node* foncts = makeNode(fonctions);
    /*on ajoute la declaration de variable et de fonctions à Prog*/
    addChild($$, var);
    addChild($$, foncts);

    addChild(var, $1);
    addChild(foncts, $2);
    tree = $$;
}
    ;
DeclVars:
    DeclVars TYPE Declarateurs ';'{
        Node* declarationVar = makeNode(VariableDeclaration);
        Node* typeVar = makeNode(type);
        strcpy(typeVar->type, $2); 
        addChild(declarationVar, typeVar);
        
        if($1 == NULL){ //on doit verifier que la liste des variable est nulle ou pas
            $$ = declarationVar; //si c'est le cas on doit l'initialiser
        }else{
            addSibling($$, declarationVar); //sinon on ajoute 
        }
        
        addChild(declarationVar, $3);
    }
    | {$$ = NULL;} 
    ;
Declarateurs:
       Declarateurs ',' IDENT {
        $$ = $1;
        Node* identificateur = makeNode(NameVar);
        strcpy(identificateur->ident, $3);
        addSibling($$, identificateur);

       }
    |  IDENT '[' NUM ']' {
        $$ = makeNode(NameVar);
        strcpy($$->ident, $1);
        $$->isArray = 1; 

        Node* index_arr = makeNode(Index);
        index_arr->num = $3;

        addChild($$, index_arr);
        }
    |  IDENT {
        $$ = makeNode(NameVar);
        strcpy($$->ident, $1);
        }
    ;
DeclFoncts:
   DeclFoncts DeclFonct {
      $$ = $1;
      Node* declarationFoncts = makeNode(fonction);
      addSibling($$, declarationFoncts);
      addChild(declarationFoncts, $2);
   }
   | DeclFonct {
      $$ = makeNode(fonction);
      addChild($$, $1);
   }
   ;
DeclFonct:
   EnTeteFonct Corps {
      $$ = makeNode(enTete);
      addChild($$, $1);
      addSibling($$, $2);
   }
   ;
EnTeteFonct:
    TYPE IDENT '(' Parametres ')' {
        $$ = makeNode(returnType);
        strcpy($$->type, $1);

        Node *identificateur = makeNode(FunctionName);
        strcpy(identificateur->ident, $2);
        addSibling($$, identificateur);

        Node *parametres_fonction = makeNode(ParameterList);
        addSibling($$, parametres_fonction);

        addChild(parametres_fonction, $4); /* on ajoute le contenu de parametres_fonction à Parametres */
    }
    | VOID IDENT '(' Parametres ')' {
        $$ = makeNode(returnType);
        strcpy($$->type, "void");

        Node *identificateur = makeNode(FunctionName);
        addSibling($$, identificateur);
        strcpy(identificateur->ident, $2);

        Node *parametres_fonction = makeNode(ParameterList);
        addSibling($$, parametres_fonction);

        //addChild(parametres_fonction, $4); /* on ajoute le contenu de parametres_fonction à Parametres */
    }
    ;

Parametres:
       VOID { 
        $$ = NULL;
        }
    |  ListTypVar { $$ = $1; }
    | { $$ = NULL; }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT '[' ']' {
        Node* param = makeNode(Parameter);

        Node* type_var = makeNode(type);
        Node* ident_var = makeNode(NameVar);
        param->isArray = 1;
        strcpy(type_var->type, $3);
        strcpy(ident_var->ident, $4);

        addChild(param, type_var);
        addChild(param, ident_var);

        if ($$ == NULL) {
            $$ = param;
        } else {
            addSibling($$, param);
        }
       }
    | ListTypVar ',' TYPE IDENT {
        Node* param = makeNode(Parameter);

        Node* type_var = makeNode(type);
        Node* ident_var = makeNode(NameVar);
        strcpy(type_var->type, $3);
        strcpy(ident_var->ident, $4);

        addChild(param, type_var);
        addChild(param, ident_var);

        if ($$ == NULL) {
            $$ = param;
        } else {
            addSibling($$, param);
        }
    }
    |  TYPE IDENT '[' ']' {
        Node* param = makeNode(Parameter);
        Node* type_var = makeNode(type);
        Node* ident_var = makeNode(NameVar);

        param->isArray = 1;
        strcpy(type_var->type, $1);
        strcpy(ident_var->ident, $2);

        addChild(param, type_var);
        addChild(param, ident_var);

        $$ = param;
    }
    |  TYPE IDENT {
        Node* param = makeNode(Parameter);
        Node* type_var = makeNode(type);
        Node* ident_var = makeNode(NameVar);

        strcpy(type_var->type, $1);
        strcpy(ident_var->ident, $2);

        addChild(param, type_var);
        addChild(param, ident_var);

        $$ = param;
    }
    ;
Corps: '{' DeclVars SuiteInstr '}' {
        $$ = makeNode(corps);
        Node* var_foncts = makeNode(variables);
        Node* instruction_foncts = makeNode(instructions);

        addChild(var_foncts, $2);
        addChild(instruction_foncts, $3);
        addChild($$, var_foncts);
        addChild($$, instruction_foncts);

    }   
    ;
SuiteInstr:
    SuiteInstr Instr {
        if ($$ == NULL) {
            $$ = $2;
        }else{
            addSibling($$, $2);
        }
    }
        
    | { $$ = NULL; }
    ;
Instr:
       LValue '=' Exp ';' {
        $$ = makeNode(affectation);
        $$->byte = '=';
        addChild($$, $1);
        addChild($$, $3);

       }
    |  IF '(' Exp ')' Instr {
        $$ = makeNode(condition_if);
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IF '(' Exp ')' Instr ELSE Instr {
        $$ = makeNode(ifElseCondition);

        //condition if
        Node* if_cond = makeNode(condition_if);
        addChild(if_cond, $3);
        addChild(if_cond, $5);

        //condition else
        Node* else_cond = makeNode(condition_else);
        addChild(else_cond, $7);

        //on rajoute les noeuds if et else 
        addChild($$, if_cond);
        addChild($$, else_cond);
    }
    |  WHILE '(' Exp ')' Instr {
        $$ = makeNode(while_loop);

        //condition du while
        Node* while_cond = makeNode(cond_while);
        addChild(while_cond, $3);

        addChild($$, while_cond);
        addChild($$, $5);
    }
    |  IDENT '(' Arguments  ')' ';' {
        
        $$ = makeNode(fonctionCall);

        Node* ident_call = makeNode(NameFonct);
        strcpy(ident_call->ident, $1);

        Node* args = makeNode(arguments);
        addChild(args, $3);

        addChild($$, ident_call);
        addChild($$, args);
    }
    |  IDENT '[' IDENT ']'{
        $$ = makeNode(arrayIndexing);
        $$->isArray = 1;
        Node* ident_call = makeNode(NameVar);

        strcpy(ident_call->ident, $1);
        strcpy(ident_call->arrayIndexExpr, $3);

        addChild($$, ident_call);
        
    }
    |  IDENT '[' Exp ']'{
        $$ = makeNode(arrayIndexing);
        $$->isArray = 1;
        Node* ident_call = makeNode(NameVar);

        strcpy(ident_call->ident, $1);
        addChild($$, ident_call);
        addChild($$, $3);

    }
    |  RETURN Exp ';' {
        $$ = makeNode(Return);
        addChild($$, $2);
    }
    |  RETURN ';' { $$ = makeNode(Return);}
    |  '{' SuiteInstr '}' {
        $$ = makeNode(instructions);
        addChild($$, $2);
    }
    |  ';' { $$ = NULL; }
    ;
Exp :  Exp OR TB { 
        $$ = makeNode(or_op);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  TB { $$ = $1; }
    ;
TB  :  TB AND FB{
        $$ = makeNode(and_op);
        addChild($$, $1);
        addChild($$, $3);
    }   
    |  FB { $$ = $1; }
    ;
FB  :  FB EQ M {
        $$ = makeNode(eq);
        strcpy($$->comp, $2);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  M { $$ = $1; }
    ;
M   :  M ORDER E {
        $$ = makeNode(order);
        strcpy($$->comp, $2);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  E { $$ = $1; }
    ;
E   :  E ADDSUB T {
        $$ = makeNode(addsub_op);
        $$->byte = $2;
        addChild($$, $1);
        addChild($$, $3);
    }
    |  T { $$ = $1; }
    ;    
T   :  T DIVSTAR F {
        $$ = makeNode(divstar_op);
        $$->byte = $2;
        addChild($$, $1);
        addChild($$, $3);
    }
    |  F { $$ = $1; }
    ;
F   :  ADDSUB F {
        $$ = makeNode(unary_sign);
        $$->byte = $1;
        addChild($$, $2);
    }
    |  '!' F {
        $$ = makeNode(NOT_OPERATOR);
        $$->byte = '!';
        addChild($$, $2);
    }
    |  '(' Exp ')' { $$ = $2; }
    |  NUM {
        $$ = makeNode(num);
        $$->num = $1;
    }
    |  CHARACTER {
        $$ = makeNode(character);
        $$->byte = $1;
    }
    |  LValue { $$ = $1; }
    |  IDENT '(' Arguments  ')' {
        $$ = makeNode(fonctionCall);

        Node *foncts = makeNode(FunctionName);
        strcpy(foncts->ident, $1);

        Node* args = makeNode(arguments);
        addChild(args, $3);

        addChild($$, foncts);
        addChild($$, args);
    }
    ;
LValue:
       IDENT {
        $$ = makeNode(NameVar);
        strcpy($$->ident, $1);
       }
    |  IDENT '[' IDENT ']' {
        $$ = makeNode(NameVar);
        strcpy($$->ident, $1);
        $$->isArray = 1;
        
        Node* array_index = makeNode(Index);
        strcpy(array_index->ident, $3);

        addChild($$, array_index);
        }
    |  IDENT '[' Exp ']' {
        $$ = makeNode(NameVar);
        $$->isArray = 1;
        strcpy($$->ident, $1);
        addChild($$, $3);
    }
    |  IDENT '[' NUM ']' {
        $$ = makeNode(NameVar);
        strcpy($$->ident, $1);
        $$->isArray = 1;


        Node* index_array = makeNode(Index);
        index_array->num = $3;

        addChild($$, index_array);
    }
    ;
Arguments:
       ListExp { $$ = $1; }
    | { $$ = NULL; }
    ;
ListExp:
       ListExp ',' Exp {
            $$ = $1;    
            addSibling($$, $3);
       }
    |  Exp { $$ = $1; }
    ;


%%
int displayTree = 0;

void printHelp() {
    printf("Usage: tpcas [OPTIONS] FILE.tpc\n");
    printf("Options:\n");
    printf("  -t, --tree\tAfficher l'arbre de syntaxe abstraite.\n");
    printf("  -rep, --rapport\tAfficher le rapport.\n");
    printf("  -h, --help\tAfficher ce message d'aide.\n");
}


int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            printHelp();
            return 0;
        } else if (strcmp(argv[i], "-t") == 0 || strcmp(argv[i], "--tree") == 0) {
            displayTree = 1;
        } else if (strcmp(argv[i], "-rep") == 0 || strcmp(argv[i], "--rapport") == 0) {
            if (system("xdg-open rep/rapport.pdf") != 0 && 
                system("open rep/rapport.pdf") != 0 &&
                system("start rep/rapport.pdf") != 0) { 
                // If PDF viewer is not found, try with web browsers
                if (system("firefox rep/rapport.pdf") != 0 &&
                    system("google-chrome rep/rapport.pdf") != 0 &&
                    system("chromium-browser rep/rapport.pdf") != 0) {
                    fprintf(stderr, "Error: Impossible d'ouvrir le rapport.\n");
                }
            }
            return 0;
        }
    }

    // Parsing logic
    int res = yyparse();
    if (res == 0 && displayTree) {
        printTree(tree);
    }

    if (res == 0) {
        deleteTree(tree);
    }

    return res;
}


void yyerror(const char *msg){
    fprintf(stderr, "Erreur : l%d:c%d -> %s\n", lineno, colno, msg);
}