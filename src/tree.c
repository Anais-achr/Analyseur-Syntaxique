/* tree.c */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./tree.h"
extern int lineno;       /* from lexer */

static const char *StringFromLabel[] = {
    FOREACH_LABEL(GENERATE_STRING)
};

Node *makeNode(label_t label) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->label = label;
  node-> firstChild = node->nextSibling = NULL;
  node->lineno=lineno;
  return node;
}

void addSibling(Node *node, Node *sibling) {
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node);
}

void printTree(Node *node) {
    static bool rightmost[128];
    static int depth = 0;


    for (int i = 1; i < depth; i++) {
        printf(rightmost[i] ? "    " : "\u2502   ");
    }

    if (depth > 0) {
        printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
    }

    printf("%s", StringFromLabel[node->label]);

    // Affichage des attributs spécifiques du nœud
    printNodeAttributes(node);

    printf("\n");

    depth++;

    for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
        rightmost[depth] = (child->nextSibling) ? false : true;
        printTree(child);
    }

    depth--;
}

void printNodeAttributes(Node *node) {
    if (node->ident[0] != '\0') {
        if (node->ident[1] != '\0') {
            printf(" : %s", node->ident);
        } else {
            printf(" : %c", node->ident[0]);
        }
    } else if (node->type[0] != '\0') {
        printf(" : %s", node->type);
    } else if (node->label == num || node->label == Index) {
        printf(" : %d", node->num);
    }

    if (node->comp[0] != '\0') {
        printf(" : %s", node->comp);
    }

    if (node->byte != '\0') {
        printf(" : %c", node->byte);
    }

    if (node->isArray) {
        printf(" (Array)");
    }
}
