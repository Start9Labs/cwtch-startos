FROM --platform=linux/arm64/v8 arm64v8/alpine:latest as tor-build-stage

# Install prerequisites, grab tor, compile it and move to /usr/local

RUN wget -q https://dist.torproject.org/tor-0.4.6.6.tar.gz
RUN apk --no-cache add --update gnupg build-base libevent libevent-dev libressl libressl-dev xz-libs xz-dev zlib zlib-dev zstd zstd-dev 
RUN tar xf tor-0.4.6.6.tar.gz && cd tor-0.4.6.6 && ./configure && make install && ls -R /usr/local/

FROM --platform=linux/arm64/v8 arm64v8/golang:alpine as cwtch-build-stage
# Need additional packages for cgo etc
RUN apk --no-cache add --update gcc build-base
RUN ls -al
# Copy source files from the repo to /go/src
COPY cwtch/ src/
#Build Cwtch
RUN cd src/app && go build 

FROM --platform=linux/arm64/v8 arm64v8/alpine:latest
# install YQ for the config page
RUN wget https://github.com/mikefarah/yq/releases/download/v4.12.2/yq_linux_arm.tar.gz -O - |\
      tar xz && mv yq_linux_arm /usr/bin/yq
#Specify various env vars
ENV TOR_USER=_tor CWTCH_USER=_cwtch CWTCH_HOME=/var/lib/cwtch
# Installing dependencies of Tor
RUN apk --no-cache add --update libevent libressl xz-libs zlib zstd zstd-dev tini
# Copy Tor
COPY --from=tor-build-stage /usr/local/ /usr/local/
#Copy cwtch app
COPY --from=cwtch-build-stage /go/src/app/app /usr/local/bin/cwtch
# Create unprivileged users
RUN mkdir -p /run/tor && mkdir /var/lib/cwtch && addgroup -S $TOR_USER && adduser -G $TOR_USER -S $TOR_USER && adduser -S $CWTCH_USER
# Copy configuration files
COPY cwtch/docker/torrc /etc/tor/torrc
ADD ./configurator/target/aarch64-unknown-linux-musl/release/configurator /usr/local/bin/configurator
# set up entrypoint
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
# Persist data
VOLUME /etc/tor /var/lib/tor /var/lib/Cwtch

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker_entrypoint.sh"]
CMD ["/usr/local/bin/cwtch","--exportServerBundle"]

