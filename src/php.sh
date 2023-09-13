#!/bin/sh

# exit on error
set -e

#### Disclaimer ####
echo "***********Disclaimer**********"
echo
echo "The existing PHP will be overwritten by the new PHP!"
echo
echo

ask_php_version() {
	echo "Install PHP"
	echo
	echo "1. PHP 8.2 (default)"
	echo "2. PHP 8.1"
	echo "3. PHP 8.0"
	echo "4. PHP 7.4"
	echo "5. PHP 7.2"
	echo "Enter 'q' to quit."
	echo
	echo -en "Please select PHP Version: "

	read PHP_VERSION
	return "$PHP_VERSION"
}

# validate php version input
validate_php_version() {
	local input="$1"
	# Define a regular expression pattern for decimal numbers
	local pattern='^[0-9]+([.][0-9]+)?$'

	if [[ "$input" =~ $pattern ]]; then
		return 1
	else

		ans=$(echo $input | tr '[A-Z]' '[a-z]')
		if [ "$ans" == "q" ]; then
			break
		else
			return 0
		fi
		echo "Invalid PHP Version : $input"
		return 0
	fi
}

# Initialize PHP_VERSION
PHP_VERSION=""

# Keep asking until a valid PHP version is provided
while true; do
	PHP_VERSION=$(ask_php_version)

	if validate_php_version "$PHP_VERSION"; then
		break # Exit the loop when a valid version is provided
	fi
done
