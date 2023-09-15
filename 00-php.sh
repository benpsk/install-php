#!/bin/bash

VALID_PHP_VERSION=("8.2" "8.1" "8.0" "7.4" "7.2")
PHP_QUESTIONS=("1", "2", "3", "4", "5")
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
	read -pr "Please select PHP Version: " php_version
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

	if [[ " ${VALID_PHP_VERSION[*]} " == *" ${php_version} "* ]]; then
		break
	elif [[ " ${PHP_QUESTIONS[*]} " == *" ${php_version} "* ]]; then
		echo "Still Ok"
		break
	else
		echo "--------------------------------"
		echo
		echo "Invalid PHP Version: $php_version"
		echo
	fi
done

php="php$php_version"

PHP_SKIP=true

if [ "$PHP_SKIP" = "false" ]; then
	echo "Installing... $php"

	## install php (ondrje php)
	### add ondrje ppa
	sudo apt-get install software-properties-common -y
	sudo add-apt-repository ppa:ondrej/php -y
	sudo apt update

	sudo apt install -y "$php"

	### install php modules (Laravel Project)
	sudo apt install -y "$php"-mysql "$php"-mbstring "$php"-exif "$php"-bcmath "$php"-gd "$php"-zip "$php"-dom

	### install php-fpm by default
	sudo apt install -y "$php"-fpm
fi
