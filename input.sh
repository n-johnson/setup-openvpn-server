#!/bin/bash

DOCKER_IMAGE='njohnson/openvpn'

_check() { 
  curl -k 'https://localhost:8080' -so /dev/null \
    && return 0 \
    || return 1
}

installDocker() {
  local deb_dir="/etc/apt/sources.list.d"
  local docker_deb="$deb_dir/docker.list"

  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && sudo mkdir -p "$deb_dir" \
    && touch "$docker_deb" \
    && echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> "$docker_deb" \
    && apt-get update \
    && apt-cache policy docker-engine \
    && apt-get install linux-image-extra-$(uname -r) -y \
    && apt-get install docker-engine -y \
    && return 0 \
    || { echo "WARNINGDOCKER INSTALL FAILED"; exit 1; }
}

_killContainers() { 
  docker ps -a | awk '{print $1}' | grep -v 'CONTAINER' | xargs -I {} docker rm -f {}; 
}

_runDockerVpn() {
  local container_id=$(docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp "$DOCKER_IMAGE")
    
  docker run -d -p 8080:8080 --name tmp-ssl --volumes-from "$container_id" "$DOCKER_IMAGE" serveconfig
}
_waitForSetupCompletion() {
  _check;
  while [ $? -eq 1 ]; do
    echo 'Waiting for connection...'
    sleep 2
    _check 
  done
}

startDockerVpn() {
  _killContainers \
    && _runDockerVpn \
    && _waitForSetupCompletion
}

echo "Starting docker-vpn setup!"
installDocker && startDockerVpn
echo "docker-vpn setup complete!"