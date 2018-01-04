[ubilogo]: https://prd-www-cdn.ubnt.com/media/images/dashboard/logos/unifi.svg

# docker-unifi
<a href="https://www.ubnt.com/enterprise/#unifi">
<img src="https://prd-www-cdn.ubnt.com/media/images/dashboard/logos/unifi.svg" width="250" height="250" />
</a>
<p>
The UniFi® Controller software is a powerful, enterprise wireless software engine ideal for high-density client deployments requiring low latency and high uptime performance. (https://www.ubnt.com/enterprise/#unifi)
</p>
<p>
This project is aimed to provide a turn-key solution for running the UniFi® Controller software in a Docker Swarm using v3 compose files to create a stack.
</p>

[Unifi Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)

Determining the install method, I use this page:
[Install via Apt](https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-Update-via-APT-on-Debian-or-Ubuntu)

This is the Ubiquiti's UniFi software that has been nicely wrapped into a container.  In order to effectively run this, you will need to mount a volume for the container to store the MongoDB information in so that persistence exists.

In order to run, here is an example that mounts a separate log and data volume into the container.  This also has the ports exposed that allow for L-2 discovery as well as general access to the controller using http://{controller}:8443/

docker run --restart=always -d -p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 -p 161:8161 -p 6789:6789 -v /opt/unifi/data:/usr/lib/unifi/data -v /opt/unifi/logs:/usr/lib/unifi/logs --name unifi5 tibmeister/unifi:latest
