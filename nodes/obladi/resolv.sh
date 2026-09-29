#!/bin/sh

cat > /etc/resolv.conf <<EOF
nameserver 192.230.1.2
nameserver 192.230.1.3
nameserver 192.168.122.1
EOF
cat /etc/resolv.conf
