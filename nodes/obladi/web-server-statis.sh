#!/bin/bash

echo "== Sinkronisasi Waktu Otomatis =="
export DEBIAN_FRONTEND=noninteractive
apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update
apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false install -y ntpdate
ntpdate id.pool.ntp.org

echo "== Memulai Instalasi & Konfigurasi Web Server =="
G=K38
H=$(hostname)

apt-get update && apt-get install -y apache2 lynx curl dnsutils

D=/var/www/vault.$G.com
mkdir -p $D/arsip
echo "<h1>Vault - $H</h1>" > $D/index.html
echo "isi file 1 dari $H" > $D/arsip/file1.txt
echo "isi file 2 dari $H" > $D/arsip/file2.txt
echo "isi file 3 dari $H" > $D/arsip/catatan.txt

cat > /etc/apache2/sites-available/vault.$G.com.conf <<'CONF'
<VirtualHost *:80>
    ServerName vault.@G@.com
    ServerAlias @H@.@G@.com
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/vault.@G@.com

    <Directory /var/www/vault.@G@.com>
        Options -Indexes
    </Directory>

    <Directory /var/www/vault.@G@.com/arsip>
        Options +Indexes
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
CONF

sed -i "s/@G@/$G/g; s/@H@/$H/g" /etc/apache2/sites-available/vault.$G.com.conf

grep -q "ServerName localhost" /etc/apache2/apache2.conf || echo "ServerName localhost" >> /etc/apache2/apache2.conf
a2dissite 000-default.conf
a2ensite vault.$G.com.conf
apache2ctl configtest
service apache2 restart
sleep 1

echo "== Uji lewat hostname =="
lynx -dump http://$H.$G.com/arsip/
lynx -dump http://vault.$G.com/arsip/
