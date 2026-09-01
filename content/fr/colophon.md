---
translationKey: "colophon"
title: "Colophon"
description: "Comment ce site est construit, versionné, déployé, et pourquoi il ne charge rien qui vienne d'ailleurs."
---

Un site qui affirme que la souveraineté se vérifie doit être vérifiable
lui-même. Voici donc ce qu'il est, exactement.

{{< build-manifest >}}

## Construction

Le site est généré par [Hugo](https://gohugo.io) en version *extended*,
épinglée dans le fichier `.hugo-version` du dépôt et lue par la même
chaîne en local et en intégration continue. Pas de `latest` : une version
flottante rend un build irreproductible et c'est exactement ce que ce site
reproche aux autres.

Aucun thème tiers. Tous les gabarits sont écrits dans ce dépôt. Les thèmes
Hugo populaires sont reconnaissables au premier coup d'œil et constituent
une dépendance de plus à suivre ; ici il n'y a rien à suivre.

Pas de Node, pas de `npm`, pas de bundler. Le SCSS est transpilé, minifié
et empreinté par Hugo Pipes. Les URL d'assets contiennent leur empreinte,
ce qui les rend immuables et permet de les mettre en cache un an sans
revalidation, exactement comme les chemins du registre d'images d'Open
Image Cloud.

## Ce que le navigateur télécharge

Une page HTML, une feuille de style, quatre fichiers de police préchargés,
et deux de plus seulement si la page contient de l'italique ou un titre en
serif grasse. Rien d'autre, et rien qui vienne d'un autre domaine.

Les polices sont la famille [IBM Plex](https://www.ibm.com/plex/), sous
licence SIL Open Font License, servies depuis ce domaine en `woff2`
sous-ensemblés au latin étendu. Six graisses pèsent 132 Ko au total. Pas
de Google Fonts : demander une police à un tiers, c'est lui annoncer
chacune de vos visites.

Pas d'analytics, pas de balise de suivi, pas de CDN externe, pas de
bandeau de consentement, parce qu'il n'y a rien à consentir.

## JavaScript

Une fonction, en ligne dans le `<head>`, qui lit une préférence de thème
en `localStorage`, l'applique avant le premier rendu et révèle le bouton
de bascule. Sans JavaScript, le bouton reste caché et le thème suit
`prefers-color-scheme`. Aucune page d'article n'exécute quoi que ce soit
d'autre.

L'empreinte SHA-256 de ce script est reportée ci-dessus, et c'est la même
valeur que la directive `script-src` de l'en-tête
`Content-Security-Policy`. Elle est calculée au build : le script ne peut
pas changer sans que la politique change avec lui.

## En-têtes

Le fichier `_headers` est généré par un gabarit, pas écrit à la main. La
politique de sécurité de contenu se réduit à `default-src 'self'` plus
l'empreinte du script ci-dessus. S'y ajoutent HSTS, `nosniff`,
`Referrer-Policy: strict-origin-when-cross-origin`, `frame-ancestors
'none'` et une `Permissions-Policy` qui refuse à peu près toutes les API
du navigateur, puisque le site n'en utilise aucune.

## Hébergement et déploiement

Le dépôt est sur GitHub. Chaque poussée sur `main` déclenche une action
qui installe la version épinglée de Hugo, construit le site, et le publie
sur Cloudflare avec `wrangler`. Le jeton d'API vit dans les secrets du
dépôt ; il n'apparaît nulle part dans le code.

Le hash du commit affiché plus haut est injecté au moment du build. Il
désigne l'état exact du dépôt qui a produit la page que vous lisez.

## Typographie

IBM Plex, une seule famille pour tout le site. Plex Sans pour les titres
et la navigation, Plex Serif pour le corps des articles, Plex Mono pour
tout ce qui est une donnée plutôt qu'une phrase : dates, numéros de
changement, versions, empreintes. Corps à 18 pixels, interligne 1,65,
mesure limitée à 68 caractères.

Deux thèmes, clair et sombre, dérivés d'un même jeu de variables CSS. Un
seul accent.

## Licence

Les textes sont sous
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.fr). Le code
des gabarits et des styles est sous licence MIT. Les polices IBM Plex sont
sous SIL OFL 1.1.
