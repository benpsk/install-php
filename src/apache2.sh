#!/bin/sh

WEB_SERVER_QUESTIONS=("1" "2")

ask_install_web_server() {

	echo
	echo "***********Disclaimer**********"
	echo
	echo "The existing web server will be overwritten."
	echo
	echo "*******************************"
	echo
	echo
	echo "1. Apache2 (default)"
	echo "2. Nginx"
	echo "Enter 'q' to quit."
	echo 
	read -p "Install web server? : " web_server 
	echo
}

# validate php version input
validate_web_server_input() {
	local input="$1"
	
	# Define a regular expression pattern for decimal numbers
	local pattern='^[0-9]?$'

	if [[ "$input" =~ $pattern ]]; then
		return 0
	else
		return 1
	fi
}

while true; do
	ask_install_web_server

	web_server=$(echo $web_server | tr '[A-Z]' '[a-z]')

	if [ "$web_server" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi
	
	if [ -z "$web_server" ]; then
	    web_server="1"
	fi

	if [[ " ${WEB_SERVER_QUESTIONS[*]} " == *" ${web_server} "* ]]
       	then
		break
	else 
		echo "--------------------------------"
		echo	
		echo "Please choose web server indicating number"
		echo 
	fi
done


if [ "$web_server" = "1" ]; then 
	if dpkg -l | grep -q "apache2"; then
	    echo "Backup existing apache2 config to => /etc/apache2.bak"
	    sudo mv /etc/apache2 /etc/apache2.bak
	fi

	# install apache2 and dependencies
	sudo apt install apache2 -y

	php_version=$(php -v 2>&1 | grep -oP "(?<=PHP )([0-9]+\.[0-9]+)")

	if [ -n "$php_version" ]; then
	    sudo apt install libapache2-mod-php"$php_version"
	fi
	sudo a2enmod rewrite

else 
	echo "install nginx $web_server"
fi
