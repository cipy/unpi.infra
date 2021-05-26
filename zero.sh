#!/bin/bash
# zero quick

echo
echo "Acum facem o re.configurare specifica pentru unPi mini"
echo
wget -4 -q https://infra.unpi.ro/zero.yml -O zero.yml

touch /tmp/run.init.sh
export ANSIBLE_STDOUT_CALLBACK=unixy
[ -s zero.yml ] && ansible-playbook -i localhost, zero.yml

echo
figlet gata
rm -f /tmp/run.init.sh
sync
