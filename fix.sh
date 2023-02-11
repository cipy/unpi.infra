#!/bin/dash

logger unpi fixing time

logger running on an $(cat /proc/device-tree/model)

# uneori e bine sa resetam browserul
rm -rf /home/pi/.config/chromium/Default

# daca ssh este cumva activ
[ ! -f /root/.unpi/help ] && systemctl start ssh

# la chindii nu incarca sistemul cu operatii suplimentare
if [ "$(date +%H)" -lt 17 -o "$(date +%H)" -gt 19 ]; then
  # daca init.sh sau redo.sh nu ruleaza si nu este tarziu
  if [ ! -f /tmp/run.init.sh -a "$(date +%H)" -ne 0 ]; then

    # configureaza limba romana
    if grep -Ev '^#' /etc/default/locale | grep -qv ro_RO; then
      raspi-config nonint do_change_locale ro_RO.UTF-8
      update-locale LANG=ro_RO.UTF-8 LC_ALL=ro_RO.UTF-8 LANGUAGE=ro_RO.UTF-8
    fi

    # pregateste debug daca e necesar
    if [ -d /root/.unpi/debug ]; then
      sysdna=$(cat /root/.unpi/profile.logdna 2>/dev/null)
      sysid=$(cat /root/.unpi/hashedcode 2>/dev/null | tail -c6 | tr -d -c [:alnum:])
      [ -n "$sysid" ] && sed -i -e "s/%HOSTNAME%/$sysid/" /etc/rsyslog.d/22-logdna.conf
      [ -n "$sysdna" ] && sed -i -e "s/1d3573d6a76175515af60a4419b1690d/$sysdna/" /etc/rsyslog.d/22-logdna.conf
      [ -n "$sysid$sysdna" ] && service rsyslog force-reload
      sync
    fi

    if uptime -p | grep -q hour; then
      # asteptam sa treaca macar 1 ora de la pornirea unPi
      wget -q https://infra.unpi.ro/apps.yml -O /var/run/apps.yml; chmod a+r /var/run/apps.yml; sync
      sudo -iu pi ansible-playbook -i localhost, /var/run/apps.yml --start-at-task="Configurari finale" -e esteundar= -e hashedcode=
      DEBIAN_FRONTEND=noninteractive apt-get update --allow-releaseinfo-change -q
      sync
    fi

    if uptime -p | grep -qE '(hour|day)'; then
    # dupa 1 ora uptime incercam un full update
      if [ ! -f /tmp/ran.fix.sh ]; then
        wget -q https://infra.unpi.ro/files/gui/warn.py -O /var/run/warn.py; chmod a+r /var/run/warn.py; sync
        sudo -u pi DISPLAY=:0 python3 /var/run/warn.py &
        lastpid=$!
        undar=$(cat /root/.unpi/esteundar 2>/dev/null)
        hashed=$(cat /root/.unpi/hashedcode 2>/dev/null)
        su -l pi -c "ansible-playbook -i localhost, /var/run/apps.yml -e esteundar='$undar' -e hashedcode='$hashed'"
        touch /tmp/ran.fix.sh
        kill $lastpid
        sync
      fi
    fi
    
    wget -c https://rpf.io/fl-guis-emojis -O /var/tmp/emojis.zip
    unzip -n /var/tmp/emojis.zip -d /var/tmp/
  fi
fi

# daca ora este prea tarzie
uptime -p | grep -qE '(week|day|up .. hours)' && shutdown 00:55 "Este timpul sa mergi la somn."

#DEBIAN_FRONTEND=noninteractive raspi-config nonint do_vnc 0

curl -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
