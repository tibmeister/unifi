#!/bin/bash

docker build -t tibmeister/unifi:5.6.29-10253 .
docker tag tibmeister/unifi:5.6.29-10253 tibmeister/unifi:latest
docker push tibmeister/unifi:5.6.29-10253
docker push tibmeister/unifi:latest
