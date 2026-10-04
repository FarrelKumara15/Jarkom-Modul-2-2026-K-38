#!/bin/bash
# Soal 18 - A record abbey -> IP fiktif, serial dinaikkan, TTL 15 detik
#
#   bash ttl-abbey.sh demo      (default) jalankan 3 fase otomatis dengan cache resolver
#   bash ttl-abbey.sh fiktif    ubah saja abbey ke IP fiktif (TTL 15) + naikkan serial
#   bash ttl-abbey.sh restore   kembalikan abbey ke 192.230.4.2 dengan TTL normal (untuk soal 20)
#
# Kenapa pakai cache resolver? prab/tedd itu authoritative: mereka selalu menjawab data
# terbaru, tidak pernah "ketahan cache". Fase 2 (masih IP lama karena cache) baru bisa
# diperlihatkan kalau ada resolver cache di tengah. Di sini dipakai dnsmasq di 127.0.0.1:5353
# yang meneruskan ke named lokal.
G=K38
F=/etc/bind/jarkom/$G.com
OLD_IP=192.230.4.2
PRAB=192.230.1.2
TEDD=192.230.1.3
MODE=${1:-demo}

bump_serial() {
  local old new
  old=$(grep -m1 ';[[:space:]]*Serial' "$1" | awk '{print $1}')
  new=$((old+1))
  sed -i "s/^\([[:space:]]*\)$old\([[:space:]]*;[[:space:]]*Serial\)/\1$new\2/" "$1"
}
restart_named() {
  if [ -x /etc/init.d/bind9 ]; then service bind9 restart
  else killall named 2>/dev/null; sleep 1; named; fi
}
reload_named() {
  rndc reload >/dev/null 2>&1 || restart_named
}
set_abbey() {  # $1 = ttl ("" = default zona) , $2 = ip
  sed -i -E '/^abbey[[:space:]].*[[:space:]]A[[:space:]]/d' $F
  if [ -n "$1" ]; then
    printf "%-8s %s IN      A     %s\n" abbey "$1" "$2" >> $F
  else
    printf "%-8s IN      A     %s\n" abbey "$2" >> $F
  fi
  bump_serial $F
  named-checkzone $G.com $F >/dev/null || { echo "ZONA ERROR, dibatalkan"; exit 1; }
  reload_named
  sleep 1
}
serials() {
  echo "serial prab: $(dig @$PRAB $G.com SOA +short | awk '{print $3}')   serial tedd: $(dig @$TEDD $G.com SOA +short | awk '{print $3}')"
}
q_cache() { dig @127.0.0.1 -p 5353 abbey.$G.com +noall +answer +time=3 +tries=1; }
stop_cache() { pkill -f 'dnsmasq.*--port=5353' 2>/dev/null; }

case "$MODE" in
  demo)
    command -v dnsmasq >/dev/null 2>&1 || { export DEBIAN_FRONTEND=noninteractive; apt-get install -y dnsmasq-base; }
    stop_cache
    echo "[persiapan] abbey = $OLD_IP dengan TTL 15"
    set_abbey 15 $OLD_IP
    sleep 3
    dnsmasq --port=5353 --listen-address=127.0.0.1 --bind-interfaces --no-resolv --no-hosts \
            --server=127.0.0.1#53 --cache-size=1000 --pid-file=/run/dnsmasq-k38.pid
    sleep 1

    echo; echo "=== FASE 1: sebelum perubahan (harus IP lama $OLD_IP) ==="
    q_cache

    NEW_IP="203.0.113.$((RANDOM % 253 + 1))"
    echo; echo ">>> ubah abbey -> $NEW_IP, naikkan serial, TTL 15 ..."
    set_abbey 15 $NEW_IP

    echo; echo "=== FASE 2: baru berubah, masih dalam 15 detik (harus MASIH IP lama, TTL menurun = dari cache) ==="
    q_cache

    echo; echo "(tunggu 16 detik sampai TTL habis ...)"
    sleep 16
    echo "=== FASE 3: TTL habis (harus IP fiktif baru $NEW_IP) ==="
    q_cache

    echo; echo "=== sinkron ke tedd ==="
    serials
    echo "tedd menjawab abbey -> $(dig @$TEDD abbey.$G.com +short)"
    echo; echo "Jangan lupa: bash ttl-abbey.sh restore  (sebelum tes soal 20)"
    ;;
  fiktif)
    NEW_IP="203.0.113.$((RANDOM % 253 + 1))"
    set_abbey 15 $NEW_IP
    sleep 2
    echo "abbey -> $NEW_IP (TTL 15)"; serials
    ;;
  restore)
    stop_cache
    set_abbey "" $OLD_IP
    sleep 2
    echo "abbey kembali -> $(dig @127.0.0.1 abbey.$G.com +short)"; serials
    ;;
  *) echo "pakai: bash ttl-abbey.sh [demo|fiktif|restore]"; exit 1 ;;
esac