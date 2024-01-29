#!/bin/bash

log() {
    echo "$(date +"[%Y-%m-%d %T,%3N]") <docker-entrypoint> $*"
}

exit_handler() {
    log "Exit signal received, shutting down"
    java -jar ${BASEDIR}/lib/ace.jar stop
    for i in `seq 1 10` ; do
        [ -z "$(pgrep -f ${BASEDIR}/lib/ace.jar)" ] && break
        # graceful shutdown
        [ $i -gt 1 ] && [ -d ${BASEDIR}/run ] && touch ${BASEDIR}/run/server.stop || true
        # savage shutdown
        [ $i -gt 7 ] && pkill -f ${BASEDIR}/lib/ace.jar || true
        sleep 1
    done
    # shutdown mongod
    if [ -f ${MONGOLOCK} ]; then
        mongo localhost:${MONGOPORT} --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null 2>&1
    fi
    exit ${?};
}

confSet () {
  file=$1
  key=$2
  value=$3
  if [ "$newfile" != true ] && grep -q "^${key} *=" "$file"; then
    ekey=$(echo "$key" | sed -e 's/[]\/$*.^|[]/\\&/g')
    evalue=$(echo "$value" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/^\(${ekey}\s*=\s*\).*$/\1${evalue}/" "$file"
  else
    echo "${key}=${value}" >> "$file"
  fi
}

trap 'kill ${!}; exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

DEBCONF_NONINTERACTIVE_SEEN=true
DEBIAN_FRONTEND=noninteractive

MONGOPORT=${MONGOPORT:-27117}
DATALINK=${BASEDIR}/data
LOGLINK=${BASEDIR}/logs
RUNLINK=${BASEDIR}/run
ENABLE_UNIFI=yes
UNIFI_USER=${UNIFI_USER:-unifi}
UNIFI_GROUP=$(id -gn ${UNIFI_USER})
MONGOLOCK="${DATADIR}/db/mongod.lock"
UNIFI_UID=$(id -u ${UNIFI_USER})
DATADIR_UID=$(stat ${DATADIR} -Lc %u)
UNIFI_CORE_ENABLED=${UNIFI_CORE_ENABLED:-"false"}
UNIFI_JVM_OPTS=${UNIFI_JVM_OPTS:-"-Xmx1024M -XX:+UseParallelGC"}
PIDFILE=/var/run/unifi/unifi.pid
CUID=$(id -u)

confFile="${DATADIR}/system.properties"
if [ -e "$confFile" ]; then
  newfile=false
else
  newfile=true
fi

declare -A settings

# Basic settings
#Reduce mongodb IO
settings["unifi.db.nojournal"]="true"
settings["unifi.db.extraargs"]="--quiet"

if [[ -z "$PORTAL_HTTP_PORT"  ]]; then
  settings["portal.http.port"]="$PORTAL_HTTP_PORT"
fi

if [[ -z "$PORTAL_HTTPS_PORT"  ]]; then
  settings["portal.https.port"]="$PORTAL_HTTPS_PORT"
fi

if [[ -z "$UNIFI_HTTP_PORT"  ]]; then
  settings["unifi.http.port"]="$UNIFI_HTTP_PORT"
fi

if [[ -z "$UNIFI_HTTPS_PORT"  ]]; then
  settings["unifi.https.port"]="$UNIFI_HTTPS_PORT"
fi

if [[ "$UNIFI_STDOUT" == "true" ]]; then
  settings["unifi.logStdout"]="true"
fi

# Documentation for these settings here
# https://help.ui.com/hc/en-us/articles/115005159588-UniFi-Tuning-the-Network-Application-for-a-High-Number-of-UniFi-Devices
if [[ -z "$UNIFI_MAX_MEMORY" ]]; then
    settings["unifi.xmx"]="$UNIFI_MAX_MEMORY"
    settings["unifi.xms"]="$UNIFI_MAX_MEMORY"
fi

if [[ -a "$Java_HPGC" ]]; then
    settings["unifi.G1GC.enabled"]="true"
fi

if [[ "${@}" == "unifi" ]]; then
    rm -f /var/run/unifi/unifi.pid

    log "Setting Timezone to ${TIMEZONE}"
    ln -fs "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata

    # log 'Starting mongodb.'
    # mongod --dbpath "${DATADIR}" --logpath "${LOGDIR}/mongod.log" --fork

    log 'Starting unifi controller service.'

    UNIFI_CMD="/usr/bin/java \
        -Dfile.encoding=UTF-8 \
        -Djava.awt.headless=true \
        -Dapple.awt.UIElement=true \
        -Dunifi.core.enabled=${UNIFI_CORE_ENABLED} \
        ${UNIFI_JVM_OPTS} \
        -XX:+ExitOnOutOfMemoryError \
        -XX:+CrashOnOutOfMemoryError \
        -XX:ErrorFile=${LOGDIR}/hs_err_pid%p.log \
        -Dunifi.datadir=${DATADIR} \
        -Dunifi.logdir=${LOGDIR} \
        -Dunifi.rundir=${RUNDIR} \
        --add-opens java.base/java.lang=ALL-UNNAMED \
        --add-opens java.base/java.time=ALL-UNNAMED \
        --add-opens java.base/sun.security.util=ALL-UNNAMED \
        --add-opens java.base/java.io=ALL-UNNAMED \
        --add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED \
        -jar ${BASEDIR}/lib/ace.jar start"

    cd ${BASEDIR}

    if [ "$(id unifi -u)" != "${UNIFI_UID}" ] || [ "$(id unifi -g)" != "${UNIFI_GID}" ]; then
        log "INFO: Changing 'unifi' UID to '${UNIFI_UID}' and GID to '${UNIFI_GID}'"
        usermod -o -u ${UNIFI_UID} unifi && groupmod -o -g ${UNIFI_GID} unifi
    fi

    # Only set if the file doesn't exist for now.  Later, we will parse the file and switch settings
    if ! [[ -f "${confFile}" ]]; then
        log 'Setting up a default system.properties file'
        touch "${confFile}"
        for key in "${!settings[@]}"; do
        confSet "$confFile" "$key" "${settings[$key]}"
        done
    fi

    if [ "${RUNAS_UID0}" == "true" ] || [ "${CUID}" != "0" ]; then
        if [ "${CUID}" == 0 ]; then
            log 'WARNING: Running UniFi in insecure (root) mode'
        fi
        ${UNIFI_CMD} &
    elif [ "${RUNAS_UID0}" == "false" ]; then
        if [ "${BIND_PRIV}" == "true" ]; then
            if setcap 'cap_net_bind_service=+ep' "${JAVA_HOME}/bin/java"; then
                sleep 1
            else
                log "ERROR: setcap failed, can not continue"
                log "ERROR: You may either launch with -e BIND_PRIV=false and only use ports >1024"
                log "ERROR: or run this container as root with -e RUNAS_UID0=true"
                exit 1
            fi
        fi
    fi

    if [ "$(id unifi -u)" != "${UNIFI_UID}" ] || [ "$(id unifi -g)" != "${UNIFI_GID}" ]; then
        log "INFO: Changing 'unifi' UID to '${UNIFI_UID}' and GID to '${UNIFI_GID}'"
        usermod -o -u ${UNIFI_UID} unifi && groupmod -o -g ${UNIFI_GID} unifi
    fi
    gosu unifi:unifi ${UNIFI_CMD} &
    wait
    log "WARN: unifi service process ended without being signaled? Check for errors in ${LOGDIR}." >&2
else
    log "Executing: ${@}"
    exec ${@}
fi
exit 1