#!/bin/bash

v=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)

if [ "$v" -ge 8 ]; then
  dnf -y install epel-release ansible

  echo "secret stuff" > demo.txt
  ansible-vault encrypt demo.txt
else
  echo "not compatinle version"
  exit 1
fi
