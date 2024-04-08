/* tree.h */
#ifndef __TREE_H__
#define __TREE_H__

#define FOREACH_LABEL(label) \
  label(programme)           \
  label(fonctions)           \
  label(variables)           \
  label(fonction)            \
  label(enTete)              \
  label(parametres)          \
  label(corps)               \
  label(declaration)         \
  label(var)                 \
  label(attribut)            \
  label(expression)          \
  label(instructions)         \
  label(or_op)               \
  label(and_op)              \
  label(NOT_OPERATOR)              \
  label(eq_op)               \
  label(addsub_op)           \
  label(divstar_op)          \
  label(order_op)            \
  label(while_loop)          \
  label(if_condition)        \
  label(else_condition)      \
  label(Return)            \
  label(void_v)              \
  label(type)                \
  label(returnType)          \
  label(ident)               \
  label(num)                 \
  label(character)           \
  label(FunctionName)        \
  label(ParameterList)       \
  label(Parameter)           \
  label(VariableDeclaration) \
  label(instruction)         \
  label(affectation)         \
  label(condition_if)        \
  label(condition_else)      \
  label(eq)                  \
  label(cond_while)                \
  label(ifElseCondition)     \
  label(whileLoop)           \
  label(order)               \
  label(fcall)              \
  label(arguments) \
  label(arrayIndexing) \
  label(unary_sign)   \
  label(NameVar) \
  label(Index) \
  label(NameFonct) \
  label(fonctionCall) \

#define GENERATE_ENUM(ENUM) ENUM,
#define GENERATE_STRING(STRING) #STRING,

typedef enum {
  FOREACH_LABEL(GENERATE_ENUM)

  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef struct Node {
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;
  char byte;
  int num;
  char ident[64];
  char comp[3];
  char type[30];
  int isArray;
  int arrayIndex;
  char arrayIndexExpr[64];
} Node;

Node *makeNode(label_t label);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);
void printNodeAttributes(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling

#endif