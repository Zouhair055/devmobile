# Projet Flutter - Application de Gestion de Vêtements
## Description

Ce projet consiste à développer une application mobile simple inspirée de Vinted, permettant à des utilisateurs d'acheter des vêtements d'occasion. L'application propose une interface de connexion, un affichage des vêtements disponibles, un panier d'achat et un profil utilisateur.
et cette application  permet aussi de télécharger des images de vêtements et d'obtenir des prédictions sur la catégorie de ces vêtements (par exemple, "T-shirt", "Chapeau", etc.).

## Accès à l'Application (deux utilisateurs)
Utilise ces identifiants pour te connecter à l'application.

        Login: zouhair
        Password: 123456

        Login: angelina
        Password: 123456

## Fonctionnalités
#### Login Utilisateur : 
Authentification via Firebase, avec un écran de connexion simple.
#### Liste des Vêtements : 
Affichage des vêtements disponibles avec leurs informations (image, titre, taille, prix).
#### Détail d'un Vêtement : 
Affichage complet d'un vêtement avec une option d'ajout au panier.
#### Panier : 
Vue du panier avec possibilité de retirer un vêtement et mise à jour du total.
#### Profil Utilisateur : 
Accès aux informations de profil (login, mot de passe, adresse, etc.) avec possibilité de modification.
#### Ajouter un Vêtement : 
Ajout d'un vêtement via un formulaire dans le profil utilisateur.

## API GitHub
L'API pour la catégorisation des vêtements est disponible sur GitHub ici : 
    - [GitHub](https://github.com/Zouhair055/flask-api)

## Instructions de démarrage pour l'API
Clone le dépôt de l'API :

`git clone git@github.com:Zouhair055/flask-api.git`

## Lance l'API :

`python app.py`

## Lance l'application :

`flutter run`