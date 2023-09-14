#!/bin/sh

WEB_SERVER_QUESTIONS=("1" "2")

ask_install_web_server() {

	echo
	echo "***********Disclaimer**********"
	echo
	echo "The existing web server will be overwritten by the new web server depend on the new web server!"
	echo
	echo "*******************************"
	echo
	echo
	echo "1. Apache2 (default)"
	echo "2. Nginx"
	echo "Enter 'q' to quit."
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
	echo "install apache2 $web_server"
else 
	echo "install nginx $web_server"
fi
