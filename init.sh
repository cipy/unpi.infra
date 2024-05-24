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

touch /tmp/run.init.sh
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

if which raspi-config &> /dev/null; then
  echo
  echo -n "Acum configuram unPi pentru: limba romana, tastatura si fus orar "
  grep -vE '^#' /etc/locale.gen | grep -q ro_RO || sudo raspi-config nonint do_change_locale ro_RO.UTF-8 &> /dev/null
  grep -vE '^#' /etc/default/locale | grep -qv ro_RO && sudo update-locale LANG=ro_RO.UTF-8 LC_ALL=ro_RO.UTF-8 LANGUAGE=ro_RO.UTF-8 &> /dev/null
  grep -qE 'XKBLAYOUT=.(us|fi).' /etc/default/keyboard || sudo raspi-config nonint do_configure_keyboard us &> /dev/null
  sudo grep -qE 'country=' /etc/wpa_supplicant/wpa_supplicant.conf || sudo raspi-config nonint do_wifi_country RO &> /dev/null
  grep -qE 'Bucharest' /etc/timezone || sudo raspi-config nonint do_change_timezone Europe/Bucharest &> /dev/null
  echo OK
fi

echo
echo "Pregatim sistemul de operare pentru a instala programe noi"
echo
sudo apt update -y

if ! which ansible &> /dev/null; then
  echo
  echo "Acum instalam ansible (pentru automatizarile urmatoare)"
  echo
  sudo apt install -y ansible
fi

if [[ "$(lsb_release -c)" =~ "buster" ]]; then
  # Debian/Buster este sigurul ce mai foloseste py2 & py3 cu ansible
  sudo apt install -y python-dnspython python-passlib python-scrypt 
fi
# dependinte aditionale pentru noua versiune ansible
sudo apt install -y python3-dnspython python3-passlib python3-scrypt aptitude

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
[ -s apps.yml ] && LC_ALL=C.UTF-8 ansible-playbook -i localhost, apps.yml

if [ -f /proc/device-tree/model ]; then
  # este un RPi Zero 2? adica unPi mini
  if [[ "$(cat /proc/device-tree/model | tr -d '\0')" =~ "Zero 2" ]]; then
    echo
    echo "Acum facem o configurare specifica pentru unPi mini"
    echo
    wget -q https://infra.unpi.ro/zero.yml -O zero.yml

    export ANSIBLE_STDOUT_CALLBACK=unixy
    [ -s zero.yml ] && LC_ALL=C.UTF-8 ansible-playbook -i localhost, zero.yml
  fi
fi

echo
figlet spor la studiu
rm -f /tmp/run.init.sh
stats
