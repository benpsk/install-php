#!/bin/bash

##
##
##
##
## *************** START COMMON FUNCTION SECTION ****************
##
##
##

DATE=$(date +%Y%m%d)

backup_and_remove_apache2() {

	if dpkg -l | grep -q "apache2"; then

		echo "Backup existing apache2 config to => /etc/apache2.tar.gz"
		sudo systemctl stop apache2

		sudo tar czvf /etc/apache2_backup_"$DATE".tar.gz -C /etc/apache2

		sudo apt-get purge apache2* libapache2-mod-php* -y

		sudo apt autoremove -y

		sudo rm -rf /etc/apache2/
	fi
}

backup_and_remove_nginx() {

	if dpkg -l | grep -q "nginx"; then

		echo "Backup existing nginx config to => /etc/nginx.tar.gz"
		sudo systemctl stop nginx

		sudo tar czvf /etc/nginx_backup_"$DATE".tar.gz -C /etc/nginx

		sudo apt-get purge nginx* -y

		sudo apt autoremove -y

		sudo rm -rf /etc/nginx/
	fi

}

stop_nginx() {

	if dpkg -l | grep -q "nginx"; then
		sudo systemctl stop nginx
		sudo systemctl disable nginx
	fi
}

stop_apache2() {

	if dpkg -l | grep -q "apache2"; then
		sudo systemctl stop apache2
		sudo systemctl disable apache2
	fi
}
##
##
##
## *************** END COMMON FUNCTION SECTION ****************
##
##
##
##
##

##
##
##
##
##
## *************** START PHP SECTION ****************
##
##
##

declare -A PHP_VERSIONS

PHP_VERSIONS["1"]="8.2"
PHP_VERSIONS["2"]="8.1"
PHP_VERSIONS["3"]="8.0"
PHP_VERSIONS["4"]="7.4"
PHP_VERSIONS["5"]="7.2"

PHP_SKIP=false

ask_php_version() {

	cat <<-EOF

		***********Disclaimer**********

		The existing PHP will be overwritten by the new PHP!

		*******************************

		Available PHP Versions:

		1. PHP 8.2 (default)
		2. PHP 8.1
		3. PHP 8.0
		4. PHP 7.4
		5. PHP 7.2

		- Enter 0 (zero) to skip.
		- Enter 'q' to quit.

	EOF
	read -p "Please select PHP Version: " php_version
	echo
}

while true; do
	ask_php_version

	php_version=$(echo "$php_version" | tr "[:upper:]" "[:lower:]")

	if [ "$php_version" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi

	if [ "$php_version" = "0" ]; then
		echo "Skipping... PHP installation!"
		PHP_SKIP=true
		break
	fi

	if [ -z "$php_version" ]; then
		php_version="1"
	fi

	# Check if the input is equal to one of the array keys
	if [[ -n "${PHP_VERSIONS[$php_version]}" ]]; then
		php_version="${PHP_VERSIONS[$php_version]}"
		break
	else
		echo "***********************************"
		echo
		echo "Please choose the given prefix number or the given PHP Version"
		echo
	fi
done

php="php$php_version"

if [ "$PHP_SKIP" = "false" ]; then
	echo "Installing... $php"

	### check for apache2
	backup_and_remove_apache2

	## stop nginx
	stop_nginx

	## install php (ondrje php) ### add ondrje ppa
	sudo apt-get install software-properties-common -y
	sudo add-apt-repository ppa:ondrej/php -y
	sudo apt-get update

	sudo apt-get install -y "$php"

	### install php modules (Laravel Project)
	sudo apt-get install -y "$php"-mysql "$php"-mbstring "$php"-exif "$php"-bcmath "$php"-gd "$php"-zip "$php"-dom

	### install php-fpm by default
	sudo apt-get install -y "$php"-fpm

	### set installed php to default php
	sudo update-alternatives --set php /usr/bin/"$php"
	sudo a2enmod "$php"
	sudo a2enmod rewrite

fi
##
##
##
## *************** END PHP SECTION ****************
##
##
##
##
##

##
##
##
##
##
## *************** START COMPOSER SECTION ****************
##
##
##
is_php_install=false

if command -v php &>/dev/null; then
	is_php_install=true
fi

COMPOSER_QUESTIONS=("y" "n")
COMPOSER_SKIP=false

ask_install_composer() {

	cat <<-EOF

		***********Disclaimer**********

		The existing composer will be overwritten by the new composer depend on the php version!

		*******************************

		- y (default)
		- Enter 0 (zero) to skip.
		- Enter 'q' to quit.

	EOF

	read -p "Install Composer? (y/n) : " composer
	echo
}

while "$is_php_install"; do
	ask_install_composer

	composer=$(echo "$composer" | tr '[:upper:]' '[:lower:]')

	if [ "$composer" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi

	if [ "$composer" = "0" ]; then
		echo "Skipping... Composer installation"
		COMPOSER_SKIP=true
		break
	fi

	if [ -z "$composer" ]; then
		composer="y"
	fi

	if [[ " ${COMPOSER_QUESTIONS[*]} " == *" ${composer} "* ]]; then
		break
	else
		echo "***********************************"
		echo
		echo "Please type y (or) n"
		echo
	fi
done

if [ "$composer" = "y" ] && [ "$COMPOSER_SKIP" = "false" ]; then
	# remove existing composer
	ehco "Cleaning Composer..."
	sudo apt-get remove composer -y

	echo "Installing Composer..."
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	sudo mv composer.phar /usr/local/bin/composer
fi

##
##
##
## *************** END COMPOSER SECTION ****************
##
##
##
##
##

##
##
##
##
##
## *************** START WEB SERVER SECTION ****************
##
##
##

WEB_SERVER_QUESTIONS=("1" "2")
WEB_SERVER_SKIP=false

ask_install_web_server() {
	cat <<-EOF

		***********Disclaimer**********

		The existing web server will be overwritten.

		*******************************

		1. Apache2 (default)
		2. Nginx

		- Enter 0 (zero) to skip.
		- Enter 'q' to quit.

	EOF

	read -p "Install web server? : " web_server
	echo
}

while true; do
	ask_install_web_server

	web_server=$(echo "$web_server" | tr '[:upper:]' '[:lower:]')

	if [ "$web_server" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi

	if [ "$web_server" = "0" ]; then
		echo "Skipping... Web Server installation"
		WEB_SERVER_SKIP=true
		break
	fi

	if [ -z "$web_server" ]; then
		web_server="1"
	fi

	if [[ " ${WEB_SERVER_QUESTIONS[*]} " == *" ${web_server} "* ]]; then
		break
	else
		echo "*******************************"
		echo
		echo "Please choose the given prefix number"
		echo
	fi
done

if [ "$WEB_SERVER_SKIP" = "false" ]; then
	echo "Installing... Web Server"

	if [ "$web_server" = "1" ]; then

		## disable nginx if installed (prevent from port 80)
		stop_nginx

		# ondrje php already install apache2 by default
		if [ "$PHP_SKIP" = "true" ]; then

			backup_and_remove_apache2

			# install apache2 and dependencies
			sudo apt-get install apache2 -y

			current_php_version=$(php -v 2>&1 | grep -oP "(?<=PHP )([0-9]+\.[0-9]+)")

			if [ -n "$current_php_version" ]; then
				sudo apt-get install libapache2-mod-php"$current_php_version"
				sudo a2enmod php"$current_php_version"
			fi
			sudo a2enmod rewrite
		fi
	else

		stop_apache2

		backup_and_remove_nginx

		sudo apt-get install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y
		curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor |
			sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
		gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    		http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" |
			sudo tee /etc/apt/sources.list.d/nginx.list

		sudo apt-get update
		sudo apt-get install nginx -y
	fi
fi

##
##
##
## *************** END WEB SERVER SECTION ****************
##
##
##
##
##

##
##
##
##
##
## *************** START DATABASE SECTION ****************
##
##
##

DATABASE_QUESTIONS=("1" "2")
DATABASE_SKIP=false

ask_install_database() {

	cat <<-EOF

		***********Disclaimer**********

		The existing database will be overwrite.

		*******************************

		1. MySQL(default)
		2. MariaDB 

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

		echo "Backup old mysql data to => /var/lib/mysql_backup.tar.gz"
		echo "Backup old mysql config to => /etc/mysql_backup.tar.gz"

		sudo tar czvf /var/lib/mysql_backup_"$DATE".tar.gz -C /var/lib/mysql
		sudo tar czvf /etc/mysql/mysql_backup_"$DATE".tar.gz -C /etc/mysql
	}

	### backup data
	if dpkg -l | grep -q "mariadb"; then
		sudo systemctl stop mariadb

		db_backup

		sudo apt-get purge mariadb* -y
		sudo apt-get autoremove -y
	fi

	if dpkg -l | grep -q "mysql"; then
		sudo systemctl stop mysql

		db_backup

		sudo apt-get purge mysql* -y
		sudo apt-get autoremove -y
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
		sudo sh -c 'cat <<-EOF >/etc/apt/sources.list.d/mariadb.sources
			# MariaDB 11.1 repository list - created 2023-09-11 22:00 UTC
			# https://mariadb.org/download/
			X-Repolib-Name: MariaDB
			Types: deb
			# deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
			# URIs: https://deb.mariadb.org/11.1/ubuntu
			URIs: https://mirror.kku.ac.th/mariadb/repo/11.1/ubuntu
			Suites: $(lsb_release -cs)
			Components: main main/debug
			Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp
			EOF'
		sudo apt-get update -y
		sudo apt-get install mariadb-server -y
	fi
fi

##
##
##
## *************** END DATABASE SECTION ****************
##
##
##
##
##
