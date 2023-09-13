#!/bin/sh



echo
echo "***********Disclaimer**********"
echo
echo "The existing composer will be overwritten by the new composer depend on the php version!"
echo
echo "*******************************"
echo

COMPOSER_QUESTIONS=("y" "n")

ask_install_composer() {
	echo
	echo "1. y (default)"
	echo "2. Enter 'q' to quit."
	read -p "Install Composer? (y/n) : " composer 
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

while true; do
	ask_install_composer	

	composer=$(echo $composer | tr '[A-Z]' '[a-z]')

	if [ "$composer" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi
	
	if [ -z "$composer" ]; then
	    composer="y"
	fi

	if [[ " ${COMPOSER_QUESTIONS[*]} " == *" ${composer} "* ]]
       	then
		break
	else 
		echo "--------------------------------"
		echo	
		echo "Please type y (or) n"
		echo 
	fi
done


#if [ "$composer" = "y" ]; then 
#	echo "Installing composer..."
#	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#	php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#	php composer-setup.php
#	php -r "unlink('composer-setup.php');"
#fi
