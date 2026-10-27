---
translationKey: "about"
title: "À propos"
description: "Ingénieur OpenStack à Genève. Treize ans d'infrastructure, cinq ans d'OpenStack à plus de 5 000 serveurs, et des correctifs en amont depuis 2026."
---

Je suis ingénieur OpenStack. Pendant treize ans j'ai construit et exploité
de l'infrastructure, et pendant cinq de ces années j'ai fait tourner des
clouds OpenStack de plus de 5 000 serveurs. Aujourd'hui je corrige en amont
ce que je rencontrais en exploitation, et je cherche un poste où OpenStack
est le cœur du métier.

## Ce que je fais

**Exploiter OpenStack à grande échelle.** Nova, Neutron, Cinder, Keystone,
Placement, et ce qui les porte : la base de données, la file de messages,
le stockage. Les incidents de niveau 3, ceux qui n'ont pas de page de
documentation, et les signaux faibles qui les précèdent.

**Faire monter une plateforme de version.** Préparer, tester ce qui peut
l'être, décider ce qui ne le sera pas, exécuter dans la fenêtre, et savoir
sur quel critère on revient en arrière. Un plan de montée de version et son
exécution ne sont jamais le même document.

**Construire les images système.** La couche que presque personne ne
regarde et dont tout le reste hérite. Builds reproductibles, signature,
provenance embarquée. C'est le sujet d'[Open Image
Cloud](/projets/open-image-cloud/).

**Contribuer en amont.** Modernisation de la base de code et correctifs de
sécurité sur Horizon, le tableau de bord d'OpenStack, et sur openstacksdk.
Revues de code sur Horizon, openstacksdk et Keystone. Le
[registre](/contributions/) liste tout, abandons compris.

**Automatiser.** Terraform et Ansible pour des clusters multi-cloud, GitHub
Actions pour les chaînes de build. La réversibilité se pose avant la
migration, pas après.

**Transmettre.** Formation Public Cloud et accompagnement technique
d'équipes qui adoptent le cloud.

## Le terrain

Je suis aujourd'hui ingénieur N3 Cloud et Services Managés chez Cheops
Technology Switzerland, à Genève.

Avant cela, pendant cinq ans chez Infomaniak, j'ai exploité et fait
évoluer des environnements OpenStack de plus de 5 000 serveurs. Montées de
version, scale-up, incidents de niveau 3, clusters multi-cloud pilotés sous
Terraform et Ansible. À cette échelle, la documentation officielle décrit
la procédure ; elle ne décrit pas ce qui arrive quand la procédure
rencontre l'existant. C'est cet écart qui m'intéresse et c'est de là que
vient à peu près tout ce que je sais.

J'y ai aussi conçu les images système sur lesquelles ces machines
démarrent. C'est la couche que presque personne ne regarde, et c'est
précisément celle qui décide : ce qu'elle contient, tout le reste en
hérite.

## Ce que je publie

[Open Image Cloud](/projets/open-image-cloud/) est la suite logique de ce
travail : des images cloud prêtes à l'emploi pour OpenStack et Proxmox,
construites de façon reproductible sur GitHub Actions, signées avec cosign
en mode keyless, et livrées avec leur provenance embarquée dans un
`MANIFEST.json`. Huit distributions Linux, plus les amphores Octavia
alignées sur chaque version d'OpenStack.

L'objectif tient en une phrase : vous pouvez vérifier ce que vous démarrez
sans avoir à me faire confiance.

## En amont

Corriger un problème chez soi le règle une fois ; le corriger en amont le
règle pour tout le monde. Je contribue à OpenStack sous le compte Gerrit
`kallioli` depuis 2026 : modernisation (Python 3.14, Django 6.0) et
correctifs de sécurité sur Horizon, et sur openstacksdk.

Le [registre des contributions](/contributions/) le dit tel quel : les
changements mergés, ceux en revue, ceux qui ont été abandonnés, avec le
lien vers chaque revue. Un patch abandonné assumé en dit plus long qu'une
liste où ne figurent que les succès.

## Ce que je crois

La souveraineté ne se décrète pas, elle se vérifie. Une infrastructure
qu'on ne sait pas reconstruire depuis la source n'est pas souveraine, quel
que soit le pays du datacentre. La géographie du datacentre est une
condition ; elle n'a jamais été une preuve.

## Ce que je cherche

Un poste d'ingénieur ou d'architecte OpenStack : exploitation à grande
échelle, montées de version, chaîne d'images, ou travail en amont. Une
équipe qui fait tourner OpenStack en production et qui a des problèmes
sans page de documentation.

## Écrire

Par courriel : [kevin@stackops.ch](mailto:kevin@stackops.ch).
Le code est sur [GitHub](https://github.com/kallioli), les revues sur
[Gerrit](https://review.opendev.org/q/owner:kallioli), le parcours sur
[LinkedIn](https://www.linkedin.com/in/kevin-allioli).
