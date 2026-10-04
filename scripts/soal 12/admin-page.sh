#!/bin/bash

H=$(hostname)

for D in /var/www/vault.K38.com /var/www/html; do
    mkdir -p $D/admin
    echo "ADMIN $H" > $D/admin/index.html
done
chmod -R a+rX /var/www

echo "== isi file =="
cat /var/www/vault.K38.com/admin/index.html
cat /var/www/html/admin/index.html
echo "== tes lokal =="
curl -i -H "Host: vault.K38.com" http://127.0.0.1/admin/