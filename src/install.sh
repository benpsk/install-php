#!/bin/sh

# exit on error
set -e

#### Disclaimer ####
echo "Please keep in mind that if there's the exiting mariadb it'll backup and install new!"

#### start backup if exist ####

# Check if MariaDB is installed
if dpkg -l | grep -q mariadb-server; then
	echo "MariaDB is installed."
	sudo systemctl stop mariadb
	sudo tar czvf mysql_backup.tar.gz /var/lib/mysql/
	mv mysql_backup.tar.gz /var/lib/

	sudo apt remove mariadb-server -y
	sudo apt autoremove -y

	echo "Remove Successfuly"
else
	echo "MariaDB is not installed."
	# Perform actions when MariaDB is not installed
	# For example, install MariaDB:
	# sudo apt-get update
	# sudo apt-get install mariadb-server
fi
