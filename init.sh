#!/bin/bash

# script de initializare pentru unPi :: doar pentru Raspbian OS
# sub licenta BSD-3, copyright Ciprian Manea <ciprian@unpi.ro>
# unPi ® este o marca inregistrata in Romania de Ciprian Manea

ERR_NOOS="Imi pare rau, doar Raspbian/Linux OS este recomandat pentru unPi"
ERR_INET="Imi pare rau, dar trebuie sa fii online, conectat la Internet!"

trap ctrl_c INT

function ctrl_c
{
  say=$(which figlet || which echo)
  echo
  $say CTRL-C, STOP
  exit 1
}

# se ruleaza pe un Linux OS?
if [ ! -f /etc/issue ]; then echo $ERR_NOOS; exit 1; fi

linuxos="$(cat /etc/issue)"
# se ruleaza pe Raspbian sau Debian Linux?
if [[ ! "$linuxos" =~ "bian" ]]; then echo $ERR_NOOS; exit 1; fi

echo
# exista o conexiune online la Intenet?
echo "Verific conexiunea ta la Internet"
if ! ping -i 0.2 -c 3 1.1 -W 3 &> /dev/null; then echo $ERR_INET; exit 2; fi

export DEBIAN_FRONTEND=noninteractive

# este un Debian/Linux OS minim, sau Debian/WSL in Windows?
if ! which wget lsb_release &> /dev/null; then
  echo
  echo "Trebuie sa instalam mai intai aplicatia wget, te rog asteapta putin"
  echo
  sudo apt update -y
  sudo apt install -y wget lsb-release
fi

# rulez scriptul init.sh corect?
if [ "$0" != "init.sh" ]; then
  # forteza un download al ultimei versiuni init.sh
  wget -q https://infra.unpi.ro/init.sh -O init.sh
  # sterge download-urile facute manual, daca sunt
  rm -f index.html* init.sh.*
  # ruleaza acum ultima versiune init.sh
  exec bash init.sh
fi

function stats
{
  # se ruleaza pe un Raspberry Pi / unPi?
  if which vcgencmd &> /dev/null && [ -f /proc/device-tree/model ]; then
    echo
    echo -n "Calculatorul tau este un " && cat /proc/device-tree/model && echo
    echo "Temperatura procesorului central este acum $(vcgencmd measure_temp | cut -d= -f2) grade"
    echo "Frecventa procesorului este acum $(vcgencmd measure_clock arm | cut -d= -f2 | sed -E 's/[0-9]{6}$//') Mhz"
    echo "Frecventa placii de baza este $(vcgencmd measure_clock core | cut -d= -f2 | sed -E 's/[0-9]{6}$//') Mhz"
    echo
  fi
  # forteaza un sync pe disk/microSD daca au fost instalate programe noi
  sync
}

# modelul unPi pe care se ruleaza
if [ -f /proc/device-tree/model ]; then
  model=$(cat /proc/device-tree/model | tr -d '\0')
  [[ "$model" =~ "Zero" ]] && eMIN=yes
  [[ "$model" =~ "Pi 3" ]] && eSTD=yes
  [[ "$model" =~ "Pi 4" ]] && ePRO=yes
fi

if which raspi-config &> /dev/null; then
  echo
  echo -n "Acum configuram unPi pentru: limba romana, tastatura si fus orar "
  grep -vE '^#' /etc/locale.gen | grep -q ro_RO || sudo raspi-config nonint do_change_locale ro_RO.UTF-8 &> /dev/null
  grep -qE 'XKBLAYOUT=.us.' /etc/default/keyboard || sudo raspi-config nonint do_configure_keyboard us &> /dev/null
  sudo grep -qE 'country=' /etc/wpa_supplicant/wpa_supplicant.conf || sudo raspi-config nonint do_wifi_country RO &> /dev/null
  grep -qE 'Bucharest' /etc/timezone || sudo raspi-config nonint do_change_timezone Europe/Bucharest &> /dev/null
  echo OK
fi

echo
echo "Pregatim sistemul de operare pentru a instala programe noi"
echo
sudo apt update -y

py2d="$(dpkg -l | grep python- | grep -E '(dns|scrypt)' | wc -l)"
py3d="$(dpkg -l | grep python3- | grep -E '(dns|scrypt)' | wc -l)"

# daca lipsesc oricare din dependinte, instaleaza-le pe toate
if ! which ansible &> /dev/null || [ "$py2d" -lt 2 -o "$py3d" -lt 2 ]; then
  echo
  echo "Acum instalam ansible (pentru automatizarile urmatoare)"
  echo
  sudo apt install -y ansible python-dnspython python3-dnspython \
    python-passlib python3-passlib python-scrypt python3-scrypt aptitude
fi

if ! which atop htop figlet &> /dev/null; then
  echo
  echo "Acum instalam cateva programe utilitare (evaluarea performantei)"
  echo
  sudo apt install -y atop htop figlet
fi

echo
figlet buna/salut
stats

echo "Pregatim calculatorul tau personal unPi pentru configurare"
echo
wget -q https://infra.unpi.ro/apps.yml -O apps.yml

export ANSIBLE_STDOUT_CALLBACK=unixy
[ -s apps.yml ] && ansible-playbook -i localhost, apps.yml \
  -e "MIN=$eMIN" -e "STD=$eSTD" -e "PRO=$ePRO"

# este un Pi Zero? adica unPi mini
if [ "$eMIN" == "yes" ]; then
  echo "Acum facem o configurare specifica pentru unPi mini"
  echo
  wget -q https://infra.unpi.ro/zero.yml -O zero.yml

  export ANSIBLE_STDOUT_CALLBACK=unixy
  [ -s zero.yml ] && ansible-playbook -i localhost, zero.yml
fi

echo
figlet spor la studiu
stats
