#!/bin/bash

docker build -t tibmeister/unifi:5.5.20-9565 .
docker tag tibmeister/unifi:5.5.20-9565 tibmeister/unifi:latest
docker push tibmeister/unifi:5.5.20-9565 
#docker push tibmeister/unifi:latest
