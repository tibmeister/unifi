FROM ubuntu:20.04
LABEL version="8.1.113"
LABEL Description="UniFi controller with autostart and haveged installed"

ARG DEBIAN_FRONTEND=noninteractive

# Pulled from https://ui.com/download/releases/network-server
ARG PKG_URL=https://dl.ui.com/unifi/8.1.113/unifi_sysvinit_all.deb

ENV BASEDIR=/usr/lib/unifi \
	DATADIR=/unifi/data \
	LOGDIR=/unifi/logs \
	CERTDIR=/unifi/cert \
	RUNDIR=/unifi/run \
	ORUNDIR=/var/run/unifi \
	ODATADIR=/var/lib/unifi \
	OLOGDIR=/var/log/unifi \
	CERTNAME=cert.pem \
	CERT_PRIVATE_NAME=privkey.pem \
	CERT_IS_CHAIN=false \
	BIND_PRIV=false \
	RUNAS_UID0=false \
	UNIFI_GID=1000 \
	UNIFI_UID=1000 \
	TIMEZONE=Etc/UTC

COPY docker-build.sh /usr/local/bin/

RUN  chmod +x /usr/local/bin/docker-build.sh

RUN set -ex \
	&& /usr/local/bin/docker-build.sh "${PKG_URL}"

COPY docker-entry.sh /usr/local/bin/

WORKDIR "${BASEDIR}"

ENTRYPOINT ["/usr/local/bin/docker-entry.sh"]

CMD ["unifi"]
