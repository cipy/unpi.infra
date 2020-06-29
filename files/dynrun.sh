#!/bin/dash

# ignora interfata lo(cala)
[ "$IFACE" = "lo" ] &&  exit 0

if [ -f /root/.unpi/profile.dynpin ]; then
  pin=$(cat /root/.unpi/profile.dynpin)
  curl -Ls "http://dyn.unpi.ro/$pin" -o /dev/null
fi
