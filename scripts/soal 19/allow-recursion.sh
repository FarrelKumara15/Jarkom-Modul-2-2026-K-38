#!/bin/bash

restart_named() {
  if [ -x /etc/init.d/bind9 ]; then service bind9 restart
  else killall named 2>/dev/null; sleep 1; named; fi
}

cp -n /etc/bind/named.conf.options /etc/bind/named.conf.options.bak 2>/dev/null
cat > /etc/bind/named.conf.options <<'CONF'
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation no;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
CONF
named-checkconf || exit 1
restart_named
sleep 3
dig @127.0.0.1 outbound.K38.com +noall +answer