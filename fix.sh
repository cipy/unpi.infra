#!/bin/dash

logger unpi.fixing.bit

logger running on an $(cat /proc/device-tree/model)

# daca este cumva activ
systemctl disable ssh

if uptime -p | grep -q hours; then
  # asteptam sa treaca macar o ora
  wget -q https://infra.unpi.ro/apps.yml -O /var/run/apps.yml; chmod a+r /var/run/apps.yml; sync
  sudo -iu pi ansible-playbook -i localhost, /var/run/apps.yml --start-at-task="Configurari finale" -e esteundar= -e hashedcode=
fi

# daca este prea tarziu
uptime -p | grep -qE '(up [1-9]+ days|up .. hours)' && shutdown 01:30 "Este timpul sa mergi la somn."

curl -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
