FROM ubuntu:18.04
#FROM mongo:3.6.16-xenial

MAINTAINER tibmeister

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /var/log/supervisor /usr/lib/unifi/data && \ 
	touch /usr/lib/unifi/data/.unifidatadir 

ADD /gpgkey.sh /root/gpgkey.sh

RUN apt-get update \
	&& apt-get install -y \
	apt-utils \
	wget \
	haveged \
	apt-transport-https \
	gnupg2 \
	binutils \
	ca-certificates-java \
	java-common \
	jsvc \
	libcommons-daemon-java \
	&& /root/gpgkey.sh \
	&& update-rc.d haveged defaults

ADD /100-ubnt-unifi.list /etc/apt/sources.list.d/100-ubnt-unifi.list
ADD /200-mongo.list /etc/apt/sources.list.d/200-mongo.list

RUN apt-get update \
	&& apt-get install -y \
        mongodb-org-server=3.4.23 \
	unifi=5.12.35-12979-1 \
	&& apt-get autoremove -y \
	&& apt-get autoclean all

#VOLUME /usr/lib/unifi/data 
#EXPOSE  8443 8880 8080 27117 8161
WORKDIR /usr/lib/unifi 

CMD ["java", "-Xmx256M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"] 

LABEL version="5.12.35-12979-1"
LABEL Description="UniFi controller with autostart and haveged installed"

