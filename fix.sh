#!/bin/dash

logger unpi.fixing.bit

# daca imaginea NOOBS l-a activat
systemctl disable ssh

curl -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
