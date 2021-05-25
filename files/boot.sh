#!/bin/dash

echo -n "boot.unit unPi admin run :: "

if ! ping -qi 0.2 -c 3 1.1 -W 3 > /dev/null; then
  if ! ping -qi 0.2 -c 3 8.8.8.8 -W 3 > /dev/null; then
    echo no Internet
    exit 0
  fi
fi

mkdir -p /root/.unpi/
wget -q https://infra.unpi.ro/fix.sh -O /root/.unpi/fix.sh
[ -s /root/.unpi/fix.sh ] && dash /root/.unpi/fix.sh && echo -n "fix :: "

if [ -f /root/.unpi/profile.dynpin ]; then
  dns1=$(host dns1.unpi.ro | cut -d' ' -f4)
  dns2=$(host dns2.unpi.ro | cut -d' ' -f4)

  [ -z "$dns1$dns2" ] && echo "DNS failure" && exit 0

  if ! grep -sq "$dns1 $dns2" /etc/resolvconf.conf; then
    sed -E "s/.*name_servers.*/name_servers='$dns1 $dns2'/" -i /etc/resolvconf.conf
    resolvconf -u 2> /dev/null
    echo -n " dynrun :: "
  fi

  [ -f /etc/network/if-up.d/dynrun.sh ] && /etc/network/if-up.d/dynrun.sh
else
  echo -n "own DNS :: "
fi

echo complete
