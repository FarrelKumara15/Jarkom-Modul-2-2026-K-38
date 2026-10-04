#!/bin/bash
# Soal 14 - backend core (Nginx): log mencatat IP asli client (dari header X-Real-IP milik abbey)
# Jalankan di oblada DAN molly.
set -e

PROXY_IP="192.230.4.2"   # abbey

cat > /etc/nginx/conf.d/realip.conf <<CONF
set_real_ip_from ${PROXY_IP};
real_ip_header   X-Real-IP;
CONF

nginx -t
service nginx restart

echo "Selesai. Dari alpha: curl -s http://static.K38.com/ > /dev/null"
echo "Lalu cek di node ini : tail -n 5 /var/log/nginx/access.log   (harus muncul IP alpha 192.230.6.2, bukan 192.230.4.2)"
