#!/bin/bash

docker build -t docker1:5000/unifi:5.4.11 .
docker tag docker1:5000/unifi:5.4.11 docker1:5000/unifi:latest
docker push docker1:5000/unifi:5.4.11 
docker push docker1:5000/unifi:latest
