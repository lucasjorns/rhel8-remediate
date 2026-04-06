#!/usr/bin/bash

# Get ssh info
read -p "Host:" host
read -p "SSH Username:" sshUser

osInfo=$(ssh $sshUser@$host 'uname -a')

echo "OS Found: $osInfo"

# Execute script based on RHEL version identifier
if echo "$osInfo" | grep -q "el9"; then
	read -p "RHEL 9 detected. Proceed with remediation? (Y/n):" answer

	case "$answer" in
		Y|y);; # insert rhel9 script here
		N|n) echo "Aborting..."; exit;;
		*) echo "Unknown answer provided. Exiting..."
	esac

        echo "Done!"
elif echo "$osInfo" | grep -q "el8"; then
	read -p "RHEL 8 detected. Proceed with remediation? (Y/n):" answer
	case "$answer" in
		Y|y) bash ./rhel8remediator/rhel8auto.sh;;
		N|n) echo "Aborting..."; exit;;
		*) echo "Unknown answer provided. Exiting..."
	esac
	echo "Done!"
else
	echo "OS did match supported versions! exiting..."
fi
