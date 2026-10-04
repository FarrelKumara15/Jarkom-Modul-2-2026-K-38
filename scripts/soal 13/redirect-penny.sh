#!/bin/bash

set -e

DOMAIN="K38.com"

cat > /etc/apache2/sites-available/00-redirect.conf <<CONF
<VirtualHost *:80>
    ServerName penny.${DOMAIN}
    ServerAlias ${DOMAIN}
    Redirect permanent / http://www.${DOMAIN}/
</VirtualHost>
CONF

a2dissite 000-default >/dev/null 2>&1 || true
a2ensite 00-redirect.conf
apache2ctl configtest
service apache2 restart

echo "== tes dari penny =="
echo "penny.${DOMAIN} : $(curl -s -o /dev/null -w '%{http_code} -> %{redirect_url}' http://penny.${DOMAIN}/)"
echo "192.230.5.2     : $(curl -s -o /dev/null -w '%{http_code} -> %{redirect_url}' http://192.230.5.2/)"
echo "(harus 301 -> http://www.${DOMAIN}/)"