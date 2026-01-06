#!/bin/bash

# Mise à jour des paquets et installation des dépendances
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Ajout de la clé GPG officielle de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Configuration du dépôt Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mise à jour des paquets et installation de Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Vérification de l'installation
sudo docker run hello-world

# Installation de Docker Compose (si nécessaire)
sudo apt-get install -y docker-compose

# Ajout de l'utilisateur courant au groupe docker (pour éviter d'utiliser sudo)
sudo usermod -aG docker $USER
newgrp docker

echo "Docker et Docker Compose ont été installés avec succès !"
