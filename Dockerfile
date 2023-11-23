FROM ubuntu:20.04

MAINTAINER tibmeister

ENV DEBIAN_FRONTEND=noninteractive \
	PGID=999 \
	PUID=999

RUN mkdir -p /var/log/supervisor /usr/lib/unifi/data && \
	touch /usr/lib/unifi/data/.unifidatadir

ADD /gpgkey.sh /root/gpgkey.sh

RUN set -x \
	&& groupadd -r unifi -g $PGID \
	&& useradd --no-log-init -r -u $PUID -g $PGID unifi \
	&& apt update -y \
	&& apt --no-install-recommends install -y \
	apt-utils \
	&& apt --no-install-recommends install -y \
	iputils-ping \
	binutils \
	curl \
	bash-completion \
	dirmngr \
	gosu \
	libcap2 \
	libcap2-bin \
	procps \
	wget \
	haveged \
	apt-transport-https \
	gnupg2 \
	binutils \
	ca-certificates-java \
	openjdk-17-jre-headless

RUN set -x && apt --no-install-recommends install -y mongodb-server-core
RUN set -x /root/gpgkey.sh \
	&& update-rc.d haveged defaults

ADD /100-ubnt-unifi.list /etc/apt/sources.list.d/100-ubnt-unifi.list

RUN wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg \
	&& apt-get update --allow-releaseinfo-change -y \
	&& apt-get install -y \
	unifi=8.0.7-24256-1 \
	&& apt-get autoremove -y \
	&& apt-get autoclean all

WORKDIR /usr/lib/unifi

CMD ["java", "-Xmx256M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]

LABEL version="8.0.7-24256-1"
LABEL Description="UniFi controller with autostart and haveged installed"

