# install-docker-scripts
Scripts d'installation de Docker pour un serveur Unix

Le dépot contient 2 scripts facilitant l'install de Docker sur un serveur Linux

## Prérequis

Avant de commencer il est conseillé d'avoir un utilisateur non root, avec des privilèges root.

Voici comment le créer :

```bash
sudo adduser duck
sudo usermod -aG sudo duck
sudo rsync --archive --chown=duck:duck ~/.ssh /home/duck/.ssh
```

Changer *duck* par le nom d'utilisateur souhaité.

Il est également coneillé d'activer le firewall.

```bash
sudo ufw allow OpenSSH
sudo ufw enable
```


## Installer Docker

1. Cloner le dépôt sur le serveur avec l'utilisateur non root.
2. Lancer le script *install_docker.sh*
