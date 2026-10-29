---
title: "Déployer Windows Server sur OpenStack"
date: 2024-03-24
draft: false
description: "Déployer une instance Windows Server sur OpenStack, de la création de l'instance à la connexion RDP, en passant par la paire de clés qui chiffre le mot de passe administrateur."
pillar: "Terrain OpenStack"
tags: ["openstack", "windows", "tutoriel"]
---

Dans ce tutoriel, vous allez découvrir comment déployer une **instance Windows Server sur une infrastructure OpenStack**. Nous utiliserons pour la démonstration l'interface graphique Horizon, mais les étapes décrites sont valables sur n'importe quelle plateforme compatible.

[Voir la vidéo sur YouTube](https://www.youtube.com/watch?v=aXPEb6oeF2g)

## Prérequis

Pour suivre ce tutoriel, vous aurez besoin :

- d'un compte sur une plateforme OpenStack avec accès au tableau de bord Horizon,
- d'un client RDP (Remote Desktop),
- d'un éditeur de texte pour sauvegarder votre clé privée.

## Lancer une instance Windows

### Connexion au tableau de bord

1. Connectez-vous à votre interface Horizon.
2. Accédez à **Compute > Instances**.
3. Cliquez sur **"Launch Instance"**.

### Choix de l'image et des ressources

1. Nommez votre instance (ex : `windows-instance1`).
2. Dans l'onglet **"Source"**, sélectionnez une image **Windows Server 2022 Datacenter**.
3. Dans l'onglet **"Flavor"**, choisissez :
   - 2 vCPU, 4 Go RAM, 80 Go de disque
4. Dans **"Network"**, attachez un réseau qui fournit au minimum une adresse IPv4 publique.

## Clé SSH pour déchiffrer le mot de passe

OpenStack utilise les **paires de clés SSH** pour sécuriser la création des mots de passe Windows :

1. Dans **"Key Pair"**, créez une nouvelle clé (`windows-key`).
2. Téléchargez la **clé privée**.
3. Enregistrez-la localement (ex : `windows-key.priv`).
4. Lancez l'instance une fois toutes les options remplies.

Cette clé **ne sert pas à se connecter en SSH**, mais à **déchiffrer le mot de passe administrateur généré automatiquement**.

## Autoriser l'accès RDP

Pour autoriser les connexions RDP (Remote Desktop) :

1. Rendez-vous dans **Network > Security Groups**.
2. Cliquez sur **"Manage Rules"** du groupe lié à votre instance.
3. Ajoutez une règle :
   - Type : **RDP**
   - CIDR : `0.0.0.0/0` *(à restreindre pour un usage en production)*

Ouvrir le port RDP permet d'accéder à l'interface graphique Windows de votre VM.

## Récupérer le mot de passe Windows

1. Attendez le **démarrage complet** de l'instance (jusqu'à l'écran de connexion Windows).
2. Cliquez sur **"Retrieve Password"** dans le menu de l'instance.
3. Fournissez votre **clé privée** (copier-coller ou fichier).
4. Cliquez sur **"Decrypt Password"**.
5. Le mot de passe administrateur s'affiche.

## Connexion à l'instance via RDP

1. Ouvrez votre client RDP.
2. Saisissez l'adresse IP publique de l'instance.
3. Nom d'utilisateur : `Administrator`.
4. Mot de passe : celui récupéré à l'étape précédente.

Et voilà, vous accédez à un **Windows Server fonctionnel sur OpenStack**.

## Nettoyer les ressources

Une fois les tests terminés, pensez à :

1. supprimer l'**instance**,
2. supprimer la **clé SSH** associée,
3. retirer la **règle RDP** du Security Group.

Cela évite de conserver des ressources inutiles (et facturables).

## À retenir

- La **clé SSH** est utilisée uniquement pour le **chiffrement du mot de passe initial**.
- **RDP** doit être autorisé via les *Security Groups*.
- Toujours **attendre la fin de la phase de démarrage** avant de récupérer le mot de passe.
- La suppression des ressources est essentielle en environnement cloud.

## Aller plus loin

- [Documentation OpenStack](https://docs.openstack.org/)
- [Client Remote Desktop Microsoft](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-clients)
