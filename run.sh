#!/bin/bash

#docker run --restart=always -d -p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 -p 161:8161 -p 6789:6789 -v /srv/data/apps/docker/unifi/data:/usr/lib/unifi/data --name unifi5 tibmeister/unifi:5.4.11
docker run --restart=always -d -p 3478:3478/udp -p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 -p 8161:161/udp -p 6789:6789 -v /nfs/swarm/unifi/data:/usr/lib/unifi/data -v /nfs/swarm/unifi/logs:/usr/lib/unifi/logs --name unifi5 tibmeister/unifi:5.6.29-10253
