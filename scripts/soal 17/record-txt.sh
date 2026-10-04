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
reload_named() {
  rndc reload >/dev/null 2>&1 || restart_named
}

for h in alpha beta gamma delta epsilon; do
  add_rr $h TXT "\"$h\""
done

bump_serial $F
named-checkzone $G.com $F || exit 1
reload_named
sleep 3

echo "== verifikasi TXT (prab 192.230.1.2 | tedd 192.230.1.3) =="
for h in alpha beta gamma delta epsilon; do
  echo "$h.$G.com  prab: $(dig @192.230.1.2 $h.$G.com TXT +short)   tedd: $(dig @192.230.1.3 $h.$G.com TXT +short)"
done
echo "serial prab: $(dig @192.230.1.2 $G.com SOA +short | awk '{print $3}')  tedd: $(dig @192.230.1.3 $G.com SOA +short | awk '{print $3}')"