#!/bin/bash

WAN=eth5
ip addr flush dev $WAN
ip addr add 192.168.122.200/24 dev $WAN
ip link set $WAN up
ip route del default 2>/dev/null
ip route add default via 192.168.122.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1 || echo 1 > /proc/sys/net/ipv4/ip_forward

if ! command -v iptables >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update && apt-get install -y iptables
fi

iptables -t nat -C POSTROUTING -s 192.230.0.0/16 -o $WAN -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -s 192.230.0.0/16 -o $WAN -j MASQUERADE
for i in eth0 eth1 eth2 eth3 eth4; do
  iptables -C FORWARD -i $i -o $WAN -j ACCEPT 2>/dev/null || iptables -A FORWARD -i $i -o $WAN -j ACCEPT
done
iptables -C FORWARD -i $WAN -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
  iptables -A FORWARD -i $WAN -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "== cek =="
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -L POSTROUTING -n
ping -c 2 8.8.8.8