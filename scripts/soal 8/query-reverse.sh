#!/bin/bash

G=K38
L=/etc/bind/named.conf.local

restart_named() {
  if [ -x /etc/init.d/bind9 ]; then service bind9 restart
  else killall named 2>/dev/null; sleep 1; named; fi
}

for R in 1 4 5; do
  Z=$R.230.192.in-addr.arpa
  grep -q "zone \"$Z\"" $L || cat >> $L <<EOF
zone "$Z" {
    type master;
    notify yes;
    also-notify { 192.230.1.3; };
    allow-transfer { 192.230.1.3; };
    file "/etc/bind/jarkom/$Z";
};
EOF
done

mkzone() {  # $1 = nama zona; isi PTR dibaca dari stdin
  local FILE=/etc/bind/jarkom/$1
  cat > $FILE <<'CONF'
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
CONF
  cat >> $FILE
  sed -i "s/@G@/$G/g" $FILE
}

mkzone 4.230.192.in-addr.arpa <<'CONF'
2       IN      PTR     abbey.@G@.com.
CONF
mkzone 5.230.192.in-addr.arpa <<'CONF'
2       IN      PTR     penny.@G@.com.
CONF
mkzone 1.230.192.in-addr.arpa <<'CONF'
4       IN      PTR     vault.@G@.com.
5       IN      PTR     vault.@G@.com.
6       IN      PTR     core.@G@.com.
7       IN      PTR     core.@G@.com.
CONF

chown -R bind:bind /etc/bind/jarkom 2>/dev/null || true
named-checkconf
for R in 1 4 5; do named-checkzone $R.230.192.in-addr.arpa /etc/bind/jarkom/$R.230.192.in-addr.arpa; done
restart_named
sleep 2
dig @127.0.0.1 -x 192.230.4.2 +short
