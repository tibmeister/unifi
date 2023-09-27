[ubilogo]: https://prd-www-cdn.ubnt.com/media/images/dashboard/logos/unifi.svg

# docker-unifi

![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/tibmeister/unifi/dockerhub_push.yml?style=plastic&label=CI%20Build%20to%20DockerHub)
[![Docker Pulls](https://img.shields.io/docker/pulls/tibmeister/unifi.svg?style=plastic&label=DockerHub%20Pulls)](https://hub.docker.com/r/tibmeister/unifi/)
![GitHub issues](https://img.shields.io/github/issues/tibmeister/unifi?style=plastic&label=Issues)
![GitHub](https://img.shields.io/github/license/tibmeister/unifi?style=plastic&label=License)

[![UBNT](https://dl.ubnt.com/press/Company_Logos/Alternate/WEB/UBNT_Alternate_Logo_RGB.png)](https://www.ubnt.com)
![UniFi Logo](https://dl.ubnt.com/press/logo-UniFi.png)

The UniFi® Controller software is a powerful, enterprise wireless software engine ideal for high-density client deployments requiring low latency and high uptime performance. (https://www.ubnt.com/enterprise/#unifi)

This project is aimed to provide a turn-key solution for running the UniFi® Controller software in a Docker Swarm using v3 compose files to create a stack.

[Unifi Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)

Determining the install method, I use this page:
[Install via Apt](https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-Update-via-APT-on-Debian-or-Ubuntu)

This is the Ubiquiti's UniFi software that has been nicely wrapped into a container.  In order to effectively run this, you will need to mount a volume for the container to store the MongoDB information in so that persistence exists.

In order to run, here is an example that mounts a separate log and data volume into the container.  This also has the ports exposed that allow for L-2 discovery as well as general access to the controller using http://{host_ip}:8443/

docker run --restart=always -d -p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 -p 161:8161 -p 6789:6789 -v /opt/unifi/data:/usr/lib/unifi/data -v /opt/unifi/logs:/usr/lib/unifi/logs --name unifi5 tibmeister/docker-unifi:latest
