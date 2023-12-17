#!/bin/bash

#[ policy_anything ]
#countryName             = optional
#stateOrProvinceName     = optional
#localityName            = optional
#organizationName        = optional
#organizationalUnitName  = optional
#commonName              = supplied
#name                    = optional
#emailAddress            = optional

function vars_setup() {
        # Make an array of the openssl-easyrsa.cnf variables included above
        policies=(
                "countryName"
                "stateOrProvinceName"
                "localityName"
                "organizationName"
                "organizationalUnitName"
                "commonName"
                "name"
                "emailAddress"
        )

        # ANSII Color Vars
        red='\e[0;31m'
        green='\e[0;32m'
        bold='\e[1;37m'
        underline='\e[4;37m'
        reset='\e[0m'

        # A Little Flourish
        flourish="**********"

        # Target Configuration File
        config_file="/home/lain/easy-rsa/pki/openssl-easyrsa.cnf"

        # Introductory Messages
        title="\n${flourish}${bold}${underline}Vars Setup${reset}${flourish}\n"
        title_message_1="\n - The purpose of this portion of the script is to add information to the Subject line of the CA Certificate file - \n"
        title_message_2="\n - We'll do this by switching on some parameters that you added earlier - \n"

        # Generic Mesages
        generic_message_1="\n - Loading The Current configuration... - \n"

        # Log File
        log_file="./CA_Server_Setup.log"

        # Print the title of the currently running fuction
        echo -e "$title"
        sleep 1

        echo -e "${title_message_1}"
        sleep 1

        echo -e "${title_message_2}"
        sleep 1

        echo -e "${generic_message_1}"
        sleep 1

        # Print for the user, a list of which objects are set to "optional" or "supplied"
        # If an object is set to "optional", it WON'T be added to the Subject Line
        # If an object is set to "supplied", it WILL be added to the Subject Line
        # Present this data to the user  with true or false values
        # Make sure to Pretty up the object names

        for policy in "${policies[@]}"; do

                key=$(awk -v pattern="$policy" '$0 ~ pattern {print $1; exit}' "$config_file")
                value=$(awk -v pattern="$policy" '$0 ~ pattern {print $3; exit}' "$config_file")

                # Ensure key/value vars are not empty
                if [[ -z $value ]]; then
                        echo "DEBUG: $(date) unable to find matching name: $policy in $config_file" >> "$log_file"
                        echo -e "DEBUG: $(date) current value of ${bold}value${reset}: $value" >> "$log_file"
                        echo "DEBUG: $(date) unable to find matching line for $policy in $config_file"
                        echo -e "DEBUG: $(date) current value of ${bold}value${reset}: $value"
                        sleep 1
                        echo "Exiting the script..."
                        sleep 1
                        exit 1
                elif [[ -z $key ]]; then
                        echo "DEBUG: $(date) unable to find matching name: $policy in $config_file" >> "$log_file"
                        echo "DEBUG: $(date) current value of ${bold}key${reset}: $key" >> "$log_file"
                        echo "DEBUG: $(date) unable to find matching line for $policy in $config_file"
                        echo "DEBUG: $(date) current value of ${bold}key${reset}: $key"
                        sleep 1
                        echo "Exiting the script..."
                        sleep 1
                        exit 1
                fi

                # Color the value red or green based on optional/supplied strings
                if [[ $value == "optional" ]]; then
                        color='\033[31m'
                elif [[ $value == "supplied" ]]; then
                        color='\033[32m'
                else
                        echo "ERROR: $(date) Unexpected key/value pairs..." >> "$log_file"
                        echo "ERROR: $(date) Unexpected key/value pairs..."
                        sleep 1
                        echo "Exiting the Script..."
                        sleep 1
                        exit 2
                fi
                echo -e "$key : ${color}$value${reset}"
                key_value_array+=("$key : ${color}$value${reset}")
        done

        # line break for aesthetics
        echo -e "\n"
        sleep 1

        # Ask if they'd like to keep the current configuration
        while true; do
                read -p "Would you like to keep the default configuration? [Y/N]: " answer
                case "$answer" in
                        [Yy] | [Yy][Ee][Ss])
                                echo "Keeping the default configuration"
                                sleep 1
                                break
                                ;;
                        [Nn] | [Nn][Oo])
                                echo "You have chosen to update the configuration"
                                sleep 1
                                break
                                ;;
                        *)
                                echo "Invalid Input. Please try again..."
                                sleep 1
                                ;;
                esac
        done

        # Check what the answer was, and make a decision on whether or not to proceed with the function
        if [[ $answer =~ ^[Yy] ]]; then
                echo "Moving on with the script..."
                sleep 1
        fi

        if [[ $answer =~ ^[Nn] ]]; then
                echo -e "Which Objects would you like to turn on? (add to the subject line)\n"
                sleep 1

                # Print out the menu
                count=1
                for element in "${key_value_array[@]}"; do
                        echo -e "${count}.) $element"
                        ((count++))
                done

                # Ask the user to make a selection from the available options
                read -p "Select a number between 1 & ${#key_value_array[@]} " selection

        fi

}
vars_setup
