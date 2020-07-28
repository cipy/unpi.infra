#!/bin/dash

sudo raspi-config nonint do_overlayfs 1

curl -s http://ping.unpi.ro/ping/fix -A "$(cat /root/.unpi/profile.token | md5sum | cut -d' ' -f1)" -o /dev/null
