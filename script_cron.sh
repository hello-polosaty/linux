#!/bin/bash

echo #############################################################################################################################

echo server name: $HOSTNAME

echo server ip:

echo $(ip a | grep -P 'inet\s')

echo tasks:

for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l 2>/dev/null | grep -v '^#'; done
