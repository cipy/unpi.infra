#!/bin/dash

logger unpi.fixing.bit

# daca este cumva activ
systemctl disable ssh

# daca este prea tarziu
uptime -p | grep -qE '(up [1-9]+ days|up .. hours)' && shutdown 01:30 "Este timpul sa mergi la somn."

curl -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
