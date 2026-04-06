#!/usr/bin/bash

set -e
trap 'echo "Something went wrong!" 1>&2' ERR

# Variables

verbose=True

# Check if user is superuser

if [ "$EUID" -ne 0 ]; then
	echo "Permission Denied: Script must be run as superuser."
	exit 1
fi

# Check if verbose flag was added

if [ "$1" != "-v" ]; then
	verbose=False
fi

# Check to see if the inventory.ini file has been made

if [ -f "./inventory.ini" ]; then
	echo "Inventory file detected, skipping creation..."
else 
	echo "Inventory file not found, entering setup wizard..."
	read -p "Host Address:" address
	read -p "Ansible User:" ansible_user
	read -s -p "Ansible Password:" ansible_password
	echo ""
	read -s -p "Grub Password:" grubpass
	echo ""
	touch inventory.ini
	echo "[servers]" > ./inventory.ini
	echo "$address ansible_user=$ansible_user ansible_password=$ansible_password grubpass=$grubpass" >> ./inventory.ini

	if [ verbose ]; then
		echo "File contents:"
		cat "./inventory.ini"
	fi

	echo "New inventory.ini file created!"
fi

# Check if ansible-core is installed
	if [ verbose ]; then
		echo "Checking for ansible core..."
	fi

if dnf list installed | grep -q "ansible-core"; then
	if [ verbose ]; then
		echo "Ansible core version found."
	fi
else
	read -p "Ansible core not found! Would you like to install it?(Y/n):" answer

	case $answer in
		[yY] ) yes | dnf install ansible-core;;
		[nN] ) echo "Ansible install aborted! exiting..."; exit;;
		* ) echo "Invalid response! exiting..."; exit;;
	esac
fi

# Check for ansible communitity utilities

if ansible-galaxy collection list | grep -q -E 'community.general[[:space:]]+3.8.3'; then
	if [ verbose ]; then
		echo "community.general found!"
	fi

else 
	read -p "Playbook is missing dependancies! Would you like them installed?(Y/n):" answer

	case $answer in
		[yY] ) yes | ansible-galaxy collection install -r ./rhel8remeidator/requirements.yml;;
		[nN] ) echo "Ansible dependancy install aborted! exiting..."; exit;;
		* ) echo "Invalid response! exiting..."; exit;;
	esac

fi

# Finally, run the playbook.

read -p "Ansible playbook loaded for RHEL 8. Proceed with remediation? (Y/n):" answer

	case $answer in
		[yY] ) ansible-playbook -i ./inventory.ini ./rhel8remediator/rhel8playbook.yaml;;
		[nN] ) echo "Remediation aborted! exiting..."; exit;;
		* ) echo "Invalid response! exiting..."; exit;;
	esac

