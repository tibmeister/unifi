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
    less \
    gosu

# MongoDB 6.x packages depend on libssl1.1 which is no longer in bookworm, so
# temporarily pull it from bullseye while keeping other packages on bookworm.
echo "deb http://deb.debian.org/debian bullseye main" \
    > /etc/apt/sources.list.d/bullseye.list
cat <<'EOF' > /etc/apt/preferences.d/bullseye.pref
Package: *
Pin: release n=bullseye
Pin-Priority: 50
EOF
cat <<'EOF' > /etc/apt/preferences.d/libssl1.1.pref
Package: libssl1.1
Pin: release n=bullseye
Pin-Priority: 990
EOF
apt update
apt install -qy --no-install-recommends libssl1.1

# MongoDB packages were removed from Debian starting in bookworm, so hook up
# MongoDB's own repository to satisfy the UniFi deb dependencies.
MONGO_MAJOR=6.0
MONGO_DISTRO=$(. /etc/os-release && echo "${VERSION_CODENAME}")
# MongoDB does not publish bookworm packages yet; bullseye packages work fine.
if [ "${MONGO_DISTRO}" = "bookworm" ] || [ -z "${MONGO_DISTRO}" ]; then
    MONGO_DISTRO="bullseye"
fi
MONGO_KEYRING="/usr/share/keyrings/mongodb-server-${MONGO_MAJOR}.gpg"
MONGO_APT_LIST="/etc/apt/sources.list.d/mongodb-org-${MONGO_MAJOR}.list"
curl -fsSL "https://pgp.mongodb.com/server-${MONGO_MAJOR}.asc" \
    | gpg --batch --yes --dearmor -o "${MONGO_KEYRING}"
printf "deb [ arch=%s signed-by=%s ] https://repo.mongodb.org/apt/debian %s/mongodb-org/%s main\n" \
    "$(dpkg --print-architecture)" "${MONGO_KEYRING}" "${MONGO_DISTRO}" "${MONGO_MAJOR}" \
    > "${MONGO_APT_LIST}"
apt update
apt install -qy --no-install-recommends mongodb-org

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
