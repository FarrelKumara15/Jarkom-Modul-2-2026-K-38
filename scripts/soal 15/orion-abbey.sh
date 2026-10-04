#!/bin/bash

set -e

mkdir -p /var/www/orion /etc/nginx/k38-snippets
echo "<h1>ORION</h1><p>Halaman statis dari $(hostname)</p>" > /var/www/orion/index.html
# bukti tidak ada rendering php: file ini akan tampil/terunduh apa adanya
echo '<?php echo "PHP DIEKSEKUSI"; ?>' > /var/www/orion/test.php
chmod -R a+rX /var/www/orion

cat > /etc/nginx/k38-snippets/static-orion.conf <<'CONF'
# /orion dilayani lokal oleh abbey, tidak diteruskan ke core
location = /orion { return 301 /orion/; }
location /orion/ {
    alias /var/www/orion/;
    index index.html;
}
CONF

nginx -t
service nginx restart

echo "tes"
curl -i http://static.K38.com/orion/
echo "test.php harus tampil mentah (bukan 'PHP DIEKSEKUSI')"
curl -s http://static.K38.com/orion/test.php