#!/bin/sh

VALID_PHP_VERSION=("8.2" "8.1" "8.0" "7.4" "7.2")
PHP_SKIP=false

ask_php_version() {

  cat <<-EOF
		***********Disclaimer**********
		The existing PHP will be overwritten by the new PHP!

		Available PHP Versions:

		1. PHP 8.2 (default)
		2. PHP 8.1
		3. PHP 8.0
		4. PHP 7.4
		5. PHP 7.2

		Enter 0 (zero) to skip.
		Enter 'q' to quit.

	EOF
	read -p "Please select PHP Version: " php_version
	echo
}

validate_php_version() {
	local input="$1"
	
	# Define a regular expression pattern for decimal numbers
	local pattern='^[0-9]+([.][0-9]+)?$'

	if [[ "$input" =~ $pattern ]]; then
		return 0
	else
		return 1
	fi
}

# Keep asking until a valid PHP version is provided
while true; do
	ask_php_version

	php_version=$(echo $php_version | tr '[A-Z]' '[a-z]')

	if [ "$php_version" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi
	
	if [ "$php_version" = "0" ]; then
		echo "Skipping... PHP installation"
		PHP_SKIP=true
		break;
	fi
	
	if [ -z "$php_version" ]; then
	    php_version="8.2"
	fi

	if [[ " ${VALID_PHP_VERSION[*]} " == *" ${php_version} "* ]]
       	then
		echo "Valid PHP Version"
		break
	else 
		echo "--------------------------------"
		echo	
		echo "Invalid PHP Version: $php_version"
		echo 
	fi
done

php="php$php_version"


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




