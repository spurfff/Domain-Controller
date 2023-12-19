#!/bin/bash

function dns_setup() {

	# ANSII Color Code Vars
	bold='\033[1;37m'
	underline='\033[4;37m'
	reset='\033[0m'


	# Important Directories
	working_dir="/etc/bind"
	backup_file="/tmp/bind.bak"

	# Lables for different stages of the script
	root_check="Check for root"
	intro="Introductory Section"
	_install_files="Update & install necessary files"
	_verify_files="Verify Files and directories"

	# Messages
	flourish='**********'
	oscheckfail_message_0="\nFailed to identify operating system...\n"
	oscheckfail_message_1="\nPlease ensure you are running Ubuntu 22.04...\n"
	intro_message_0="\n${flourish}${bold}${underline}DNS Setup${reset}${flourish}\n"
	intro_message_1="\n - This portion of the script covers DNS setup - \n"
	_continue='Contnue? [Y/N]: '
	_exiting="Exiting The Script..."
	install_message_0="\n${flourish}Installing necessary files...\n"
	install_message_1="\n${flourish}Necessary files have been installed successfully!\n"
	please_run_elevated="Please run this script with elevated priveleges..."
	_date="${bold}${underline}$(date)${reset}"
	_user="${bold}${underline}$(whoami)${reset}"


	# Ensure the script is being run with root priveleges
	if [[ "$EUID" -ne 0 ]]; then
		echo -e "${please_run_elevated}"
		sleep 1
		exit 1
	fi	

	# Capture the home directory of the sudo user
	sudo_user="$(awk -F ':' '/sudo/ {print $4}' /etc/group)"
	sudo_user_home="/home/${sudo_user}"

	# Log File
	_log_file="${sudo_user_home}/dns_setup.log"

	# Create the log file
	if [[ ! -f "${_log_file}" ]]; then
		touch "${_log_file}"
		if [[ $? -ne 0 ]]; then
			echo -e "[ERROR]: ${_date} Failed to create log file..." >> "${_log_file}"
			echo -e "[EXIT]: ${_date} Exiting the script with errors..."
			echo -e "Failed to create the log file..."
			sleep 1
			echo -e "Exiting the script..."
			sleep 1
			exit 1
		fi
		echo -e "[INFO]: ${_date} The log file has been created in '${_log_file}'" >> "${_log_file}"
	else
		echo -e "[INFO]: ${_date} The log file already exists at '${_log_file}'" >> "${_log_file}"
	fi

	# Startup log message
	echo -e "[STARTUP]: ${_date} Starting the script..." >> "${_log_file}"

	# Ensure the script is running Ubuntu 22.04
	if  grep -e "Ubuntu" -e "22.04" /etc/os-release >/dev/null; then
		echo -e "[INFO]: ${_date} Passed check for Ubuntu 22.04" >> "${_log_file}"
	else
		echo -e "[ERROR]: ${_date} Failed check for Ubuntu 22.04" >> "${_log_file}"
		echo -e "[DEBUG]: ${_date} Checking output of /etc/os-release or /etc/issue..." >> "${_log_file}"
		# Check for os-release
		if [[ -f /etc/os-release ]]; then
			cat /etc/os-release | tee -a "${_log_file}" >/dev/null && echo "Found file /etc/os-release" >> "${_log_file}"
		elif [[ -f /etc/issue ]]; then
			cat /etc/issue | tee -a "${_log_file}" >/dev/null && echo "Found file /etc/issue" >> "${_log_file}"
		else
			echo -e "[DEBUG]: ${_date} Could not identify Operating System"
		fi
		echo -e "${oscheckfail_message_0}"
		sleep 1
		echo -e "${oscheckfail_message_1}"
		sleep 1
		echo -e "[EXIT]: ${_date} Exiting the script with errors..." >> "${_log_file}"
		exit 1
	fi



	# Run the introduction
	echo -e "${intro_message_0}"
	sleep 1
	echo -e "${intro_message_1}"
	sleep 1

	while true; do
		read -p "${_continue}" answer
		case "$answer" in
			[Yy] | [Yy][Ee][Ss])
				echo "Continuing with the script..."
				sleep 1
				break
				;;
			[Nn] | [Nn][Oo])
				echo -e "${_exiting}"
				echo -e "[INFO]: ${_date} Script Exited by ${_user} at ${intro}" >> "${_log_file}"
				sleep 1
				echo -e "[EXIT]: ${_date} Exiting the Script normally..." >> "${_log_file}"
				exit 0
				;;
			*)
				echo "Invalid selection. Please try again..."
				sleep 1
				;;
		esac

	done

	# Take an action based on the selection
	if [[ "$answer" =~ ^[Yy] ]]; then
		echo -e "[SCRIPT]: ${_date} user ${_user} has chosen '${answer}', running '${_install_files}'" >> "${_log_file}"
		echo -e "${install_message_0}"
		sleep 1
		apt-get update && apt-get install bind9 dnsutils rsync -y
		sleep 1
		unset answer
	else
		echo -e "[ERROR]: ${_date} An error has occured while running '${_install_files}'..." >> "${_log_file}"
		echo "An Error has occured..."
		sleep  1
		echo "Exiting the script..."
		echo -e "[EXIT]: ${_date} Exiting the Script with errors..." >> "${_log_file}"
		sleep 1
		exit 1
	fi

	# Verify Files and directories exist
	if  [[ -f "/usr/sbin/named" && -d "/etc/bind" ]]; then
		echo -e "[SCRIPT]: ${_date} bind9 has been successfully installed by ${_user}" >> "${_log_file}"
		echo -e "${install_message_1}"
		sleep 1
	else
		echo -e "[ERROR]: ${_date} An error has occured while running '${_verify_files}'..." >> "${_log_file}"
		echo "An Error has occured..."
		sleep  1
		echo "Exiting the script..."
		echo -e "[EXIT]: ${_date} Exiting the Script with errors..." >> "${_log_file}"
		sleep 1
		exit 1
	fi
	
	# make a backup of the /etc/bind directory
	if [[ ! -f "${backup_file}" ]]; then
		echo -e "[INFO]: ${_date} Attempting to create backup of '${working_dir}'" >> "$_log_file"
		cd /tmp || exit 1
		rsync -av --backup "${working_dir}" "${backup_file}" &>> "${_log_file}" 
		if [[ $? -eq 0 ]]; then
			echo -e "[SCRIPT]: ${_date} Successfully backed up '${working_dir}' to '${backup_file}'" >> "${_log_file}"
		else
			echo -e "[ERROR]: ${_date} Failed to back up '${working_dir}' to '${backup_file}'" >> "${_log_file}"
		fi
	else
		echo -e "[INFO]: ${_date} The backup file '${backup_file}' already exists" >> "${_log_file}"
	fi

	# Move into the /etc/bind directory and begin modifications
	cd ${working_dir}
	if [[ $? -eq 0 ]]; then
		echo -e "[SCRIPT]: ${_date} Successfully moved into '${working_dir}'" >> "${_log_file}"
	else
		echo -e "[ERROR]: ${_date} Failed to move into '${working_dir}'" >> "${_log_file}"
		echo -e "Failed to move into '${working_dir}'..."
		sleep 1
		echo "Exiting the script..."
		echo -e "[EXIT]: ${_date} Exiting the script with errors..." >> "${_log_file}"
		sleep 1
		exit 1
	fi
}
dns_setup
