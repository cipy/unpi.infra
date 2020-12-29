#!/bin/dash

logger unpi.fixing.bit

logger running on an $(cat /proc/device-tree/model)

# daca este cumva activ
systemctl disable ssh

undar=$(cat /root/.unpi/esteundar 2>/dev/null)
hashed=$(cat /root/.unpi/hashedcode 2>/dev/null)
wget -q https://infra.unpi.ro/apps.yml -O /var/run/apps.yml; chmod a+r /var/run/apps.yml; sync
sudo -iu pi ansible-playbook -i localhost, /var/run/apps.yml --start-at-task="Configurari finale" -e "esteundar=$undar" -e "hashedcode=$hashed"

# daca este prea tarziu
uptime -p | grep -qE '(up [1-9]+ days|up .. hours)' && shutdown 01:30 "Este timpul sa mergi la somn."

curl -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
