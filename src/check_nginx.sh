#!/bin/sh


if dpkg -l | grep -q "nginx"; then
	echo "nginx is installed"
else 
	echo "nginx is not"
fi
