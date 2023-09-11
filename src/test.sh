#!/bin/sh

# Check the status of the mariadb service
STATUS=$(sudo systemctl is-active mariadb)

# Check if the status is "active"
if [ "$STATUS" = "active" ]; then
	echo "MariaDB is Active"
else
	echo "MariaDB is Not Active"
fi
