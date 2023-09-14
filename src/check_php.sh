#!/bin/bash

if command -v php &> /dev/null; then
    echo "PHP is installed"
else
    echo "PHP is not installed"
fi

php_version=$(php -v 2>&1 | grep -oP "(?<=PHP )([0-9]+\.[0-9]+)")

if [ -n "$php_version" ]; then
    echo "PHP version: $php_version"
else
    echo "PHP is not installed or an error occurred."
fi

