#!/bin/bash

docker build -t tibmeister/unifi:5.6.26-10236 .
docker tag tibmeister/unifi:5.6.26-10236 tibmeister/unifi:latest
docker push tibmeister/unifi:5.6.26-10236
docker push tibmeister/unifi:latest
