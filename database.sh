#!/bin/sh

DATABASE_QUESTIONS=("1" "2")

ask_install_database() {

	echo
	echo "***********Disclaimer**********"
	echo
	echo "The existing database will be overwrite."
	echo
	echo "*******************************"
	echo
	echo
	echo "1. MySQL(default)"
	echo "2. Mariadb"
	echo "Enter 'q' to quit."
	echo 
	read -p "Install database ? : " database
	echo
}

while true; do
	ask_install_database

	database=$(echo $database | tr '[A-Z]' '[a-z]')

	if [ "$database" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi
	
	if [ -z "$database" ]; then
	    database="1"
	fi

	if [[ " ${DATABASE_QUESTIONS[*]} " == *" ${database} "* ]]
       	then
		break
	else 
		echo "--------------------------------"
		echo	
		echo "Please choose the given prefix number"
		echo 
	fi
done

if [ "$database" = "1" ]; then 
	### install mysql 
	if dpkg -l | grep -q "mysql"; then
	    echo "Backup existing apache2 config to => /etc/apache2.bak"
	    sudo service apache2 stop
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
	### install mariadb
	echo "install mariadb"
	if dpkg -l | grep -q "nginx"; then
	    echo "Backup existing nginx config to => /etc/nginx.bak"
	    sudo service nginx stop
	    sudo mv /etc/nginx /etc/nginx.bak
	fi

	### install nginx
	sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y
	curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
	    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
	gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
	http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
	    | sudo tee /etc/apt/sources.list.d/nginx.list

	sudo apt update
	sudo apt install nginx -y
fi
