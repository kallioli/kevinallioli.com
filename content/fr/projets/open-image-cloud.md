---
translationKey: "oic"
title: "Open Image Cloud"
type: projects
weight: 10
description: "Des images cloud pour OpenStack et Proxmox : builds reproductibles, signature cosign keyless, provenance embarquée dans chaque image."
status: "Actif - huit distributions Linux, plus les amphores Octavia"
facts:
  - key: "site"
    value: "openimages.cloud"
    url: "https://openimages.cloud"
  - key: "registre"
    value: "images.openimages.cloud"
    url: "https://images.openimages.cloud"
  - key: "code"
    value: "github.com/open-img-cloud"
    url: "https://github.com/open-img-cloud"
  - key: "licence"
    value: "Apache-2.0 / MIT selon les dépôts"
  - key: "rôle"
    value: "Auteur et mainteneur"
links:
  - label: "openimages.cloud"
    url: "https://openimages.cloud"
  - label: "github.com/open-img-cloud"
    url: "https://github.com/open-img-cloud"
---

Open Image Cloud publie des images cloud prêtes à l'emploi pour OpenStack
et Proxmox. Huit distributions Linux (Alpaquita, Alpine, Amazon Linux 2 et
2023, Gentoo, NixOS, Oracle Linux 9 et 10), plus les amphores Octavia
alignées sur chaque version d'OpenStack.

Ce qui distingue ces images des images officielles des distributions n'est
pas leur contenu. C'est ce qu'on peut en dire avec certitude.

## Le problème

Vous démarrez une image cloud. Elle vient d'un miroir, elle a un nom de
fichier et une somme de contrôle. La somme prouve que le fichier n'a pas
été altéré depuis sa publication. Elle ne dit rien de ce qui s'est passé
avant : quel dépôt, quelle révision, quelle machine, quels paquets à quelle
date, quelles retouches appliquées après l'installation de base.

Sur une machine, c'est un détail. Sur une flotte, c'est la couche dont
tout le reste hérite, et c'est la seule que personne ne relit.

## Ce qui est mis en place

**Builds reproductibles.** Chaque image est construite par un workflow
GitHub Actions, à partir de sources amont épinglées et d'un conteneur de
build lui-même étiqueté. La révision du dépôt, l'URL d'exécution du build
et l'empreinte du conteneur constructeur sont écrites dans le
`MANIFEST.json` livré à côté de l'image.

**Signature cosign keyless.** Les images sont signées via l'OIDC de GitHub
Actions. Il n'y a pas de clé privée à conserver, donc pas de clé privée à
perdre. La vérification se fait contre l'identité du workflow qui a
produit l'image :

```bash
cosign verify-blob alpine-3.23.4-uefi-x86_64.qcow2 \
  --bundle alpine-3.23.4-uefi-x86_64.qcow2.bundle --new-bundle-format \
  --certificate-identity-regexp 'https://github.com/open-img-cloud/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

**Chemins immuables.** Le registre public sert les images sous
`images.openimages.cloud/<os>/<version>/<fichier>`. Un chemin publié ne
change plus. Un alias `latest/` mutable existe à côté, pour ceux qui le
veulent, mais ce n'est jamais lui qui fait foi.

## L'architecture

La chaîne de build vit dans un dépôt `.github` partagé, sous forme de
workflows réutilisables et d'actions composites. Chaque dépôt d'image
reste mince : un `VERSION`, un script de personnalisation (libguestfs ou
diskimage-builder selon la distribution), un détecteur de nouvelle version
amont, et deux workflows appelants.

Côté stockage, la source de vérité est un
[Garage](https://garagehq.deuxfleurs.fr) auto-hébergé, miroité vers
Cloudflare R2 et servi derrière le CDN. Un petit Worker route les chemins
`/<os>/*` vers les compartiments correspondants.

## Pourquoi ça compte

Le mot souverain est aujourd'hui vendu comme une propriété
géographique. Mais un datacentre situé en Europe qui démarre des images
dont personne ne sait reconstruire la généalogie ne vous donne aucune
garantie supplémentaire : il déplace la confiance, il ne la supprime pas.

L'objectif d'Open Image Cloud est de rendre cette confiance inutile. Vous
pouvez vérifier ce que vous démarrez sans avoir à me croire.
