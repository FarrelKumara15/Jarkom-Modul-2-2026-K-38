#!/bin/bash

G=K38
F=/etc/bind/jarkom/$G.com

add_rr() {  # nama tipe nilai (tidak menambah dua kali)
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

add_rr rootkit A 192.230.1.1
add_rr alpha   A 192.230.6.2
add_rr beta    A 192.230.6.3
add_rr gamma   A 192.230.6.4
add_rr delta   A 192.230.7.2
add_rr epsilon A 192.230.7.3
add_rr abbey   A 192.230.4.2
add_rr penny   A 192.230.5.2
add_rr obladi  A 192.230.1.4
add_rr desmond A 192.230.1.5
add_rr oblada  A 192.230.1.6
add_rr molly   A 192.230.1.7

bump_serial $F
named-checkzone $G.com $F && restart_named
sleep 2
for h in rootkit alpha beta gamma delta epsilon abbey penny obladi desmond oblada molly; do
  echo -n "$h.$G.com -> "; dig @127.0.0.1 $h.$G.com +short
done