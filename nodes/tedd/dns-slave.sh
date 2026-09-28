#!/bin/bash

G=K38
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update && apt-get install -y bind9 bind9utils dnsutils
  [ -e /etc/init.d/bind9 ] || ln -s /etc/init.d/named /etc/init.d/bind9
else
  apk update && apk add bind bind-tools
fi
mkdir -p /etc/bind/jarkom /var/cache/bind
chown -R bind:bind /etc/bind/jarkom 2>/dev/null || true

restart_named() {
  if [ -x /etc/init.d/bind9 ]; then service bind9 restart
  else killall named 2>/dev/null; sleep 1; named; fi
}

cat > /etc/bind/named.conf.options <<'CONF'
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation no;
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
CONF

cat > /etc/bind/named.conf.local <<'CONF'
zone "@G@.com" {
    type slave;
    masters { 192.230.1.2; };
    file "/etc/bind/jarkom/@G@.com";
};
CONF

sed -i "s/@G@/$G/g" /etc/bind/named.conf.local
named-checkconf
restart_named
sleep 3
dig @127.0.0.1 $G.com SOA | grep -E "flags:|SOA"