#!/bin/bash

WAN=eth5

ip link set "$WAN" up 2>/dev/null
ip addr flush dev "$WAN" scope global 2>/dev/null
ip addr add 192.168.122.200/24 dev "$WAN"
ip route del default 2>/dev/null
ip route add default via 192.168.122.1 dev "$WAN"
echo "nameserver 192.168.122.1" > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward

if ! command -v iptables >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -o Acquire::Check-Valid-Until=false update
  apt-get install -y iptables
fi

iptables -t nat -C POSTROUTING -s 192.230.0.0/16 -o "$WAN" -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -s 192.230.0.0/16 -o "$WAN" -j MASQUERADE

for i in eth0 eth1 eth2 eth3 eth4; do
  iptables -C FORWARD -i "$i" -o "$WAN" -j ACCEPT 2>/dev/null || iptables -A FORWARD -i "$i" -o "$WAN" -j ACCEPT
done
iptables -C FORWARD -i "$WAN" -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
  iptables -A FORWARD -i "$WAN" -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "== verifikasi =="
if ip -4 addr show dev "$WAN" | grep -q "192.168.122.200/24"; then
  echo "OK   $WAN -> 192.168.122.200"
else
  echo "GAGAL $WAN tidak punya IP yang benar"
fi
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -L POSTROUTING -n
ping -c2 8.8.8.8
