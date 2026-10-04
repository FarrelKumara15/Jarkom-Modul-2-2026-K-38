#!/bin/bash

G=K38
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -o Acquire::Check-Valid-Until=false update
  apt-get install -y bind9 bind9utils dnsutils
  [ -e /etc/init.d/bind9 ] || ln -s /etc/init.d/named /etc/init.d/bind9
else
  apk update && apk add bind bind-tools
fi

if ! command -v named >/dev/null 2>&1; then
  echo "GAGAL: paket bind9 tidak terpasang. Cek 'date' (jam sistem) lalu jalankan ulang skrip ini."
  exit 1
fi

mkdir -p /etc/bind/jarkom /var/cache/bind

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
    type master;
    notify yes;
    also-notify { 192.230.1.3; };
    allow-transfer { 192.230.1.3; };
    file "/etc/bind/jarkom/@G@.com";
};
CONF

cat > /etc/bind/jarkom/$G.com <<'CONF'
$TTL    604800
@       IN      SOA     prab.@G@.com. root.@G@.com. (
                        2026092801 ; Serial (YYYYMMDDXX)
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.@G@.com.
@       IN      NS      tedd.@G@.com.
@       IN      A       192.230.5.2
prab    IN      A       192.230.1.2
tedd    IN      A       192.230.1.3
CONF

sed -i "s/@G@/$G/g" /etc/bind/named.conf.local /etc/bind/jarkom/$G.com
chown -R bind:bind /etc/bind/jarkom 2>/dev/null || true
named-checkconf && named-checkzone $G.com /etc/bind/jarkom/$G.com
restart_named
sleep 2
dig @127.0.0.1 $G.com SOA +short
dig @127.0.0.1 $G.com A +short
