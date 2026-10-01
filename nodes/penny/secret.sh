#!/bin/bash
set -e
AUTH_USER="prabs"
AUTH_PASS="pakar_pinter_jadi_gob***"
if [ "$AUTH_PASS" = "CHANGE_ME" ]; then echo "Isi AUTH_PASS dulu."; exit 1; fi
apt-get install -y -qq apache2-utils
mkdir -p /etc/apache2/snippets
htpasswd -bc /etc/apache2/.htpasswd "AUTHUSER""AUTH_PASS"
chgrp www-data /etc/apache2/.htpasswd
chmod 640 /etc/apache2/.htpasswd
cat > /etc/apache2/snippets/www-auth.conf <<'EOF'
<Location "/admin">
    AuthType Basic
    AuthName "Ruang Rahasia Sindikat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Location>
EOF
apache2ctl configtest
service apache2 restart
echo "Tes: curl -I http://www.K38.com/admin/  (401)  |  curl -u ${AUTH_USER}:PASSWORD http://www.K38.com/admin/ (200)"
