#!/bin/sh

G=K38
H=$1
case "$H" in
  rootkit) IP=192.230.1.1 ;;
  alpha)   IP=192.230.6.2 ;;
  beta)    IP=192.230.6.3 ;;
  gamma)   IP=192.230.6.4 ;;
  delta)   IP=192.230.7.2 ;;
  epsilon) IP=192.230.7.3 ;;
  abbey)   IP=192.230.4.2 ;;
  penny)   IP=192.230.5.2 ;;
  prab)    IP=192.230.1.2 ;;
  tedd)    IP=192.230.1.3 ;;
  obladi)  IP=192.230.1.4 ;;
  desmond) IP=192.230.1.5 ;;
  oblada)  IP=192.230.1.6 ;;
  molly)   IP=192.230.1.7 ;;
  *) echo "pakai: sh /root/s5-host.sh alpha"; exit 1 ;;
esac
hostname $H
echo $H > /etc/hostname
printf "127.0.0.1\tlocalhost\n$IP\t$H.$G.com $H\n" > /etc/hosts
echo "hostname     : $(hostname)"
echo "hostname -f  : $(hostname -f 2>/dev/null)"
cat /etc/hosts
