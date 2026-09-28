#!/bin/sh

G=K38
for S in 192.230.1.2 192.230.1.3; do
  echo "== server $S =="
  dig @$S $G.com A +short
  dig @$S prab.$G.com +short
  dig @$S tedd.$G.com +short
  dig @$S $G.com SOA | grep -o "flags: [a-z ]*;"
done
ping -c1 $G.com
