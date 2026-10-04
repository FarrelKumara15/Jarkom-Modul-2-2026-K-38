#!/bin/bash

G=K38
H=$(hostname)
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx lynx curl dnsutils
apt-get install -y php8.4-fpm || apt-get install -y php-fpm
V=$(ls /etc/php | sort -V | tail -n1)

D=/var/www/core.$G.com
mkdir -p $D

cat > $D/index.php <<'PHP'
<?php
echo "<h1>Beranda</h1>";
echo "<p>Dilayani oleh: " . gethostname() . "</p>";
echo "<p>Versi PHP: " . phpversion() . "</p>";
echo "<a href='/profil'>Halaman Profil</a>";
?>
PHP

cat > $D/profil.php <<'PHP'
<?php
echo "<h1>Profil</h1>";
echo "<p>Node: " . gethostname() . "</p>";
echo "<p>Kelompok: @G@</p>";
echo "<a href='/'>Kembali ke Beranda</a>";
?>
PHP
sed -i "s/@G@/$G/g" $D/profil.php

cat > /etc/nginx/sites-available/core.$G.com.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name core.@G@.com @H@.@G@.com;

    root /var/www/core.@G@.com;
    index index.php;

    location / {
        # rewrite: /profil -> /profil.php (URL bersih tanpa .php)
        rewrite ^/([^\.]+)$ /$1.php last;
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php@V@-fpm.sock;
    }
}
NGINX
sed -i "s/@G@/$G/g; s/@H@/$H/g; s/@V@/$V/g" /etc/nginx/sites-available/core.$G.com.conf

ln -sf /etc/nginx/sites-available/core.$G.com.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
chown -R www-data:www-data $D

service php$V-fpm start || service php$V-fpm restart
nginx -t
service nginx restart
sleep 1
echo "== uji lewat hostname =="
lynx -dump http://$H.$G.com/
lynx -dump http://$H.$G.com/profil
