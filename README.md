# abdorohmang-pariat-pprog-2024



# Projet jeu de plateforme en Ocaml
Le but du projet va être de créer un jeu de plateforme en 2d à la manière de Shovel Knight en OCaml. Le joueur pourra contrôler un personnage pour parcourir différentes plateformes en affrontant des ennemis et en ramassant des objets.
Toute la problématique réside dans le fait de réussir à le faire en ocaml, qui est un language qu'on a jamais utilisé pour faire ce style de projet (on l'a fait en Java).

## Objectif
Faire un jeu avec plusieurs niveaux variés, plusieurs objets/bonus, plusieurs ennemis. Les niveaux ont une fin que le joueur doit atteindre pour passer au niveau suivant.

## Objectifs intermédiaires

Créer les Objets et l'environnement et définir leurs propriétés : le joueur, les plateformes, les objets/bonus, les ennemies.

Créer les interactions entre objets : comment les platformes sont générés, comment le joueur interagit avec elles, les sauts du joueur, comment le joueur tue les ennemis, comment le niveau se termine ...

Créer un rendu graphique : Créer une interface de jeu et un menu, afficher les sprites, les animations du personnage, et les éléments de l'environnement (plateformes, ennemies) En utilisant des bibliothèques graphiques d'ocaml.

Créer plusieurs niveaux avec une difficulté croissante.

Créer un systeme de score (rapidité à finir le niveau, nb d'ennemies tués ...) pour pouvoir battre son score précédent.

## Objectifs supplémentaires

Mode multijoueurs pour pouvoir faire des niveaux à 2.

Mode où la caméra bouge : le joueur doit rester dans le champ de vision de la caméra sinon la partie se termine.

Ajouter du son pour l'ambiance du jeu

## Testabilité

Nous ferons des niveaux de test les plus simples possible pour pouvoir tester notre projet au fur et à mesure de notre avancée (niveau avec une plateforme toute plate par exemple)

Autres exemples de tests: tester les collisions, la physique du jeu, les deplacements, le comportement des ennemies etc.

A partir de tests unitaires.

## Pourquoi ce n'est pas un simple collage d'API ?

Hormis pour la partie visuelle du jeu, nous n'utiliserons pas de bibliothèques externes pour ce projet. Toute la logique du jeu et les interactions avec l'environnement seront codés manuellement.

## Calendrier
les dates associées aux étapes sont approximatives et peuvent évoluer

|Etape|Date fin de la tache|
|-----|--------------------|
|Réflechir à la structure de notre projet et se refamiliariser avec ocaml|Novembre 2024|
|Créer les Objets et l'environnement et définir leurs propriétés : le joueur, les plateformes, les objets/bonus, les ennemies. Structurer le modèle. Commencer à travailler la vue|fin du semestre 1|
|Créer les interactions entre objets : comment le joueur interagit avec les plateformes, les sauts du joueur, avoir une vue qui marche avec une bonne gestion de la caméra, les sprites du joueur et de la map, une première plateforme|fin janvier/ début février|
|Implémenter différent types d'objets, d'ennemies et de blocs (exemples : échelles), en les testant sur des map vides. Créer le système d'attaque du jeu (attaque sauté, corps à corps etc ...).|fin février|
|Implémenter des animations (courir, sauté, attaquer) pour le joueur et les ennemies. Gérer les hitbox et les knockbacks pour les attaques |mi-mars|
|implémenter un premier niveau simple. Stylisé le jeu et l'interface de jeu (ajout de son, de nouvelles animations, des menus de pauses ...)|début avril|
|Selon le temps disponible et l'avancement des objectifs précédents : implémenter un système de score(temps à finir le niveau, golds récupérés ...), créer d'autres niveaux peut être plus difficile, avec potentielement un combat de boss. Implémenter les objectifs supplémentaire (si le temps le permet)|fin avril/ début mai|


## Installer Raylib

Pour avoir raylib sur Linux:
```bash
sudo apt update
sudo apt install build-essential git cmake
git clone https://github.com/raysan5/raylib.git
cd raylib
mkdir build && cd build
cmake ..
make
sudo make install
```

Ensuite installer sur opam
```bash
opam depext raylib
opam install raylib
```

## Lancement du jeu

Etre dans le répertoire shovelknight
```bash
cd shovelknight
```
Puis

```bash
dune build
```

Puis 
```bash
dune exec shovelknight
```

Si besoin
```bash
dune clean
```

## Liens utiles

Doc de Raylib: https://tjammer.github.io/raylib-ocaml/raylib/Raylib/index.html

Sprites du jeu: https://www.spriters-resource.com/pc_computer/shovelknight/

Niveaux créés avec Tiled: https://www.mapeditor.org