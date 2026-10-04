#!/bin/bash

G=K38
F=/etc/bind/jarkom/$G.com

add_rr() {
  grep -qE "^$1[[:space:]]+IN[[:space:]]+$2[[:space:]]+$3\$" $F || \
    printf "%-8s IN      %-5s %s\n" "$1" "$2" "$3" >> $F
}
bump_serial() {
  local old new
  old=$(grep -m1 ';[[:space:]]*Serial' "$1" | awk '{print $1}')
  new=$((old+1))
  sed -i "s/^\([[:space:]]*\)$old\([[:space:]]*;[[:space:]]*Serial\)/\1$new\2/" "$1"
}
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

add_rr outbound CNAME http.badssl.com.
bump_serial $F
named-checkconf && named-checkzone $G.com $F || exit 1
restart_named
sleep 3

echo "== verifikasi di prab =="
dig @127.0.0.1 outbound.$G.com +noall +answer
echo "== curl =="
curl -s -m 10 http://outbound.$G.com | head -n 15
echo "serial prab: $(dig @192.230.1.2 $G.com SOA +short | awk '{print $3}')  tedd: $(dig @192.230.1.3 $G.com SOA +short | awk '{print $3}')"
echo "Jangan lupa jalankan allow-recursion.sh di tedd."