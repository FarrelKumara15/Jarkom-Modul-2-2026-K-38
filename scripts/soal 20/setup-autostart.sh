#!/bin/sh
# Soal 20 - bikin node otomatis "pulih" setelah di-restart.
# Pemakaian (di tiap node, sekali saja):   sh setup-autostart.sh <nama node>
#   contoh: sh setup-autostart.sh penny
#
# Yang dilakukan:
#  1. menulis /root/autostart.sh  (IP+gateway, hostname, resolv.conf, lalu start service sesuai peran node)
#  2. memasang pemanggilnya di /root/.bashrc dan /root/.profile (jalan tiap console node dibuka)
#  3. mencoba mendaftarkan service ke init (update-rc.d / systemctl) kalau tersedia
# autostart.sh aman dijalankan berulang kali (idempotent).
G=K38
H=$1
SVCS=""
case "$H" in
  rootkit) ROLE=router; IP=192.230.1.1; GW="" ;;
  alpha)   ROLE=client; IP=192.230.6.2; GW=192.230.6.1 ;;
  beta)    ROLE=client; IP=192.230.6.3; GW=192.230.6.1 ;;
  gamma)   ROLE=client; IP=192.230.6.4; GW=192.230.6.1 ;;
  delta)   ROLE=client; IP=192.230.7.2; GW=192.230.7.1 ;;
  epsilon) ROLE=client; IP=192.230.7.3; GW=192.230.7.1 ;;
  abbey)   ROLE=client; IP=192.230.4.2; GW=192.230.4.1; SVCS="nginx" ;;
  penny)   ROLE=client; IP=192.230.5.2; GW=192.230.5.1; SVCS="apache2" ;;
  prab)    ROLE=client; IP=192.230.1.2; GW=192.230.1.1; SVCS="named bind9" ;;
  tedd)    ROLE=client; IP=192.230.1.3; GW=192.230.1.1; SVCS="named bind9" ;;
  obladi)  ROLE=client; IP=192.230.1.4; GW=192.230.1.1; SVCS="apache2" ;;
  desmond) ROLE=client; IP=192.230.1.5; GW=192.230.1.1; SVCS="apache2" ;;
  oblada)  ROLE=client; IP=192.230.1.6; GW=192.230.1.1; SVCS="nginx" ;;
  molly)   ROLE=client; IP=192.230.1.7; GW=192.230.1.1; SVCS="nginx" ;;
  *) echo "pakai: sh setup-autostart.sh <rootkit|alpha|beta|gamma|delta|epsilon|abbey|penny|prab|tedd|obladi|desmond|oblada|molly>"; exit 1 ;;
esac

cat > /root/autostart.sh <<'AUTO'
#!/bin/sh
# DIBUAT OTOMATIS oleh setup-autostart.sh - aman dijalankan berulang kali
G=K38; H=@H@; IP=@IP@; GW=@GW@; ROLE=@ROLE@
log() { echo "[autostart $H] $*"; }

# proses jalan? (tidak butuh pgrep/ps, baca /proc langsung)
running() {
  for p in /proc/[0-9]*/comm; do
    [ "$(cat "$p" 2>/dev/null)" = "$1" ] && return 0
  done
  return 1
}
# start service kalau belum jalan: up <nama-proses> <nama-service>
up() {
  if running "$1"; then log "$2 sudah jalan"; return; fi
  service "$2" start >/dev/null 2>&1 || /etc/init.d/"$2" start >/dev/null 2>&1
  sleep 2
  if running "$1"; then log "$2 start OK"; else log "$2 GAGAL start"; fi
}
up_named() {
  if running named; then log "named sudah jalan"; return; fi
  mkdir -p /run/named /var/cache/bind
  chown bind:bind /run/named /var/cache/bind 2>/dev/null
  service named start >/dev/null 2>&1 || service bind9 start >/dev/null 2>&1 || named -u bind
  sleep 2
  if running named; then log "named start OK"; else log "named GAGAL start"; fi
}
setip() {  # dev ip/24
  ip link set "$1" up 2>/dev/null
  ip -4 addr show dev "$1" | grep -q "inet $2/24" || ip addr add "$2/24" dev "$1"
}

# ---- 1. IP, gateway, (router: NAT + forwarding) ----
if [ "$ROLE" = router ]; then
  setip eth0 192.230.1.1; setip eth1 192.230.4.1; setip eth2 192.230.5.1
  setip eth3 192.230.6.1; setip eth4 192.230.7.1
  ip link set eth5 up 2>/dev/null
  ip -4 addr show dev eth5 | grep -q "inet 192.168.122.200/24" || ip addr add 192.168.122.200/24 dev eth5
  ip route | grep -q '^default' || ip route add default via 192.168.122.1 dev eth5
  sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward
  if command -v iptables >/dev/null 2>&1; then
    iptables -t nat -C POSTROUTING -s 192.230.0.0/16 -o eth5 -j MASQUERADE 2>/dev/null || \
      iptables -t nat -A POSTROUTING -s 192.230.0.0/16 -o eth5 -j MASQUERADE
    for i in eth0 eth1 eth2 eth3 eth4; do
      iptables -C FORWARD -i $i -o eth5 -j ACCEPT 2>/dev/null || iptables -A FORWARD -i $i -o eth5 -j ACCEPT
    done
    iptables -C FORWARD -i eth5 -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
      iptables -A FORWARD -i eth5 -m state --state ESTABLISHED,RELATED -j ACCEPT
  else
    log "iptables belum terpasang di rootkit (jalankan router-script-rootkit.sh sekali)"
  fi
else
  setip eth0 "$IP"
  ip route | grep -q "^default via $GW" || { ip route del default 2>/dev/null; ip route add default via "$GW" dev eth0; }
fi

# ---- 2. hostname + /etc/hosts ----
hostname "$H"
echo "$H" > /etc/hostname
printf "127.0.0.1\tlocalhost\n$IP\t$H.$G.com $H\n" > /etc/hosts

# ---- 3. resolver ----
if [ "$ROLE" = router ]; then
  echo "nameserver 192.168.122.1" > /etc/resolv.conf
else
  printf "nameserver 192.230.1.2\nnameserver 192.230.1.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
fi

# ---- 4. service sesuai peran ----
V=$(ls /etc/php 2>/dev/null | sort -V | tail -n1)
case "$H" in
  prab|tedd) up_named ;;
  penny)     [ -n "$V" ] && up php-fpm$V php$V-fpm; up apache2 apache2 ;;
  obladi|desmond) up apache2 apache2 ;;
  abbey)     up nginx nginx ;;
  oblada|molly)   [ -n "$V" ] && up php-fpm$V php$V-fpm; up nginx nginx ;;
esac
log "selesai"
AUTO
sed -i "s|@H@|$H|; s|@IP@|$IP|; s|@GW@|$GW|; s|@ROLE@|$ROLE|" /root/autostart.sh
chmod +x /root/autostart.sh

# pemanggil otomatis tiap console dibuka (idempotent: tidak dobel)
for RC in /root/.bashrc /root/.profile; do
  touch "$RC"
  grep -q "k38-autostart" "$RC" || printf '\n# k38-autostart\n[ -f /root/autostart.sh ] && sh /root/autostart.sh > /root/autostart.log 2>&1\n' >> "$RC"
done

# daftar ke init kalau ada (di container GNS3 biasanya tidak ada init -> .bashrc di atas yang bekerja)
for S in $SVCS; do
  command -v update-rc.d >/dev/null 2>&1 && update-rc.d "$S" defaults >/dev/null 2>&1
  command -v systemctl   >/dev/null 2>&1 && systemctl enable "$S" >/dev/null 2>&1
done
case "$H" in penny|oblada|molly)
  V=$(ls /etc/php 2>/dev/null | sort -V | tail -n1)
  [ -n "$V" ] && command -v update-rc.d >/dev/null 2>&1 && update-rc.d php$V-fpm defaults >/dev/null 2>&1 ;;
esac

echo "== jalankan sekali sekarang =="
sh /root/autostart.sh
