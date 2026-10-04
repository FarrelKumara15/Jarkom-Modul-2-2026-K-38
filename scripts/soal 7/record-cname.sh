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

add_rr vault  A     192.230.1.4
add_rr vault  A     192.230.1.5
add_rr core   A     192.230.1.6
add_rr core   A     192.230.1.7
add_rr www    CNAME penny.$G.com.
add_rr static CNAME abbey.$G.com.

bump_serial $F
named-checkzone $G.com $F && restart_named
sleep 2
for h in vault core www static; do
  echo "== $h.$G.com =="; dig @127.0.0.1 $h.$G.com +short
done
