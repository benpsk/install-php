#!/bin/bash

declare -A PHP_VERSIONS

PHP_VERSIONS["1"]="8.2"
PHP_VERSIONS["2"]="8.1"
PHP_VERSIONS["3"]="8.0"
PHP_VERSIONS["4"]="7.4"
PHP_VERSIONS["5"]="7.2"

PHP_SKIP=false

backup_and_remove_apache2() {

	if dpkg -l | grep -q "apache2"; then
		echo "Backup existing apache2 config to => /etc/apache2.tar.gz"
		sudo systemctl stop apache2

		web_server_date=$(date +%Y%m%d)

		sudo tar czvf /etc/apache2_backup_"$web_server_date".tar.gz -C /etc/apache2

		sudo apt-get remove apache2 -y

		sudo rm -rf /etc/apache2/
	fi
}
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
		echo "Skipping... PHP installation"
		PHP_SKIP=true
		break
	fi

	if [ -z "$php_version" ]; then
		php_version="8.2"
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

	## install php (ondrje php)
	### add ondrje ppa
	sudo apt-get install software-properties-common -y
	sudo add-apt-repository ppa:ondrej/php -y
	sudo apt-get update

	sudo apt-get install -y "$php"

	### install php modules (Laravel Project)
	sudo apt-get install -y "$php"-mysql "$php"-mbstring "$php"-exif "$php"-bcmath "$php"-gd "$php"-zip "$php"-dom

	### install php-fpm by default
	sudo apt-get install -y "$php"-fpm
fi
