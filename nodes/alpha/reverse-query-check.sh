#!/bin/sh

for S in 192.230.1.2 192.230.1.3; do
  echo "== server $S =="
  for ip in 192.230.4.2 192.230.5.2 192.230.1.4 192.230.1.5 192.230.1.6 192.230.1.7; do
    N=$(dig @$S -x $ip +short | tr '\n' ' ')
    F=$(dig @$S -x $ip | grep -o "flags: [a-z ]*;")
    echo "$ip -> $N [$F]"
  done
done
