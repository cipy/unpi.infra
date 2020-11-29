#!/bin/bash

mkdir -p ~/Desktop/"Scratch 3 Curs Video"
cd ~/Desktop/"Scratch 3 Curs Video"

figlet aduc lectiile de Scratch 3
for mov in aspect control detectare evenimente miscare operatori; do
  echo acum aduc $mov.mp4
  wget -nv -c --show-progress http://cache.unpi.ro/cache/scratch/old/$mov.mp4
done

cd
figlet gata.
