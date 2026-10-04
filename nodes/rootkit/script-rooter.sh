#!/bin/sh

H=$1

set_rootkit() {
  for pair in "eth0:192.230.1.1" "eth1:192.230.4.1" "eth2:192.230.5.1" "eth3:192.230.6.1" "eth4:192.230.7.1"; do
    dev=${pair%%:*}
    ip=${pair##*:}
    ip link set "$dev" up 2>/dev/null
    ip addr flush dev "$dev" scope global 2>/dev/null
    ip addr add "$ip/24" dev "$dev"
  done

  echo "== verifikasi =="
  ok=1
  for pair in "eth0:192.230.1.1" "eth1:192.230.4.1" "eth2:192.230.5.1" "eth3:192.230.6.1" "eth4:192.230.7.1"; do
    dev=${pair%%:*}
    ip=${pair##*:}
    if ip -4 addr show dev "$dev" | grep -q "$ip/24"; then
      echo "OK   $dev -> $ip"
    else
      echo "GAGAL $dev -> seharusnya $ip, cek manual: ip addr show dev $dev"
      ok=0
    fi
  done
  if [ "$ok" -eq 0 ]; then
    echo "!! Ada interface yang gagal diisi. Jalankan ulang skrip ini sekali lagi."
    exit 1
  fi
  echo "Rootkit OK. Lanjutkan dengan: bash router-script-rootkit.sh"
}

case "$H" in
  rootkit) set_rootkit; exit 0 ;;
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
  *) echo "pakai: sh /root/script-rooter.sh <namanode>"; exit 1 ;;
esac

ip link set eth0 up 2>/dev/null
ip addr flush dev eth0 scope global 2>/dev/null
ip addr add "$IP/24" dev eth0
ip route del default 2>/dev/null
ip route add default via "$GW" dev eth0

echo "== verifikasi =="
if ip -4 addr show dev eth0 | grep -q "$IP/24"; then
  echo "OK   eth0 -> $IP"
else
  echo "GAGAL eth0 -> seharusnya $IP. Jalankan ulang skrip ini sekali lagi."
  exit 1
fi

ip addr show eth0 | grep inet
ip route

i=0
ok=0
while [ "$i" -lt 5 ]; do
  if ping -c1 -W2 "$GW" >/dev/null 2>&1; then ok=1; break; fi
  i=$((i+1))
  sleep 1
done
if [ "$ok" -eq 1 ]; then
  echo "Ping ke gateway $GW: BERHASIL"
else
  echo "Ping ke gateway $GW: GAGAL setelah 5x percobaan."
  echo "Cek: apakah rootkit sudah dikonfigurasi (script-rooter.sh rootkit) dan NAT sudah jalan (router-script-rootkit.sh)?"
fi
