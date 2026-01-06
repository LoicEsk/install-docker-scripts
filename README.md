# install-docker-scripts
Scripts d'installation de Docker pour un serveur Unix

Le dépot contient 2 scripts facilitant l'install de Docker sur un serveur Linux

## Prérequis

Il y a quelques petites actions a réaliser sur le serveur avant de commencer.

### 1. Créer un utilisateur non root avec privilèges

Avant de commencer il est conseillé d'avoir un utilisateur non root, avec des privilèges root.

Voici comment le créer :

```bash
sudo adduser duck
sudo usermod -aG sudo duck
sudo rsync --archive --chown=duck:duck ~/.ssh /home/duck/.ssh
```

Changer *duck* par le nom d'utilisateur souhaité.

### 2. Activer le firewall.

C'est recommandé

```bash
sudo ufw allow OpenSSH
sudo ufw enable
```

### 3. Cloner ce dépôt sur le serveur

Ou copier les fichers

### 4. Rendre les scripts executables

```bash
chmod +x install_docker.sh
chmod +x setup_traefik.sh
```


## Installer Docker

1. Cloner le dépôt sur le serveur avec l'utilisateur non root.
2. Lancer le script *install_docker.sh*

## Configurer Traefic

Reverse proxy permettant de faire tourner plusieus sites/webapp sur le serveur.

Simplifie la création ds certificats SSL avec Let's Encrypt.