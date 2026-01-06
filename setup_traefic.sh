#!/bin/bash

# Demander le nom de domaine principal
read -p "Entrez le nom de domaine pour le dashboard Traefik (ex: traefik.mondomaine.com) : " TRAEFIK_DOMAIN
read -p "Entrez le nom de domaine pour le service de test (ex: whoami.mondomaine.com) : " WHOAMI_DOMAIN

# Demander un email pour Let's Encrypt
while true; do
    read -p "Entrez votre email pour Let's Encrypt (ex: ton@email.com) : " LETSENCRYPT_EMAIL
    if [[ "$LETSENCRYPT_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        break
    else
        echo "Erreur : l'email n'est pas valide. Veuillez réessayer."
    fi
done

# Demander un mot de passe pour le dashboard
while true; do
    read -s -p "Définissez un mot de passe pour le dashboard Traefik : " PASSWORD
    echo
    read -s -p "Confirmez le mot de passe : " PASSWORD_CONFIRM
    echo
    if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
        break
    else
        echo "Erreur : les mots de passe ne correspondent pas. Veuillez réessayer."
    fi
done

# Générer le hash du mot de passe pour Traefik
HTPASSWD_HASH=$(htpasswd -nb admin "$PASSWORD" | cut -d: -f2)
if [ -z "$HTPASSWD_HASH" ]; then
    echo "Erreur : impossible de générer le hash du mot de passe."
    exit 1
fi

# Créer les dossiers nécessaires
mkdir -p traefik/rules
touch traefik/acme.json
chmod 600 traefik/acme.json

# Écrire le fichier docker-compose.yml
cat > traefik/docker-compose.yml <<EOL
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/etc/traefik/traefik.yml:ro
      - ./rules:/etc/traefik/rules
      - ./acme.json:/acme.json
    command: []

  whoami:
    image: traefik/whoami
    container_name: whoami
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(\`$WHOAMI_DOMAIN\`)"
      - "traefik.http.routers.whoami.tls=true"
      - "traefik.http.routers.whoami.tls.certresolver=letsencrypt"
EOL

# Écrire le fichier traefik.yml
cat > traefik/traefik.yml <<EOL
global:
  checkNewVersion: true
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"
  traefik:
    address: ":8080"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /etc/traefik/rules/dynamic.yml
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: $LETSENCRYPT_EMAIL
      storage: /acme.json
      httpChallenge:
        entryPoint: web
EOL

# Écrire le fichier rules/dynamic.yml
cat > traefik/rules/dynamic.yml <<EOL
http:
  routers:
    traefik-dashboard:
      rule: Host(\`$TRAEFIK_DOMAIN\`)
      service: api@internal
      tls:
        certResolver: letsencrypt
      middlewares:
        - auth
      entryPoints:
        - "websecure"

    whoami:
      rule: Host(\`$WHOAMI_DOMAIN\`)
      service: whoami
      tls:
        certResolver: letsencrypt
      entryPoints:
        - "websecure"

  services:
    whoami:
      loadBalancer:
        servers:
          - url: http://whoami:80

  middlewares:
    auth:
      basicAuth:
        users:
          - "admin:$HTPASSWD_HASH"
EOL

# Lancer Traefik
echo "Fichiers de configuration générés avec succès !"
cd traefik
docker-compose up -d

echo "Traefik est maintenant installé et accessible à l'adresse : https://$TRAEFIK_DOMAIN"
echo "Le service de test 'whoami' est accessible à : https://$WHOAMI_DOMAIN"
