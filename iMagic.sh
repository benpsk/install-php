#!/usr/bin/env bash

##
##
##
##
## *************** START COLOR SECTION ****************
##
##
##

## Reset
RESET='\033[0m'

## Regular Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

## Background
ON_GREEN='\033[42m'
ON_YELLOW='\033[43m'
ON_CYAN='\033[46m'

##
##
## *************** END COLOR SECTION ****************
##
##
##
##
##

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

		echo -e "$(
			cat <<-EOM
				${ON_YELLOW}

				Backup existing apache2 config to    => /etc/apache2_backup_$DATE.tar.gz

				${RESET}
			EOM
		)"

		sudo systemctl stop apache2

		sudo tar czvf /etc/apache2_backup_"$DATE".tar.gz -C /etc/apache2

		sudo apt-get purge apache2* libapache2-mod-php* -y

		sudo apt autoremove -y

		sudo rm -rf /etc/apache2/
	fi
}

backup_and_remove_nginx() {

	if dpkg -l | grep -q "nginx"; then

		echo -e "$(
			cat <<-EOM
				${ON_YELLOW}

				Backup existing nginx config to    => /etc/nginx_backup_$DATE.tar.gz

				${RESET}
			EOM
		)"

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

start_nginx() {
	if dpkg -l | grep -q "nginx"; then
		sudo systemctl start nginx
		sudo systemctl enable nginx
	fi
}

exit_message() {
	echo
	echo -e "${ON_GREEN}Goodbye, See you next time!${RESET}"
	echo
}

skip_message() {
	echo -e "${ON_YELLOW}Skipping... $1 installation!${RESET}"
}

install_message() {
	echo
	echo -e "${ON_CYAN}Installing... $1${RESET}"
	echo
}

welcome_message() {
	echo -e "$(
		cat <<-EOM
			${ON_GREEN}

			***********************************

			Welcome to iMagic installer!

			***********************************

			${RESET}

		EOM
	)"
	echo
	echo -ne "${YELLOW}Press any key to start! : ${RESET}"
	read begin
	echo
}

goodbye_message() {
	echo -e "$(
		cat <<-EOM
			${ON_GREEN}

			***********************************

			Thank you for using iMagic installer!

			***********************************

			${RESET}
		EOM
	)"
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

welcome_message

declare -A PHP_VERSIONS

PHP_VERSIONS["1"]="8.2"
PHP_VERSIONS["2"]="8.2"
PHP_VERSIONS["3"]="8.1"
PHP_VERSIONS["4"]="8.0"
PHP_VERSIONS["5"]="7.4"
PHP_VERSIONS["6"]="7.2"

PHP_SKIP=false

ask_php_version() {

	echo -e "$(
		cat <<-EOM
			${GREEN}



			***********Disclaimer**********

			The existing PHP will be overwritten by the new PHP!

			*******************************

			Available PHP Versions:

			1. PHP 8.3 (default)
			2. PHP 8.2
			3. PHP 8.1
			4. PHP 8.0
			5. PHP 7.4
			6. PHP 7.2

			- Enter 0 (zero) to skip.
			- Enter 'q' to quit.
			${RESET} 
		EOM
	)"
	echo -ne "${YELLOW}Select PHP version (enter the number): ${RESET}"
	read php_version
	echo
}

while true; do
	ask_php_version

	php_version=$(echo "$php_version" | tr "[:upper:]" "[:lower:]")

	if [ "$php_version" = "q" ]; then
		exit_message
		exit 0
	fi

	if [ "$php_version" = "0" ]; then
		skip_message "PHP"
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
		echo -e "$(
			cat <<-EOM
				    ${RED}

							***********************************
				 
							Please choose the given prefix number only!
							${REST}
			EOM
		)"
	fi
done

php="php$php_version"

if [ "$PHP_SKIP" = "false" ]; then

	install_message "$php"

	## stop nginx (php will install apache2 by default)
	if ! dpkg -l | grep -q "apache2"; then
		stop_nginx
	fi

	## install php (ondrje php) ### add ondrje ppa
	sudo apt-get install software-properties-common -y
	sudo add-apt-repository ppa:ondrej/php -y
	sudo apt-get update

	sudo apt-get install -y "$php"

	### install php modules (Laravel && Moodle)
	sudo apt-get install -y "$php"-mysql "$php"-pgsql "$php"-sqlite3 "$php"-mbstring "$php"-exif "$php"-bcmath "$php"-gd "$php"-zip "$php"-dom "$php"-curl "$php"-common "$php"-soap "$php"-xml "$php"-intl "$php"-imagick

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

	echo -e "$(
		cat <<-EOM
			${GREEN}



			***********Disclaimer**********

			The existing composer will be overwritten by the new composer depend on the php version!

			*******************************

			- y (default)
			- Enter 0 (zero) to skip.
			- Enter 'q' to quit.
			${RESET}
		EOM
	)"
	echo -ne "${YELLOW}Install Composer? (y/n) : ${RESET}"
	read composer
	echo
}

while "$is_php_install"; do
	ask_install_composer

	composer=$(echo "$composer" | tr '[:upper:]' '[:lower:]')

	if [ "$composer" = "q" ]; then
		exit_message
		exit 0
	fi

	if [ "$composer" = "0" ]; then
		skip_message "Composer"
		COMPOSER_SKIP=true
		break
	fi

	if [ -z "$composer" ]; then
		composer="y"
	fi

	if [[ " ${COMPOSER_QUESTIONS[*]} " == *" ${composer} "* ]]; then
		break
	else
		echo -e "$(
			cat <<-EOM
				${RED}

				***********************************

				Please type y (or) n
				${RESET}
			EOM
		)"
	fi
done

if [ "$composer" = "y" ] && [ "$COMPOSER_SKIP" = "false" ]; then
	# remove existing composer
	echo "Cleaning Composer..."
	sudo apt-get remove composer -y

	install_message "Composer"

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
	echo -e "$(
		cat <<-EOM
			${GREEN}



			***********Disclaimer**********

			The existing web server will be overwritten.

			*******************************

			1. Apache2 (default)
			2. Nginx

			- Enter 0 (zero) to skip.
			- Enter 'q' to quit.
			${RESET}
		EOM
	)"
	echo -ne "${YELLOW}Select web server (enter the number) : ${RESET}"
	read web_server
	echo
}

while true; do
	ask_install_web_server

	web_server=$(echo "$web_server" | tr '[:upper:]' '[:lower:]')

	if [ "$web_server" = "q" ]; then
		exit_message
		exit 0
	fi

	if [ "$web_server" = "0" ]; then
		skip_message "Web Server"
		WEB_SERVER_SKIP=true
		break
	fi

	if [ -z "$web_server" ]; then
		web_server="1"
	fi

	if [[ " ${WEB_SERVER_QUESTIONS[*]} " == *" ${web_server} "* ]]; then
		break
	else
		echo -e "$(
			cat <<-EOM
				${RED}

				*******************************

				Please choose the given prefix number
				${RESET}
			EOM
		)"
	fi
done

if [ "$WEB_SERVER_SKIP" = "false" ]; then

	install_message "Web Server"

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

		start_nginx
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

	echo -e "$(
		cat <<-EOM
			${GREEN}



			***********Disclaimer**********

			The existing database will be overwrite.

			*******************************

			1. MySQL(default)
			2. MariaDB 

			- Enter 0 (zero) to skip."
			- Enter 'q' to quit."
			${RED}
		EOM
	)"
	echo -ne "${YELLOW}Select Database (enter the number) ?: ${RESET}"
	read database
	echo
}

while true; do
	ask_install_database

	database=$(echo "$database" | tr '[:upper:]' '[:lower:]')

	if [ "$database" = "q" ]; then
		exit_message
		exit 0
	fi

	if [ "$database" = "0" ]; then
		skip_message "Database"
		DATABASE_SKIP=true
		break
	fi

	if [ -z "$database" ]; then
		database="1"
	fi

	if [[ " ${DATABASE_QUESTIONS[*]} " == *" ${database} "* ]]; then
		break
	else
		echo -e "$(
			cat <<-EOM
				${RED}

				*******************************

				Please choose the given prefix number
				${RESET}
			EOM
		)"
	fi
done

if [ "$DATABASE_SKIP" = "false" ]; then

	install_message "Database"

	db_backup() {

		echo -e "$(
			cat <<-EOM
				${ON_YELLOW}

				Backup old mysql data to     => /var/lib/mysql_backup_$DATE.tar.gz
				Backup old mysql config to   => /etc/mysql_backup_$DATE.tar.gz

				${RESET}
			EOM
		)"

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

##
##
##
##
##
## *************** START NODEJS SECTION ****************
##
##
##

declare -A NODEJS_VERSIONS

NODEJS_VERSIONS["1"]="21"
NODEJS_VERSIONS["2"]="20"
NODEJS_VERSIONS["3"]="19"
NODEJS_VERSIONS["4"]="18"
NODEJS_VERSIONS["5"]="16"

NODEJS_SKIP=false

ask_nodejs_version() {

	echo -e "$(
		cat <<-EOM
			${GREEN}



			***********Disclaimer**********

			The existing Nodejs will be overwritten by the new Nodejs!

			*******************************

			Available Nodejs Versions:

			1. Node 21 (default)
			2. Node 20
			3. Node 19
			4. Node 18
			5. Node 16

			- Enter 0 (zero) to skip.
			- Enter 'q' to quit.
			${RESET} 
		EOM
	)"
	echo -ne "${YELLOW}Select Node.js version (enter the number): ${RESET}"
	read nodejs_version 
	echo
}

while true; do
	ask_nodejs_version

	nodejs_version=$(echo "$nodejs_version" | tr "[:upper:]" "[:lower:]")

	if [ "$nodejs_version" = "q" ]; then
		exit_message
		exit 0
	fi

	if [ "$nodejs_version" = "0" ]; then
		skip_message "Node"
		NODEJS_SKIP=true
		break
	fi

	if [ -z "$nodejs_version" ]; then
		nodejs_version="1"
	fi

	# Check if the input is equal to one of the array keys
	if [[ -n "${NODEJS_VERSIONS[$nodejs_version]}" ]]; then
		nodejs_version="${NODEJS_VERSIONS[$nodejs_version]}"
		break
	else
		echo -e "$(
			cat <<-EOM
				    ${RED}

							***********************************
				 
							Please choose the given prefix number only!
							${REST}
			EOM
		)"
	fi
done

if [ "$NODEJS_SKIP" = "false" ]; then

	## ubuntu 18.x only support node 16.
	ubuntu_version=$(lsb_release -sr)
	ubuntu_version_no_dot="${ubuntu_version%%.*}" 
	if [[ "$ubuntu_version_no_dot" -le "18" ]]; then
		nodejs_version="16"
	fi

	install_message "Node $nodejs_version"
	sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg
	curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
	echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_"$nodejs_version".x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
	sudo apt-get update && sudo apt-get install nodejs -y
fi
##
##
##
## *************** END NODEJS SECTION ****************
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
## *************** START SUPERVISOR SECTION ****************
##
##
##

SUPERVISOR_SKIP=false

ask_install_supervisor() {

	echo -e "$(
		cat <<-EOM
			${GREEN}



			***********Disclaimer**********

			The existing supervisor will be overwritten by the new supervisor!

			*******************************

			- n (default)
			- Enter 0 (zero) to skip.
			- Enter 'q' to quit.
			${RESET}
		EOM
	)"
	echo -ne "${YELLOW}Install Supervisor? (y/n) : ${RESET}"
	read supervisor 
	echo
}

ask_install_supervisor

supervisor=$(echo "$supervisor" | tr '[:upper:]' '[:lower:]')

if [ "$supervisor" = "q" ]; then
	exit_message
	exit 0
fi

if [ "$supervisor" = "0" ]; then
	skip_message "Supervisor"
	SUPERVISOR_SKIP=true
fi

if [ -z "$supervisor" ]; then
	supervisor="n"
	skip_message "Supervisor"
fi

if [ "$supervisor" = "y" ] && [ "$SUPERVISOR_SKIP" = "false" ]; then
	sudo apt-get install supervisor
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
goodbye_message