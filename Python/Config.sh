#!/bin/bash
#on met à jour le systeme
apt-get update

#on install les packages nécessaire 
sudo apt-get install cups cups-bsd python3-cups python3-picamera python3-rpi.gpio python3-pip python3-tkinter -y

#Installation d'autres packages nécessaire au fonctionnement de la caméra
sudo apt-get install python-dev libjpeg-dev libjpeg8-dev libpng3 libfreetype6-dev

#lien symbolique
ln -s /usr/lib/i386-linux-gnu/libfreetype.so /usr/lib
ln -s /usr/lib/i386-linux-gnu/libjpeg.so /usr/lib
ln -s /usr/lib/i386-linux-gnu/libz.so /usr/lib

#Installation du module Pillow
sudo pip install pillow

#Autorisation d'administrer CUPS avec pi    
sudo usermod -a -G lpadmin pi

#on redémarre cups
sudo /etc/init.d/cups restart

