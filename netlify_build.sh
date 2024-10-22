#!/bin/bash

# Télécharger et installer Flutter
echo "Downloading Flutter SDK..."
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.10-stable.tar.xz
tar xf flutter_linux_3.3.10-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Afficher la version de Flutter
flutter --version

# Résoudre les dépendances
flutter pub get

# Construire l'application web
flutter build web

# Sortir du script si une commande échoue
set -e
