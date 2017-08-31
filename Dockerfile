FROM ubuntu:14.04

MAINTAINER tibmeister

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /var/log/supervisor /usr/lib/unifi/data && \ 
	touch /usr/lib/unifi/data/.unifidatadir 


ADD /100-ubnt.list /etc/apt/sources.list.d/100-ubnt.list
ADD /200-mongo.list /etc/apt/sources.list.d/200-mongo.list
ADD /gpgkey.sh /root/gpgkey.sh

RUN /root/gpgkey.sh
RUN apt-get update && \
	apt-get install -y \
	unifi=5.4.11-9184 \
	&& apt-get autoremove -y \
	&& apt-get autoclean all

#VOLUME /usr/lib/unifi/data 
#EXPOSE  8443 8880 8080 27117 8161
WORKDIR /usr/lib/unifi 
CMD ["java", "-Xmx256M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"] 

LABEL version="5.4.11-9184"
LABEL Description="UniFi controller 5.4.11-9184 with autostart"

