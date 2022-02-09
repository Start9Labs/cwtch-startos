#!/bin/sh

_term() {
  echo "caught SIGTERM signal!"
  kill -TERM "$@" 2>/dev/null
}

set -o errexit
set -ea

chmod_files() { find $2 -type f -exec chmod -v $1 {} \;
}
chmod_dirs() { find $2 -type d -exec chmod -v $1 {} \;
}

chown ${TOR_USER}:${TOR_USER} /run/tor/
chmod 770 /run/tor

chown -Rv ${TOR_USER}:${TOR_USER} /var/lib/tor
chmod_dirs 700 /var/lib/tor
chmod_files 600 /var/lib/tor

echo -e "\n========================================================"

# Display OS version, Tor version & torrc in log
echo -e "Alpine Version: \c" && cat /etc/alpine-release
tor --version
#cat /etc/tor/torrc
echo -e "========================================================\n"
echo -e "========================= End of Startup ========================\n"
tor -f /etc/tor/torrc
echo -e "========================= Tor Startup ========================\n"

#Cwtch will crash and burn if 9051 isn't ready
echo -e "========== Sleep 15 v3 ==============="
sleep 15
echo -e "========== End Sleep 15 ==============="
if [ -z "${CWTCH_CONFIG_DIR}" ]; then
	CWTCH_CONFIG_DIR=/etc/cwtch/
fi

# Properties 
echo '    type: string' >> /root/persistence/start9/stats.yaml
echo '    description: Password to use with the account' >> /root/persistence/start9/stats.yaml
echo '    copyable: true' >> /root/persistence/start9/stats.yaml
echo '    qr: false' >> /root/persistence/start9/stats.yaml
echo '    masked: true' >> /root/persistence/start9/stats.yaml

# Setting up Config settings for Tor Address
export TOR_ADDRESS=$(yq e '.tor-address' /root/persistence/start9/config.yaml)
HOST_IP=$(ip -4 route list match 0/0 | awk '{print $3}')
echo "$HOST_IP   tor" >> /etc/hosts

# Setting up config settings for disabling metrics on cwtch 
if yq e -e ".disable-metrics" /root/persistence/start9/config.yaml > /dev/null; then
  DISABLE_METRICS=1
fi

configurator
trap _term SIGTERM
#Run cwtch (or whatever the user passed)
CWTCH_CONFIG_DIR=$CWTCH_CONFIG_DIR  exec "$@"
cd usr/local/bin
./cwtch
# cd app
# go build
# ./app

# sh

# echo -e "========================= End of Running Cwtch ========================\n"