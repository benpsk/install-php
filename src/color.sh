#!/bin/bash

## Reset
RESET='\033[0m'

## Regular Colors
BLACK='\033[0;30m'
RED='\033[0;31m'  
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'  
PURPLE='\033[0;35m'
CYAN='\033[0;36m'  
WHITE='\033[0;37m' 

## Bold
BBLACK='\033[1;30m'
BRED='\033[1;31m'  
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'  
BPURPLE='\033[1;35m'
BCYAN='\033[1;36m'  
BWHITE='\033[1;37m' 

## Underline
UBLACK='\033[4;30m'
URED='\033[4;31m'  
UGREEN='\033[4;32m'
UYELLOW='\033[4;33m'
UBLUE='\033[4;34m'  
UPURPLE='\033[4;35m'
UCYAN='\033[4;36m'  
UWHITE='\033[4;37m' 

# Background
ON_BLACK='\033[40m'
ON_RED='\033[41m'  
ON_GREEN='\033[42m'
ON_YELLOW='\033[43m'
ON_BLUE='\033[44m'  
ON_PURPLE='\033[45m'
ON_CYAN='\033[46m'  
ON_WHITE='\033[47m' 

# High Intensity
IBLACK='\033[0;90m'
IRED='\033[0;91m'  
IGREEN='\033[0;92m' 
IYELLOW='\033[0;93m'
IBLUE='\033[0;94m'  
IPURPLE='\033[0;95m'
ICYAN='\033[0;96m'  
IWHITE='\033[0;97m' 

# Bold High Intensity
BIBLACK='\033[1;90m'
BIRED='\033[1;91m'  
BIGREEN='\033[1;92m'
BIYELLOW='\033[1;93m'
BIBLUE='\033[1;94m'  
BIPURPLE='\033[1;95m'
BICYAN='\033[1;96m'  
BIWHITE='\033[1;97m' 

# High Intensity backgrounds
ON_IBLACK='\033[0;100m'
ON_IRED='\033[0;101m'  
ON_IGREEN='\033[0;102m'
ON_IYELLOW='\033[0;103m'
ON_IBLUE='\033[0;104m'  
ON_IPURPLE='\033[0;105m'
ON_ICYAN='\033[0;106m'  
ON_IWHITE='\033[0;107m'


echo -e "${ON_RED}This is red text.Back to normal.${RESET}"

cat <<-EOF
${RED}This text is in red.${RESET}
${GREEN}This text is in green.${RESET}
EOF

# Store the text with color codes in a variable
colored_text="
    ${RED}This text is in red.${RESET}
    ${GREEN}This text is in green.${RESET}"

# Use echo to print the colored text
echo -e "$colored_text"

cat <<-EOF
    $colored_text
EOF


echo -e "$(
    cat <<-EOF
        ${RED}This text is in red.${RESET}
        ${GREEN}This text is in green.${RESET}
EOF
)"

# Define ANSI color escape codes
BG_GREEN='\033[42m'
RESET='\033[0m'

# Using echo to set the background color of the entire line
echo -e "${BG_GREEN} This is a green background. ${RESET}"


ask_install_composer() {
    echo -e "$(
        cat <<-EOM
            ${GREEN}                                                                                               
            ***********Disclaimer**********

            The existing composer will be overwritten by the new composer depend on the php version!

            *******************************                                                         

            - y (default)
            - Enter 0 (zero) to skip.
            - Enter 'q' to quit.
                    
EOM
    )"

    echo -e "${YELLOW}Install Composer? (y/n) : ${RESET}"
    echo -e "${RED}Install Composer? (y/n) : ${RESET}"
    echo -e "${GREEN}Install Composer? (y/n) : ${RESET}"
    echo -e "${PURPLE}Install Composer? (y/n) : ${RESET}"
    echo -e "${CYAN}Install Composer? (y/n) : ${RESET}"
	read composer
    echo "$composer"
}

ask_install_composer

