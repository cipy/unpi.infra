#!/bin/bash

# script de configurare pentru unPi :: doar pentru Raspbian OS
# sub licenta BSD-3, copyright Ciprian Manea <ciprian@unpi.ro>
# unPi ® este o marca inregistrata in Romania de Ciprian Manea

# face acelasi lucru ca init.sh dar foloseste datele salvate

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

# rulez scriptul redo.sh corect?
if [ "$0" != "redo.sh" ]; then
  # forteza un download al ultimei versiuni redo.sh
  wget -q https://infra.unpi.ro/redo.sh -O redo.sh
  # sterge download-urile facute manual, daca sunt
  rm -f index.html* redo.sh.*
  # ruleaza acum ultima versiune redo.sh
  exec bash redo.sh
fi

touch /tmp/run.init.sh
export DEBIAN_FRONTEND=noninteractive

# este un Debian/Linux OS minim, sau Debian/WSL in Windows?
if ! which wget lsb_release &> /dev/null; then
  echo
  echo "Trebuie sa instalam mai intai aplicatia wget, te rog asteapta putin"
  echo
  sudo apt-get update -y
  sudo apt-get install -y wget lsb-release
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
  # se ruleaza pe un Raspberry Pi / unPi?
  if which vcgencmd &> /dev/null && [ -f /proc/device-tree/model ]; then
    echo
    echo "Pregatim calculatorul personal unPi pentru raportarea erorilor"
    wget -q https://infra.unpi.ro/files/debug/ansible.cfg -O- | sudo tee ansible.cfg &> /dev/null
    wget -q https://infra.unpi.ro/files/debug/22-logdna.conf -O- | sudo tee /etc/rsyslog.d/22-logdna.conf &> /dev/null
    sysid=$(sudo cat /root/.unpi/hashedcode 2>/dev/null | tail -c6 | tr -d -c [:alnum:])
    [ -n "$sysid" ] && sudo sed -i -e "s/%HOSTNAME%/$sysid/" /etc/rsyslog.d/22-logdna.conf
    sysdna=$(sudo cat /root/.unpi/profile.logdna 2>/dev/null)
    [ -n "$sysdna" ] && sudo sed -i -e "s/1d3573d6a76175515af60a4419b1690d/$sysdna/" /etc/rsyslog.d/22-logdna.conf
    sudo mkdir -p /root/.unpi/debug
    sudo service rsyslog restart
    sync
  fi

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
sudo apt-get update -y

if ! which ansible &> /dev/null; then
  echo
  echo "Acum instalam ansible (pentru automatizarile urmatoare)"
  echo
  sudo apt-get install -y ansible
fi

pyver=$(python -V 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)
pyver=${pyver=2}; if [ "$pyver" -lt 3 ]; then pyver=""; fi
# dependinte aditionale pentru ansible, in functie de versiunea python existenta in Raspbian OS
sudo apt-get install -y python$pyver-dnspython python$pyver-passlib python$pyver-scrypt aptitude

if ! which atop htop figlet &> /dev/null; then
  echo
  echo "Acum instalam cateva programe utilitare (evaluarea performantei)"
  echo
  sudo apt-get install -y atop htop figlet
fi

echo
figlet buna/salut
stats

echo "Pregatim calculatorul tau personal unPi pentru re.configurare"
echo
wget -q https://infra.unpi.ro/apps.yml -O apps.yml

export ANSIBLE_STDOUT_CALLBACK=unixy
if [ -s apps.yml ]; then
  sudo mkdir -p /root/.unpi
  # folosim datele deja salvate, daca sunt prezente
  undar=$(sudo cat /root/.unpi/esteundar 2>/dev/null)
  hashed=$(sudo cat /root/.unpi/hashedcode 2>/dev/null)
  ansible-playbook -i localhost, apps.yml -e "esteundar=$undar" -e "hashedcode=$hashed"
fi

if [ -f /proc/device-tree/model ]; then
  # este un Pi Zero WH? adica unPi mini
  if [[ "$(cat /proc/device-tree/model | tr -d '\0')" =~ "Zero" ]]; then
    echo
    echo "Acum facem o configurare specifica pentru unPi mini"
    echo
    wget -q https://infra.unpi.ro/zero.yml -O zero.yml

    export ANSIBLE_STDOUT_CALLBACK=unixy
    [ -s zero.yml ] && ansible-playbook -i localhost, zero.yml
  fi
fi

echo
figlet spor la studiu
rm -f /tmp/run.init.sh
stats
