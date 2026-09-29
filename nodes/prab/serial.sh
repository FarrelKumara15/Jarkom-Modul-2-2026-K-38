#!/bin/bash

G=K38
A=$(dig @192.230.1.2 $G.com SOA +short | awk '{print $3}')
B=$(dig @192.230.1.3 $G.com SOA +short | awk '{print $3}')
echo "serial prab = $A"
echo "serial tedd = $B"
if [ -n "$A" ] && [ "$A" = "$B" ]; then
  echo ">> SAMA (zone transfer OK)"
else
  echo ">> BEDA. Di tedd jalankan: rndc retransfer $G.com   (atau restart bind9/named), lalu ulangi skrip ini"
fi
