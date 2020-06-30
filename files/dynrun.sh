#!/bin/dash

# ignora interfata lo(cala)
[ "$IFACE" = "lo" ] &&  exit 0

if [ -f /root/.unpi/profile.dynpin ]; then
  pin=$(cat /root/.unpi/profile.dynpin)
  wget -q --read-timeout=0.0 --waitretry=5 --tries=12 \
    --background "http://dyn.unpi.ro/$pin" -O /dev/null > /dev/null
fi
