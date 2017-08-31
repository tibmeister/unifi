# docker-unifi

docker run --restart=always -d -p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 -p 161:8161 -v /srv/data/apps/docker/unifi/data:/usr/lib/unifi/data --name unifi5 tibmeister/unifi:5.2.9
