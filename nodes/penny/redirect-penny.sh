#!/bin/bash
set -e


DOMAIN="K38.com"

# nama diawali 00- agar dimuat SEBELUM www.conf -> jadi default vhost
cat > /etc/apache2/sites-available/00-redirect.conf <<EOF
<VirtualHost *:80>
    ServerName penny.${DOMAIN}
    ServerAlias ${DOMAIN}
    Redirect permanent / http://www.${DOMAIN}/
</VirtualHost>
EOF

a2dissite 000-default >/dev/null 2>&1 || true
a2ensite 00-redirect.conf
apache2ctl configtest
service apache2 restart
echo "Tes: curl -I http://penny.${DOMAIN}  dan  curl -I http://192.230.5.2  (301 -> www)"
