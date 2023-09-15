#!/bin/sh

if [ -f /etc/os-release ]; then
    codename_line=$(grep "VERSION_CODENAME" /etc/os-release)
    
    # Extract the codename value from the line
    codename=$(echo "$codename_line" | cut -d= -f2 | tr -d '"')
    
    # Print the codename
    echo "$codename"
else
    echo "Unable to determine Ubuntu codename."
fi

