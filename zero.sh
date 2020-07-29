echo
echo "Acum facem o configurare specifica pentru unPi mini"
echo
wget -q https://infra.unpi.ro/zero.yml -O zero.yml

export ANSIBLE_STDOUT_CALLBACK=unixy
[ -s zero.yml ] && ansible-playbook -i localhost, zero.yml

echo
figlet gata
