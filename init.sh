#!/bin/bash

# script de initializare pentru unPi :: doar pentru Raspbian OS
# sub licenta BSD-3, copyright Ciprian Manea <ciprian@unpi.ro>
# unPi ® este o marca inregistrata in Romania de Ciprian Manea

ERR_NOOS="Imi pare rau, doar Raspbian/Linux OS este recomandat pentru unPi"
ERR_INET="Imi pare rau, dar trebuie sa fii online, conectat la Internet"

# se ruleaza pe un Linux OS?
linuxos="$(which lsb_release)"
if [ -z "$linuxos" ]; then echo $ERR_NOOS; exit 1; fi

# se ruleaza pe Raspbian sau Debian Linux?
if [[ ! "$(lsb_release -d)" =~ "bian" ]]; then echo $ERR_NOOS; exit 1; fi

# seamana cu Rasbian OS dar este Debian/WSL poate?
if ! which apt sudo wget &> /dev/null; then echo $ERR_NOOS; exit 1; fi

# exista o conexiune online la Intenet?
if ! ping -i 0.2 -c 3 1.1 -W 3 &> /dev/null; then echo $ERR_INET; exit 2; fi

# rulez scriptul init.sh corect?
if [ "$0" != "init.sh" ]; then
  # forteza un download al ultimei versiuni init.sh
  wget -q https://infra.unpi.ro/init.sh -O init.sh
  # sterge download-urile facute manual daca sunt
  rm -f init.sh.*
  # ruleaza acum ultima versiune init.sh
  exec bash init.sh
fi

echo
echo "Pregatim sistemul de operare pentru a instala cateva programe"
echo
sudo apt update

echo
echo "Acum instalam ansible (pentru automatizarile urmatoare)"
echo
sudo apt install -y ansible

echo
echo "Acum instalam cateva programe utilitare (evaluarea performantei)"
echo
sudo apt install -y atop htop figlet

figlet buna/salut
