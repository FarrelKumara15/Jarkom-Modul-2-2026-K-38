#!/bin/bash

set -e

DOMAIN="K38.com"
OBLADI_IP="192.230.1.4"
DESMOND_IP="192.230.1.5"

# install apache kalau belum ada
if ! command -v apache2 >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y apache2
fi

# hilangkan warning "Could not reliably determine the server's FQDN"
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
a2enconf servername >/dev/null

# aktifkan modul proxy
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

# folder tambahan untuk soal 12 (auth) & 15 (/eternal)
mkdir -p /etc/apache2/snippets

# onfig vhost www
cat > /etc/apache2/sites-available/www.conf <<CONF
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
CONF

# site bawaan dimatikan supaya tidak jadi default vhost
a2dissite 000-default >/dev/null 2>&1 || true
a2ensite www.conf

apache2ctl configtest
service apache2 restart
echo "Tes dari alpha: curl -I http://www.${DOMAIN}"