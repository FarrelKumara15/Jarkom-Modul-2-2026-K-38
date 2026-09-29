#!/bin/sh

G=K38
echo "klien: $(hostname)"
for h in vault core www static; do
  echo "== $h.$G.com =="
  dig $h.$G.com +short
done
