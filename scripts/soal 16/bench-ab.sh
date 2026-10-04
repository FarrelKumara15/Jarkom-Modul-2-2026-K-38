#!/bin/bash

G=K38

if ! command -v ab >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update && apt-get install -y apache2-utils
    else
        apk add apache2-utils
    fi
fi

for T in www static; do
    URL="http://$T.$G.com/"
    echo "$URL"
    # -l : jangan hitung "Failed requests" hanya karena panjang respon beda antar backend
    ab -n 250 -c 10 -l "$URL" > /root/ab-$T.txt 2>&1
    grep -E "Server Software|Server Hostname|Document Path|Document Length|Concurrency Level|Time taken|Complete requests|Failed requests|Non-2xx|Requests per second|Time per request|Transfer rate" /root/ab-$T.txt
    echo
done
echo "Output lengkap: /root/ab-www.txt dan /root/ab-static.txt"