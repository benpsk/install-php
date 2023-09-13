#!/bin/sh

#### Disclaimer ####
echo "***********Disclaimer**********"
echo
echo "The existing PHP will be overwritten by the new PHP!"
echo
echo

VALID_PHP_VERSION=("8.2" "8.1" "8.0" "7.4" "7.2")

ask_php_version() {
	echo "Available PHP Versions"
	echo 
	echo "1. PHP 8.2 (default)"
	echo "2. PHP 8.1"
	echo "3. PHP 8.0"
	echo "4. PHP 7.4"
	echo "5. PHP 7.2"
	echo "Enter 'q' to quit."
	echo
	read -p "Please select PHP Version: " php_version 
	echo
}

# validate php version input
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
