FROM ubuntu:16.04

MAINTAINER tibmeister

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /var/log/supervisor /usr/lib/unifi/data && \ 
	touch /usr/lib/unifi/data/.unifidatadir 

ADD /gpgkey.sh /root/gpgkey.sh
CMD apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50
CMD wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg

RUN apt-get update \
	&& apt-get install -y \
	apt-utils \
	wget \
	haveged \
	apt-transport-https \
	&& /root/gpgkey.sh \
	&& update-rc.d haveged defaults

#WORKDIR /tmp
#CMD wget https://dl.ubnt.com/unifi/5.8.24/unifi_sysvinit_all.deb && dpkg -i unifi_sysvinit_all.deb

ADD /100-ubnt.list /etc/apt/sources.list.d/100-ubnt.list
ADD /200-mongo.list /etc/apt/sources.list.d/200-mongo.list

RUN apt-get update \
	&& apt-get install -y \
	binutils \
	ca-certificates-java \
	java-common \
	jsvc \
	libcommons-daemon-java \
        mongodb-server=1:2.6.10-0ubuntu1 \
	unifi=5.10.17-11638-1 \
	&& apt-get autoremove -y \
	&& apt-get autoclean all

#VOLUME /usr/lib/unifi/data 
#EXPOSE  8443 8880 8080 27117 8161
WORKDIR /usr/lib/unifi 

CMD ["java", "-Xmx256M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"] 

LABEL version="5.10.17"
LABEL Description="UniFi controller 5.8.24 with autostart and haveged installed"

