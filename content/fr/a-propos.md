---
translationKey: "about"
title: "À propos"
description: "Treize ans d'infrastructure, cinq ans d'OpenStack à plus de 5 000 serveurs, et une conviction sur ce que veut dire souverain."
---

Un cloud souverain, ce n'est pas un label sur une plaquette. C'est pouvoir
reconstruire, depuis la source et de façon vérifiable, l'image système qui
démarre sur des milliers de serveurs. C'est le métier que j'exerce depuis
treize ans, et c'est le projet que je publie en open source.

## Le terrain

Pendant cinq ans, chez Infomaniak, j'ai exploité et fait évoluer des
environnements OpenStack de plus de 5 000 serveurs. Montées de version,
scale-up, incidents de niveau 3, clusters multi-cloud pilotés sous
Terraform et Ansible. À cette échelle, la documentation officielle décrit
la procédure ; elle ne décrit pas ce qui arrive quand la procédure
rencontre l'existant. C'est cet écart qui m'intéresse et c'est de là que
vient à peu près tout ce que je sais.

J'y ai aussi conçu les images système sur lesquelles ces machines
démarrent. C'est la couche que presque personne ne regarde, et c'est
précisément celle qui décide : ce qu'elle contient, tout le reste en
hérite.

Je suis aujourd'hui ingénieur N3 Cloud et Services Managés chez Cheops
Technology Switzerland, à Genève.

## Ce que je publie

[Open Image Cloud](/projets/open-image-cloud/) est la suite logique de ce
travail : des images cloud prêtes à l'emploi pour OpenStack et Proxmox,
construites de façon reproductible sur GitHub Actions, signées avec cosign
en mode keyless, et livrées avec leur provenance embarquée dans un
`MANIFEST.json`. Huit distributions Linux, plus les amphores Octavia
alignées sur chaque version d'OpenStack.

L'objectif tient en une phrase : vous pouvez vérifier ce que vous démarrez
sans avoir à me faire confiance. C'est tout l'intérêt, et c'est aussi la
seule façon honnête de prononcer le mot souveraineté.

## En amont

Corriger un problème chez soi le règle une fois ; le corriger en amont le
règle pour tout le monde. Je contribue depuis peu à OpenStack sous le
compte Gerrit `kallioli` : modernisation et correctifs de sécurité sur
Horizon, le tableau de bord d'OpenStack, et sur openstacksdk.

C'est récent, et le
[registre des contributions](/contributions/) le dit tel quel : les
changements mergés, ceux en revue, ceux qui ont été abandonnés, avec le
lien vers chaque revue. Un patch abandonné assumé en dit plus long qu'une
liste où ne figurent que les succès.

## Ce que je fais

- Architecture d'infrastructures cloud et critiques, IaaS et PaaS.
- Exploitation OpenStack à grande échelle, et les incidents qui n'ont pas
  de page de documentation.
- Chaînes de construction d'images système : reproductibilité, signature,
  provenance.
- Contribution upstream OpenStack : Horizon, openstacksdk, revues de code.
- Multi-cloud et hybridation, avec la réversibilité posée avant la
  migration plutôt qu'après.
- Transmission : formation Public Cloud, accompagnement technique.

## Ce que je crois

La souveraineté ne se décrète pas, elle se vérifie. Une infrastructure
qu'on ne sait pas reconstruire depuis la source n'est pas souveraine, quel
que soit le pays du datacentre. La géographie du datacentre est une
condition ; elle n'a jamais été une preuve.

## Écrire

Par courriel : [kevin@stackops.ch](mailto:kevin@stackops.ch).
Le code est sur [GitHub](https://github.com/kallioli), les revues sur
[Gerrit](https://review.opendev.org/q/owner:kallioli).
