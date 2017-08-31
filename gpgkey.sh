#!/bin/bash

# for Ubiquiti
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50

# for mongo-10gen [optional]
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

# or over HTTP by using hkp://keyserver.ubuntu.com:80
