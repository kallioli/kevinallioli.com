---
title: "Configurer ses images cloud avec Glance"
date: 2025-08-20
draft: false
description: "Un guide pratique des propriétés d'image Glance : OS, architecture, Secure Boot, VirtIO, et les différences à connaître entre Linux et Windows."
pillar: "Images système"
tags: ["openstack", "glance", "images système", "virtio"]
---

Quand on ajoute une image dans OpenStack, lancer la première instance peut vite tourner au casse-tête : écran noir, carte réseau absente, images mal organisées dans Horizon… Autant de petits soucis très courants dont on se passerait bien. C'est souvent à ce moment-là qu'on réalise qu'une image cloud n'est pas qu'un disque : c'est aussi un **ensemble de métadonnées**. Dans OpenStack, ces métadonnées (les *image properties*) sont gérées par le service **Glance**. Bien définies, elles pilotent le comportement de **Nova**, **Ironic** et **Cinder** pour que vos images fonctionnent comme prévu.

Ce guide vous montre comment poser les bonnes propriétés (OS, version, architecture, Secure Boot), tirer parti de **VirtIO** pour les performances, et éviter les pièges classiques **Linux contre Windows**. On y glisse aussi la bonne habitude d'utiliser la nomenclature **libosinfo** pour garder un catalogue propre et scriptable.

## Objectif

- Comprendre les propriétés d'image Glance **les plus utiles**.
- Voir les différences clés **entre Linux et Windows**.
- Optimiser pour **la performance (VirtIO)** et **la compatibilité (Secure Boot, IDE/e1000)**.
- Disposer d'un **aide-mémoire prêt à l'emploi** (*sans remplacer la documentation officielle*).

## Propriétés système et OS

| Propriété        | Exemple             | Utilité                 |
| ---------------- | ------------------- | ----------------------- |
| `architecture`   | `x86_64`            | Architecture CPU        |
| `os_distro`      | `ubuntu`, `windows` | Nom de l'OS (libosinfo) |
| `os_version`     | `24.04`, `2019`     | Version de l'OS         |
| `os_type`        | `linux`, `windows`  | Famille d'OS            |
| `os_secure_boot` | `required`          | Active Secure Boot      |

> **Astuce pratique.**
> Renseignez `os_distro` et `os_version` avec des **valeurs normalisées** (voir *libosinfo* ci-dessous).
> Ça évite `Ubuntu` contre `ubuntu` (ou `Win2019` contre `windows`), simplifie les scripts, et garde vos listes propres dans Horizon.

### libosinfo, c'est quoi et à quoi ça sert ?

**libosinfo** est une base de connaissances des systèmes d'exploitation (projet open source) utilisée par de nombreux outils de virtualisation. Elle fournit des **noms et versions normalisés** ainsi que des informations utiles (pilotes, compatibilité, paramètres recommandés).

Dans notre contexte, l'utiliser pour **nommer `os_distro` et `os_version`** apporte :

- de la **cohérence** (scripts, CI/CD, filtres, étiquetage),
- une **meilleure lisibilité** dans les interfaces,
- moins d'erreurs dues aux variations de casse ou d'orthographe.

**Exemples conformes :**

```
os_distro=ubuntu    os_version=24.04
os_distro=debian    os_version=12
os_distro=rocky     os_version=9
os_distro=windows   os_version=2019
```

> Ce n'est pas obligatoire pour Glance, mais c'est une bonne pratique.

## Propriétés hyperviseur

| Propriété          | Exemple    | Description                |
| ------------------ | ---------- | -------------------------- |
| `hypervisor_type`  | `kvm`      | Hyperviseur cible          |
| `img_config_drive` | `optional` | Config-drive requis ou non |
| `instance_uuid`    | `<UUID>`   | UUID source si snapshot    |

## Propriétés VirtIO (performance)

| Propriété             | Exemple           | Description          |
| --------------------- | ----------------- | -------------------- |
| `hw_disk_bus`         | `virtio`, `ide`   | Contrôleur disque    |
| `hw_scsi_model`       | `virtio-scsi`     | Contrôleur SCSI      |
| `hw_vif_model`        | `virtio`, `e1000` | Carte réseau         |
| `hw_rng_model`        | `virtio`          | Périphérique RNG     |
| `hw_qemu_guest_agent` | `yes`             | Agent invité QEMU    |

**Linux** : passez **directement** en `virtio` (pris en charge nativement par le noyau).
**Windows** : démarrez en `ide` et `e1000`, puis **basculez en `virtio`** après installation des pilotes VirtIO.

## Propriétés sécurité

| Propriété                               | Exemple             | Description              |
| --------------------------------------- | ------------------- | ------------------------ |
| `cinder_encryption_key_id`              | `<UUID>`            | Clé KMS pour volumes     |
| `cinder_encryption_key_deletion_policy` | `on_image_deletion` | Politique de suppression |

## Exemples pratiques

### Créer une image Ubuntu 24.04 optimisée VirtIO

```bash
openstack image create \
  --file ubuntu-24.04.qcow2 \
  --disk-format qcow2 \
  --container-format bare \
  --property os_distro=ubuntu \
  --property os_version=24.04 \
  --property os_type=linux \
  --property architecture=x86_64 \
  --property hw_disk_bus=virtio \
  --property hw_scsi_model=virtio-scsi \
  --property hw_vif_model=virtio \
  --property hw_rng_model=virtio \
  --property hw_qemu_guest_agent=yes \
  "ubuntu-24.04-virtio"
```

### Créer une image Windows Server 2019 (mode compatibilité)

```bash
openstack image create \
  --file windows-server-2019.qcow2 \
  --disk-format qcow2 \
  --container-format bare \
  --property os_distro=windows \
  --property os_version=2019 \
  --property os_type=windows \
  --property architecture=x86_64 \
  --property hw_disk_bus=ide \
  --property hw_vif_model=e1000 \
  "windows-server-2019"
```

Ensuite, dans la VM Windows :

- installez **les pilotes VirtIO**,
- installez **Cloudbase-Init**,
- puis migrez les propriétés :

```bash
openstack image set <WIN_IMAGE_ID> \
  --property hw_disk_bus=virtio \
  --property hw_scsi_model=virtio-scsi \
  --property hw_vif_model=virtio
```

## Comparatif Linux et Windows (valeurs recommandées)

| Propriété               | Linux (Ubuntu, CentOS…)      | Windows (Server 2019/2022/2025)    |
| ----------------------- | ---------------------------- | ---------------------------------- |
| `os_type`               | `linux`                      | `windows`                          |
| `os_distro`             | `ubuntu`, `centos`, `rocky`… | `windows`                          |
| `os_version`            | `24.04`, `9`…                | `2019`, `2022`, `2025`             |
| `architecture`          | `x86_64`                     | `x86_64`                           |
| `hw_disk_bus`           | `virtio` / `scsi`            | `ide` → `virtio` (après pilotes)   |
| `hw_scsi_model`         | `virtio-scsi`                | `virtio-scsi` (après pilotes)      |
| `hw_vif_model`          | `virtio`                     | `e1000` → `virtio` (après pilotes) |
| `hw_rng_model`          | `virtio`                     | `virtio` (si pilote installé)      |
| `hw_qemu_guest_agent`   | `yes`                        | `yes` (Cloudbase QGA)              |
| `img_config_drive`      | `optional`                   | `optional`                         |
| `os_secure_boot`        | `optional` / `required`      | `required` (UEFI et Secure Boot)   |

**Linux** : VirtIO partout dès le départ.
**Windows** : IDE et e1000 pour installer, puis VirtIO après les pilotes et Cloudbase-Init.

## En résumé

- Les **propriétés d'image** pilotent concrètement le **démarrage, la compatibilité et la performance**.
- **VirtIO** apporte un gain immédiat (disque et réseau).
- **Windows** : la compatibilité d'abord (IDE/e1000), **VirtIO ensuite**.
- Standardisez `os_distro` et `os_version` avec **libosinfo** pour rester propre et scriptable.
- Pensez à l'**agent invité QEMU** et à la **description** de l'image (catalogue lisible).

## Pour aller plus loin

- [Glance, *Useful image properties*](https://docs.openstack.org/glance/latest/admin/useful-image-properties.html)
- [libosinfo / osinfo-db](https://libosinfo.org) (noms et versions normalisés)
- [Cloudbase-Init](https://cloudbase.it/cloudbase-init/) (Windows)
- [Pilotes VirtIO pour Windows](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/)
