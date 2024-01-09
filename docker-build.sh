#!/usr/bin/env bash

# Fail on errors
set -e

# Try the passed command up to 5 times
trycommand() {
    for i in $(seq 1 5);
        do [ $i -gt 1 ] && sleep 10; $* && s=0 && break || s=$?; done;
    (exit $s)
}

if [ "x${1}" == "x" ]; then
    echo PKG_URL not passed as an environment variable
    exit 0
fi

apt update
apt install -qy --no-install-recommends apt-utils
apt update && apt upgrade -y
apt install -qy --no-install-recommends \
    apt-transport-https \
    curl \
    dirmngr \
    gpg \
    gpg-agent \
    openjdk-17-jre-headless \
    procps \
    libcap2-bin \
    tzdata \
    haveged \
    gosu

update-rc.d haveged defaults

if [ -d "/usr/local/docker/pre_build/$(dpkg --print-architecture)" ]; then
    find "/usr/local/docker/pre_build/$(dpkg --print-architecture)" -type f -exec '{}' \;
fi

groupadd -r unifi -g $UNIFI_GID && useradd --no-log-init -r -u $UNIFI_UID -g $UNIFI_GID unifi

mkdir -p /unifi \
	/usr/unifi \
	/usr/local/unifi/init.d \
	/usr/unifi/init.d \
	/usr/local/docker \
	/var/log/supervisor \
	/usr/lib/unifi/data && \
	touch /usr/lib/unifi/data/.unifidatadir

curl -L -o ./unifi.deb "${1}"
apt -qy install ./unifi.deb
rm -f ./unifi.deb
chown -R unifi:unifi /usr/lib/unifi /var/log/unifi /var/run/unifi
rm -rf /var/lib/apt/lists/*

rm -Rf ${ODATADIR} ${OLOGDIR} ${ORUNDIR} ${BASEDIR}/data ${BASEDIR}/run ${BASEDIR}/logs
mkdir -p ${DATADIR} ${LOGDIR} ${RUNDIR}
ln -s ${DATADIR} ${BASEDIR}/data
ln -s ${RUNDIR} ${BASEDIR}/run
ln -s ${LOGDIR} ${BASEDIR}/logs
ln -s ${DATADIR} ${ODATADIR}
ln -s ${LOGDIR} ${OLOGDIR}
ln -s ${RUNDIR} ${ORUNDIR}
mkdir -p /var/cert ${CERTDIR}
ln -s ${CERTDIR} /var/cert/unifi

chown -R unifi:unifi /unifi

rm -rf "${0}"