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
        switches=(
                "countryName"
                "stateOrProvinceName"
                "localityName" "organizationName"
                "organizationalUnitName"
                "commonName"
                "name"
                "emailAddress"
        )
        keyword="optional"
        bold='\e[1;37m'
        underline='\e[4;37m'
        reset='\e[0m'
        flourish="**********"

        # Print the title of the currently running fuction
        title="\n${flourish}${bold}${underline}Vars Setup${reset}${flourish}\n"


        echo -e "$title"
        sleep 2

        echo -e "\n - The purpose of this portion of the script is to add information to the Subject line of the CA Certificate file - \n"
        sleep 4

        echo -e "\n - We'll do this by switching on some parameters that you added earlier - \n"
        sleep 4
}
vars_setup
