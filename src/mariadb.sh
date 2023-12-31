#!/bin/sh

#### Disclaimer ####
echo "Please keep in mind that if there's the exiting mariadb it'll backup and install new!"

#### start backup if exist ####

# Check if MariaDB is installed
if dpkg -l | grep -q mariadb-server; then
	echo "MariaDB is installed."
	sudo systemctl stop mariadb
	backup_date=$(date +%Y%m%d)
	sudo tar czvf /var/lib/mysql_backup_"$backup_date".tar.gz /var/lib/mysql/
	sudo rm -rf /var/lib/mysql
	
	sudo apt remove mariadb-server -y
	echo "Remove Successfuly"
fi

sudo apt-get install apt-transport-https curl -y
sudo mkdir -p /etc/apt/keyrings
sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
sudo sh -c 'echo "# MariaDB 11.1 repository list - created 2023-09-11 22:00 UTC
  # https://mariadb.org/download/
  X-Repolib-Name: MariaDB
  Types: deb
  # deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
  # URIs: https://deb.mariadb.org/11.1/ubuntu
  URIs: https://mirror.kku.ac.th/mariadb/repo/11.1/ubuntu
  Suites: jammy
  Components: main main/debug
  Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp " >/etc/apt/sources.list.d/mariadb.sources'

sudo apt-get update -y
sudo apt-get install mariadb-server -y
