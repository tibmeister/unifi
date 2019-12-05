#!/bin/bash

# for Ubiquiti
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50

wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg 

# for mongo-10gen [optional]
#apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

# or over HTTP by using hkp://keyserver.ubuntu.com:80
