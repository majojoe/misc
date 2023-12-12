#!/bin/bash
DOMAIN=example.localnet

sudo mount -t cifs -o "user=$(id -u),gid=$(id -g),iocharset=utf8,nosuid,nodev,domain=${DOMAIN},sec=krb5,cruid=$(id -u)" //srv-dc01/Data$ /mnt
