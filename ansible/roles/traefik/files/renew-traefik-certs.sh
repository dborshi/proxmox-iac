#!/bin/bash
set -e
cp /etc/letsencrypt/live/dbnet.work/fullchain.pem /etc/traefik/certs/fullchain.dbnet.crt
cp /etc/letsencrypt/live/dbnet.work/privkey.pem   /etc/traefik/certs/wildcard.dbnet.key
systemctl restart traefik
