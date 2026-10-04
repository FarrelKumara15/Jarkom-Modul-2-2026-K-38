#!/bin/bash

set -e

AUTH_USER="prabs"
AUTH_PASS='pakar_pinter_jadi_gob***'

export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq apache2-utils
mkdir -p /etc/apache2/snippets

# buat file password (user + password HARUS dua argumen terpisah)
htpasswd -bc /etc/apache2/.htpasswd "$AUTH_USER" "$AUTH_PASS"
chgrp www-data /etc/apache2/.htpasswd
chmod 640 /etc/apache2/.htpasswd

cat > /etc/apache2/snippets/www-auth.conf <<'CONF'
<Location "/admin">
    AuthType Basic
    AuthName "Ruang Rahasia Sindikat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Location>
CONF

apache2ctl configtest
service apache2 restart

echo "tanpa kredensial : $(curl -s -o /dev/null -w '%{http_code}' http://www.K38.com/admin/)   (harus 401)"
echo "password salah   : $(curl -s -o /dev/null -w '%{http_code}' -u "$AUTH_USER:salah" http://www.K38.com/admin/)   (harus 401)"
echo "password benar   : $(curl -s -o /dev/null -w '%{http_code}' -u "$AUTH_USER:$AUTH_PASS" http://www.K38.com/admin/)   (harus 200, kalau admin-page.sh sudah jalan di obladi & desmond)"