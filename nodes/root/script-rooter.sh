#!/bin/sh

H=$1
case "$H" in
  rootkit)
    for x in "eth0 192.230.1.1" "eth1 192.230.4.1" "eth2 192.230.5.1" "eth3 192.230.6.1" "eth4 192.230.7.1"; do
      set -- $x
      ip addr flush dev $1
      ip addr add $2/24 dev $1
      ip link set $1 up
    done
    ip addr | grep -E "^[0-9]+:|inet "
    exit 0 ;;
  alpha)   IP=192.230.6.2; GW=192.230.6.1 ;;
  beta)    IP=192.230.6.3; GW=192.230.6.1 ;;
  gamma)   IP=192.230.6.4; GW=192.230.6.1 ;;
  delta)   IP=192.230.7.2; GW=192.230.7.1 ;;
  epsilon) IP=192.230.7.3; GW=192.230.7.1 ;;
  abbey)   IP=192.230.4.2; GW=192.230.4.1 ;;
  penny)   IP=192.230.5.2; GW=192.230.5.1 ;;
  prab)    IP=192.230.1.2; GW=192.230.1.1 ;;
  tedd)    IP=192.230.1.3; GW=192.230.1.1 ;;
  obladi)  IP=192.230.1.4; GW=192.230.1.1 ;;
  desmond) IP=192.230.1.5; GW=192.230.1.1 ;;
  oblada)  IP=192.230.1.6; GW=192.230.1.1 ;;
  molly)   IP=192.230.1.7; GW=192.230.1.1 ;;
  *) echo "pakai: sh /root/s1-ip.sh <namanode>"; exit 1 ;;
esac
ip addr flush dev eth0
ip addr add $IP/24 dev eth0
ip link set eth0 up
ip route del default 2>/dev/null
ip route add default via $GW
ip addr show eth0 | grep inet
ip route
ping -c 2 $GW