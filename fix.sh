#!/bin/dash

logger unpi fixing time

logger running on an $(cat /proc/device-tree/model)

# daca ssh este cumva activ
[ ! -f /root/.unpi/help ] && systemctl disable ssh

# la chindii nu incarca sistemul cu alte operatii
[ "$(date +%H)" -ge 17 -a "$(date +%H)" -lt 20 ] && exit

# configureaza limba romana
if grep -Ev '^#' /etc/default/locale | grep -qv ro_RO; then
  raspi-config nonint do_change_locale ro_RO.UTF-8
  update-locale LANG=ro_RO.UTF-8 LC_ALL=ro_RO.UTF-8 LANGUAGE=ro_RO.UTF-8
fi

if uptime -p | grep -q hour; then
  # asteptam sa treaca macar 1 ora de la pornirea unPi
  wget -4 -q https://infra.unpi.ro/apps.yml -O /var/run/apps.yml; chmod a+r /var/run/apps.yml; sync
  sudo -iu pi ansible-playbook -i localhost, /var/run/apps.yml --start-at-task="Configurari finale" -e esteundar= -e hashedcode=
  sync
fi

#if uptime -p | grep -qE '(hours|day)'; then
### TODO
#fi

# daca ora este prea tarzie
uptime -p | grep -qE '(up [1-9]+ days|up .. hours)' && shutdown 01:30 "Este timpul sa mergi la somn."

curl -4 -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
