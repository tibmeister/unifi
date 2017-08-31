#!/bin/bash

docker build -t tibmeister/unifi:5.4.11 .
docker tag tibmeister/unifi:5.4.11 tibmeister/unifi:latest
docker push tibmeister/unifi:5.4.11 
docker push tibmeister/unifi:latest
