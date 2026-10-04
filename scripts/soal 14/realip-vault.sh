#!/bin/bash

set -e

PROXY_IP="192.230.5.2"   # penny

a2enmod remoteip

cat > /etc/apache2/conf-available/k38-remoteip.conf <<CONF
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy ${PROXY_IP}
CONF
a2enconf k38-remoteip

apache2ctl configtest
service apache2 restart

echo "Selesai. Dari alpha: curl -s http://www.K38.com/ > /dev/null"
echo "Lalu cek di node ini : tail -n 5 /var/log/apache2/access.log   (IP alpha 192.230.6.2)"