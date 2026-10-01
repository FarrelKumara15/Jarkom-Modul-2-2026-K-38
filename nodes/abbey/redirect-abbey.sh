#!/bin/bash
set -e


DOMAIN="K38.com"
OLADA_IP="192.230.1.6"
MOLLY_IP="192.230.1.7"

for v in OLADA_IP MOLLY_IP; do
  if [ "${!v}" = "CHANGE_ME" ]; then echo "Isi $v dulu."; exit 1; fi
done

# cek nginx
if ! command -v nginx >/dev/null 2>&1; then
    apt update
    apt install -y nginx
fi

# site default bawaan dibuang (bentrok dengan default_server di soal 13)
rm -f /etc/nginx/sites-enabled/default

# folder tambahan untuk soal 15 (/orion)
mkdir -p /etc/nginx/k38-snippets

cat > /etc/nginx/conf.d/static.conf <<EOF
upstream corecluster {
    server ${OLADA_IP};
    server ${MOLLY_IP};
}

server {
    listen 80;
    server_name static.${DOMAIN};

    # tambahan soal 15 (/orion) masuk lewat sini
    include /etc/nginx/k38-snippets/static-*.conf;

    location / {
        proxy_pass http://corecluster;
        proxy_http_version 1.1;
        proxy_set_header Host            \$host;
        proxy_set_header X-Real-IP       \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

nginx -t
service nginx restart
echo "Tes dari alpha: curl -I http://static.${DOMAIN}"