#!/bin/sh


if dpkg -l | grep -q "mysql"; then
	echo "installed"
else 
	echo "not"
fi
