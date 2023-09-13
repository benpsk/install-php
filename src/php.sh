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
	read -p "Please select PHP Version: " PHP_VERSION
}

# validate php version input
validate_php_version() {
	local input="$1"
	ans=$(echo $input | tr '[A-Z]' '[a-z]')
	if [ "$ans" == "q" ]; then
		echo "YOu enter quite"
		return 2
	else
		# Define a regular expression pattern for decimal numbers
		local pattern='^[0-9]+([.][0-9]+)?$'

		if [[ "$input" =~ $pattern ]]; then
			return 0
		else
			echo "Invalid PHP Version: $input"
			return 1
		fi
	fi
}

# Initialize PHP_VERSION
PHP_VERSION=""

# Keep asking until a valid PHP version is provided
while true; do
	ask_php_version

	result=$(validate_php_version "$PHP_VERSION")

	if [ "$result" -eq 2 ]; then
		echo "Exiting the script."
		exit 0
	elif [ "$result" -eq 0 ]; then
		break # Exit the loop when a valid version is provided
	fi
done

echo "Selected PHP Version: $PHP_VERSION"
