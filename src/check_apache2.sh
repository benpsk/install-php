#!/bin/sh

if dpkg -l | grep -q "apache2"; then
    echo "Apache2 is installed."
else
    echo "Apache2 is not installed."
fi

