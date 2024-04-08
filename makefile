EXEC=tpcas
CC=gcc
CFLAGS=-Wall -g
LDFLAGS= -ll -lfl

BIN_DIR=bin/
OBJ_DIR=obj/
SRC_DIR=src/

SRC=$(addprefix $(SRC_DIR), lex.yy.c tpc.tab.c tree.c)
OBJ=$(addprefix $(OBJ_DIR), lex.yy.o tpc.tab.o tree.o)


$(BIN_DIR)$(EXEC): $(OBJ)
	mkdir -p $(BIN_DIR)
	$(CC) -o $(BIN_DIR)$(EXEC) $(CFLAGS) $(OBJ) $(LDFLAGS)

$(OBJ_DIR)%.o: $(SRC_DIR)%.c
	mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRC_DIR)lex.yy.c: $(SRC_DIR)tpc.lex $(SRC_DIR)tpc.tab.h
	flex -o $@ $(SRC_DIR)tpc.lex

$(SRC_DIR)tpc.tab.c $(SRC_DIR)tpc.tab.h: $(SRC_DIR)tpc.y $(SRC_DIR)tree.h
	bison -d -o $(SRC_DIR)tpc.tab.c $(SRC_DIR)tpc.y 

clean:
	rm -f  $(BIN_DIR)$(EXEC) $(OBJ) $(SRC_DIR)lex.yy.c $(SRC_DIR)tpc.tab.c $(SRC_DIR)tpc.tab.h
	rm -d $(OBJ_DIR)
	rm -d $(BIN_DIR)
