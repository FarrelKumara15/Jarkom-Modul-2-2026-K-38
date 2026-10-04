#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
apt-get install -y php8.4-fpm || apt-get install -y php-fpm
V=$(ls /etc/php | sort -V | tail -n1)
echo "versi php-fpm: $V"

a2enmod proxy_fcgi setenvif

mkdir -p /var/www/eternal /etc/apache2/snippets
cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "<h1>ETERNAL</h1>";
echo "<p>Dilayani oleh: " . gethostname() . "</p>";
echo "<p>Versi PHP: " . phpversion() . "</p>";
echo "<p>SAPI: " . php_sapi_name() . "</p>";
?>
PHP
chown -R www-data:www-data /var/www/eternal

cat > /etc/apache2/snippets/www-eternal.conf <<'CONF'
# /eternal TIDAK diteruskan ke balancer vault, dilayani lokal oleh penny
ProxyPass /eternal !
Alias /eternal /var/www/eternal
<Directory /var/www/eternal>
    Options -Indexes
    AllowOverride None
    Require all granted
    DirectoryIndex index.php index.html
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php@V@-fpm.sock|fcgi://localhost"
    </FilesMatch>
</Directory>
CONF
sed -i "s/@V@/$V/g" /etc/apache2/snippets/www-eternal.conf

service php$V-fpm start || service php$V-fpm restart
apache2ctl configtest
service apache2 restart

echo "== tes =="
curl -i http://www.K38.com/eternal/