#!/bin/bash
 
# --- Schritt 1: Entfernen von Docker und allen Inhalten ---
 
echo "Entferne Docker und alle Docker-Inhalte..."
 
# Stoppe alle laufenden Container

docker stop $(docker ps -aq)
 
# Entferne alle Container

docker rm $(docker ps -aq)
 
# Entferne alle Docker-Images

docker rmi $(docker images -q)
 
# Entferne alle Docker-Volumen

docker volume prune -f
 
# Entferne Docker und alle Docker-Komponenten

sudo apt-get purge -y docker.io docker-engine docker-ce docker-ce-cli containerd runc
 
# Entferne alle nicht mehr benötigten Pakete und Dateien

sudo apt-get autoremove -y

sudo apt-get clean
 
# Entferne Docker-Verzeichnisse, die verbleiben könnten

sudo rm -rf /var/lib/docker

sudo rm -rf /etc/docker
 
# --- Schritt 2: Entfernen von Nextcloud, MariaDB und Apache ---
 
# Stoppe und entferne Apache

sudo systemctl stop apache2

sudo systemctl disable apache2

sudo apt-get purge -y apache2 apache2-utils apache2.2-bin apache2-common
 
# Entferne MariaDB

sudo systemctl stop mariadb

sudo systemctl disable mariadb

sudo apt-get purge -y mariadb-server mariadb-client mariadb-common
 
# Entferne Nextcloud (wenn es manuell installiert wurde)

sudo rm -rf /var/www/nextcloud

sudo rm -rf /etc/apache2/sites-available/nextcloud.conf
 
# --- Schritt 3: Docker installieren ---
 
echo "Installiere Docker..."
 
# Docker installieren

sudo apt update

sudo apt install -y sudo apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io
 
# Docker Compose installieren (optional)

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
 
# --- Schritt 4: Nextcloud über Docker installieren ---
 
echo "Starte Nextcloud über Docker..."
 
# Erstelle ein Verzeichnis für Docker-Compose

mkdir -p ~/nextcloud-docker

cd ~/nextcloud-docker
 
# Erstelle die Docker-Compose-Datei

cat <<EOF > docker-compose.yml

version: '3.8'

services:

  nextcloud:

    image: nextcloud

    container_name: nextcloud

    ports:

      - 8080:80

    volumes:

      - nextcloud_data:/var/www/html

    restart: unless-stopped

  db:

    image: mariadb

    container_name: mariadb

    environment:

      MYSQL_ROOT_PASSWORD: example

      MYSQL_DATABASE: nextcloud

      MYSQL_USER: nextcloud

      MYSQL_PASSWORD: example

    volumes:

      - db_data:/var/lib/mysql

    restart: unless-stopped
 
volumes:

  nextcloud_data:

  db_data:

EOF
 
# Starte Nextcloud und MariaDB mit Docker Compose

docker-compose up -d
 
echo "Nextcloud sollte jetzt über http://localhost:8080 zugänglich sein."

 
