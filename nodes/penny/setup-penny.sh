#!/bin/bash
set -e
DOMAIN="K38.com"
OBLADI_IP="192.230.1.4"
DESMOND_IP="192.230.1.5"
# cek apache
if ! command -v apache2 >/dev/null 2>&1; then
    apt update
    apt install -y apache2
fi
# enable modules
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers
# folder tambahan untuk soal 12 (auth) & 15 (/eternal) nanti
mkdir -p /etc/apache2/snippets
# buat config
cat > /etc/apache2/sites-available/www.conf <<EOF
<VirtualHost *:80>
    ServerName www.${DOMAIN}
    ProxyRequests Off
    ProxyPreserveHost On
    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"
    # tambahan soal 12 & 15 masuk lewat sini (harus SEBELUM ProxyPass /)
    IncludeOptional /etc/apache2/snippets/www-*.conf
    <Proxy "balancer://staticcluster">
        BalancerMember http://${OBLADI_IP}
        BalancerMember http://${DESMOND_IP}
        ProxySet lbmethod=byrequests
    </Proxy>
    ProxyPass / balancer://staticcluster/
    ProxyPassReverse / balancer://staticcluster/
</VirtualHost>
EOF
# enable site
a2ensite www.conf
# test config
apache2ctl configtest
# restart
service apache2 restart
echo "Tes dari alpha: curl -I http://www.${DOMAIN}"
