#!/bin/sh

_term() {
  echo "caught SIGTERM signal!"
  kill -TERM "$cwtch_child" 2>/dev/null
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
# cat /etc/tor/torrc
echo -e "========================================================\n"
tor -f /etc/tor/torrc
#Cwtch will crash and burn if 9051 isn't ready
sleep 15
if [ -z "${CWTCH_CONFIG_DIR}" ]; then
	CWTCH_CONFIG_DIR=/etc/cwtch/
fi

# Setting up config settings for disabling metrics on cwtch 
# if yq e -e ".disable-metrics" /var/lib/cwtch/start9/config.yaml > /dev/null; 
# then
#   echo -e "Disabling Server Metrics..."
#   DISABLE_METRICS=1
# else
#   DISABLE_METRICS . /dev/null
# fi

#Run cwtch (or whatever the user passed)
echo -e "Starting Cwtch Server..."
cd usr/local/bin
./cwtch -exportServerBundle & cwtch_child=$!
cd /


render_properties() {
    while true; do
      sleep 5
      export SERVER_BUNDLE=$( cat var/lib/cwtch/serverbundle || true )
      if [ -z "$SERVER_BUNDLE" ];
      then
          sleep 5
      else
      # Properties 
        echo 'version: 2' > /var/lib/cwtch/start9/stats.yaml
        echo 'data:' >> /var/lib/cwtch/start9/stats.yaml
        echo '  Server Bundle:' >> /var/lib/cwtch/start9/stats.yaml
        echo '    type: string' >> /var/lib/cwtch/start9/stats.yaml
        echo '    value: "'"$SERVER_BUNDLE"'"' >> /var/lib/cwtch/start9/stats.yaml
        echo '    description: This is the part you need to capture and import into a Cwtch client app so you can use the server for hosting groups' >> /var/lib/cwtch/start9/stats.yaml
        echo '    copyable: true' >> /var/lib/cwtch/start9/stats.yaml
        echo '    masked: false' >> /var/lib/cwtch/start9/stats.yaml
        echo '    qr: true' >> /var/lib/cwtch/start9/stats.yaml
      fi
    done
}

trap _term SIGTERM

render_properties &
wait -n $cwtch_child 