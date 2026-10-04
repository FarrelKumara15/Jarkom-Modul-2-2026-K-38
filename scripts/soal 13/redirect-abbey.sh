#!/bin/bash

set -e

DOMAIN="K38.com"

cat > /etc/nginx/conf.d/00-redirect.conf <<CONF
server {
    listen 80 default_server;
    server_name abbey.${DOMAIN};
    return 302 http://static.${DOMAIN}\$request_uri;
}
CONF

rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

echo "== tes dari abbey =="
echo "abbey.${DOMAIN} : $(curl -s -o /dev/null -w '%{http_code} -> %{redirect_url}' http://abbey.${DOMAIN}/)"
echo "192.230.4.2     : $(curl -s -o /dev/null -w '%{http_code} -> %{redirect_url}' http://192.230.4.2/)"
echo "(harus 302 -> http://static.${DOMAIN}/)"