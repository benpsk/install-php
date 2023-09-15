#!/bin/bash

DATABASE_QUESTIONS=("1" "2")
DATABASE_SKIP=false

ask_install_database() {

	cat <<-EOF

		    ***********Disclaimer**********
		    The existing database will be overwrite.

		    *******************************

		    1. MySQL(default)
		    2. Mariadb

		    - Enter 0 (zero) to skip."
		    - Enter 'q' to quit."

	EOF
	read -p "Install database ? : " database
	echo
}

while true; do
	ask_install_database

	database=$(echo "$database" | tr '[:upper:]' '[:lower:]')

	if [ "$database" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi

	if [ "$database" = "0" ]; then
		echo "Skipping... Database installation"
		DATABASE_SKIP=true
		break
	fi

	if [ -z "$database" ]; then
		database="1"
	fi

	if [[ " ${DATABASE_QUESTIONS[*]} " == *" ${database} "* ]]; then
		break
	else
		echo "*******************************"
		echo
		echo "Please choose the given prefix number"
		echo
	fi
done

if [ "$DATABASE_SKIP" = "false" ]; then

	echo "Installing... Database"

	db_backup() {

		db_date=$(date +%Y%m%d)

		sudo tar czvf /var/lib/mysql_backup_"$db_date".tar.gz -C /var/lib/mysql
		sudo tar czvf /etc/mysql/mysql_backup_"$db_date".tar.gz -C /etc/mysql
	}

	### backup data
	if dpkg -l | grep -q "mariadb"; then
		echo "Backup old mysql data to => /var/lib/mysql_backup.tar.gz"
		echo "Backup old mysql config to => /etc/mysql_backup.tar.gz"
		sudo systemctl stop mariadb

		db_backup

		sudo apt purge mariadb-server -y

	elif dpkg -l | grep -q "mysql"; then
		echo "Backup old mysql data to => /var/lib/mysql_backup.tar.gz"
		echo "Backup old mysql config to => /etc/mysql_backup.tar.gz"
		sudo systemctl stop mysql

		db_backup

		sudo apt-get purge mysql-server* -y
		sudo apt-get install -f
		sudo apt autoremove -y

	fi

	sudo rm -rf /var/lib/mysql/ /etc/mysql/

	if [ "$database" = "1" ]; then
		### install mysql
		sudo apt-get install mysql-server -y
	else
		### install mariadb
		sudo apt-get install apt-transport-https curl -y
		sudo mkdir -p /etc/apt/keyrings
		sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
		sudo sh -c "echo \"# MariaDB 11.1 repository list - created 2023-09-11 22:00 UTC
    # https://mariadb.org/download/
    X-Repolib-Name: MariaDB
    Types: deb
    # deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
    # URIs: https://deb.mariadb.org/11.1/ubuntu
    URIs: https://mirror.kku.ac.th/mariadb/repo/11.1/ubuntu
    Suites: $(lsb_release -cs)
    Components: main main/debug
    Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp \" >/etc/apt/sources.list.d/mariadb.sources"

		sudo apt-get update -y
		sudo apt-get install mariadb-server -y
	fi
fi
