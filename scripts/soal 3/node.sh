#!/bin/sh

echo "nameserver 192.168.122.1" > /etc/resolv.conf
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y dnsutils lynx curl iputils-ping
else
  apk update
  apk add bind-tools lynx curl
fi
ping -c 2 8.8.8.8
