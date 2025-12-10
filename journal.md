## 15/11, Degorre

Discussions sur le sujet. Cf. issue #1.

RdV dès que le sujet est corrigé.

À faire :
[X] corrections sur le sujet
[/] commencer à coder (notamment modélisation par les bons types de données)

## 29/11, Degorre

Le sujet est maintenant prêt pour commencer à coder.

À faire :
[ ] continuer à traduire les fonctionnalités annoncées en types OCaml
[ ] décrire le modèle "physique" du jeu (mouvements, collisions, ...)
[ ] coder prototypes des fonctionnalités clé (affichage graphique 2D, gestion des évènements clavier, début d'intéractions physiques)

## 29/01/25, Degorre

Fait :

[X] continuer à traduire les fonctionnalités annoncées en types OCaml 
[/] décrire le modèle "physique" du jeu (mouvements, collisions, ...) -> programmé, mais pas de spécification
[X] coder prototypes des fonctionnalités clé (affichage graphique 2D, gestion des évènements clavier, début d'interactions physiques)

À faire :

[ ] revoir le calendrier (et augmenter sa granularité)
[ ] niveaux (modélisation, écrire des niveaux... chargement depuis JSON?)
[ ] objets
[ ] ennemis
(objets et ennemis : au moins une représentation de base, permettant de charger et afficher le niveau, puis mouvements et interactions)
[ ] petite demo

## 12/02/25, Degorre

Fait :

[X] revoir le calendrier (et augmenter sa granularité)
[X] modélisation niveaux
[X] ennemis qui bougent
[X] caméra qui suit le joueur
[X] on peut ramasser des pièces d'or, ce qui incrémente le compteur
[X] demo

À faire :

[ ] documenter modèle physique
[ ] niveaux (écrire des niveaux... chargement depuis JSON?)
[ ] autres objets
[ ] ennemis (intéractions)
([ ] plus généralement, suivre planning)

Utiliser des niveaux ad hoc comme listes d'objectifs pour un jalon donné.

## 12/03/25, Degorre

Fait

[X] niveaux (avec chargement depuis JSON)
[X] ennemis (affichage et déplacement mode "patrol")

À faire :

[ ] finir parser JSON
[ ] documenter modèle physique (en fait, la dynamique et les règles de simulation et de déplacement des objets mobiles du jeu)
[ ] autres objets
[ ] continuer ennemis (IA, combats)
([ ] plus généralement, suivre planning)

## 02/04/25 Degorre

Fait

[X] finir parser JSON
[/] continuer ennemis (IA, combats) : animation pour le personnage qui bouge, IA : l'ennemi pourchasse le personnage, combat: seulement le joueur qui frappe au corps à corps

Faire
	
[ ] terminer combat
[ ] documenter modèle physique (en fait, la dynamique et les règles de simulation et de déplacement des objets mobiles du jeu)
[ ] autres objets
[ ] vrais niveaux

Suggestion : prochain suivi avec Giovanni pour revue aspects fonctionnels du code


# 09/04/2025

TODO

[ ] Organise the code using modules and signatures in a coherent manner
	to avoid trivial modules.
[ ] Implement the mutable (game) state using the "State Monad"
[ ] Implement a way to finish a level, to pass to the next level
[ ] Implement a way for enemies to attack the player
