#!/bin/bash

WEB_SERVER_QUESTIONS=("1" "2")
WEB_SERVER_SKIP=false

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

ask_install_web_server() {
	cat <<-EOF

		    ***********Disclaimer**********
				The existing web server will be overwritten.

		    *******************************

				1. Apache2 (default)
				2. Nginx

				- Enter 0 (zero) to skip.
				- Enter 'q' to quit.

	EOF

	read -p "Install web server? : " web_server
	echo
}

while true; do
	ask_install_web_server

	web_server=$(echo "$web_server" | tr '[:upper:]' '[:lower:]')

	if [ "$web_server" = "q" ]; then
		echo "Goodbye, See you next time!"
		exit 0
	fi

	if [ "$web_server" = "0" ]; then
		echo "Skipping... Web Server installation"
		WEB_SERVER_SKIP=true
		break
	fi

	if [ -z "$web_server" ]; then
		web_server="1"
	fi

	if [[ " ${WEB_SERVER_QUESTIONS[*]} " == *" ${web_server} "* ]]; then
		break
	else
		echo "*******************************"
		echo
		echo "Please choose the given prefix number"
		echo
	fi
done

if [ "$WEB_SERVER_SKIP" = "false" ]; then
	echo "Installing... Web Server"

	if [ "$web_server" = "1" ]; then

		## disable nginx if installed (prevent from port 80)
		if dpkg -l | grep -q "nginx"; then
			sudo systemctl stop nginx
		fi

		backup_and_remove_apache2

		# install apache2 and dependencies
		sudo apt-get install apache2 -y

		php_version=$(php -v 2>&1 | grep -oP "(?<=PHP )([0-9]+\.[0-9]+)")

		if [ -n "$php_version" ]; then
			sudo apt-get install libapache2-mod-php"$php_version"
			sudo a2enmod php"$php_version"
		fi
		sudo a2enmod rewrite

	else

		## if apache2 is install stop
		if dpkg -l | grep -q "apache2"; then
			sudo systemctl stop apache2
		fi

		### install nginx
		if dpkg -l | grep -q "nginx"; then
			echo "Backup existing nginx config to => /etc/nginx.bak"
			sudo systemctl stop nginx
			sudo mv /etc/nginx /etc/nginx.bak
		fi

		sudo apt-get install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y
		curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor |
			sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
		gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" |
			sudo tee /etc/apt/sources.list.d/nginx.list

		sudo apt-get update
		sudo apt-get install nginx -y
	fi
fi
