#!/bin/sh

H=$1
case "$H" in
  rootkit)
    echo "== Menyiapkan Router Rootkit =="
    
    NAT_IFACE=$(ip route | grep default | awk '{print $5}')
    
    if [ -z "$NAT_IFACE" ]; then
        echo "GAGAL: Tidak ada koneksi internet bawaan dari GNS3 terdeteksi."
        echo "SOLUSI: Pastikan kamu sudah klik Stop lalu Start node rootkit di GNS3!"
        exit 1
    fi
    
    echo "-> Internet otomatis ditemukan di interface: $NAT_IFACE"
    
    for i in 0 1 2 3 4 5; do
        if [ "eth$i" != "$NAT_IFACE" ]; then
            ip addr flush dev eth$i 2>/dev/null
        fi
    done
    
    SUBNETS="192.230.1.1 192.230.4.1 192.230.5.1 192.230.6.1 192.230.7.1"
    IDX=0
    for SUB in $SUBNETS; do
        while [ "eth$IDX" = "$NAT_IFACE" ]; do
            IDX=$((IDX+1))
        done
        
        ip addr add $SUB/24 dev eth$IDX
        ip link set eth$IDX up
        IDX=$((IDX+1))
    done
    
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o $NAT_IFACE -j MASQUERADE
    
    echo "== Status IP =="
    ip addr | grep -E "^[0-9]+:|inet "
    
    echo "== Test Internet =="
    ping -c 2 8.8.8.8
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
  *) echo "pakai: bash script-rootkit.sh <namanode>"; exit 1 ;;
esac

ip addr flush dev eth0
ip addr add $IP/24 dev eth0
ip link set eth0 up
ip route del default 2>/dev/null
ip route add default via $GW
ip addr show eth0 | grep inet
ip route
