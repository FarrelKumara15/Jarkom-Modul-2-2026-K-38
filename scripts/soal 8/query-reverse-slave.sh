#!/bin/bash

L=/etc/bind/named.conf.local

restart_named() {
  if [ -x /etc/init.d/bind9 ]; then service bind9 restart
  else killall named 2>/dev/null; sleep 1; named; fi
}

for R in 1 4 5; do
  Z=$R.230.192.in-addr.arpa
  grep -q "zone \"$Z\"" $L || cat >> $L <<EOF
zone "$Z" {
    type slave;
    masters { 192.230.1.2; };
    file "/etc/bind/jarkom/$Z";
};
EOF
done

named-checkconf
restart_named
sleep 3
dig @127.0.0.1 -x 192.230.4.2 +short
