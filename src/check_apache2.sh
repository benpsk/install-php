#!/bin/sh

if dpkg -l | grep -q "apache2"; then
    echo "Apache2 is installed."
else
    echo "Apache2 is not installed."
fi

## check apache2 is running or not
if systemctl is-active --quiet apache2; then
    echo "Apache2 is running."
else
    echo "Apache2 is not running."
fi
