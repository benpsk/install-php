#!/bin/bash

declare -A PHP_VERSIONS

PHP_VERSIONS["1"]="8.2"
PHP_VERSIONS["2"]="8.1"
PHP_VERSIONS["3"]="8.0"
PHP_VERSIONS["4"]="7.4"
PHP_VERSIONS["5"]="7.2"

# Input PHP version
input_php_version="6"  # Replace with your input

# Check if the input is equal to one of the array keys
if [[ -n "${PHP_VERSIONS[$input_php_version]}" ]]; then
    php_version="${PHP_VERSIONS[$input_php_version]}"
    echo "Message: PHP version $php_version is selected."
else
    echo "Error: PHP version $input_php_version is not found."
fi

