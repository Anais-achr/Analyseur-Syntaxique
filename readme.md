# Analyseur Syntaxique pour le Langage TPC

Cet analyseur syntaxique est conçu pour le langage TPC. Il permet d'analyser les fichiers source TPC et de générer un arbre abstrait.

## Installation
```sh 
make
```

## Utilisation
Pour produire l'executable :
```sh
./bin/tpcc [OPTIONS] [FICHIER]
```
## Options
    -h ou --help : Affiche un message d'aide
    -t ou --tree : Affiche l'arbre abstrait

## Exemple
```sh
./bin/tpcas -t < tests/good/global_varibale_declaration.tpc
```
## Nettoyage
Pour nettoyer les fichiers générés :
```sh
make clean
```


