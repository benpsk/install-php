#!/bin/sh


if dpkg -l | grep -q "mariadb"; then
	echo "installed"
else 
	echo "not"
fi
