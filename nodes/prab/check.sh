#!/bin/sh

for ip in 192.230.1.1 192.230.4.1 192.230.5.1 192.230.6.1 192.230.7.1 \
          192.230.1.2 192.230.1.4 192.230.4.2 192.230.5.2 192.230.6.2 192.230.7>
  if ping -c1 -W2 $ip >/dev/null 2>&1; then echo "OK    $ip"; else echo "GAGAL >
done
if ping -c1 -W3 google.com >/dev/null 2>&1; then echo "OK    google.com"; else >