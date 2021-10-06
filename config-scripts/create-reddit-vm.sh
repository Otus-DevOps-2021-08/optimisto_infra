#!/bin/bash

IMAGE_ID=fd8tj09s0n3jrq7hb13i # fake

yc compute instance create \
 --name reddit-full \
 --hostname reddit-full \
 --memory=2 \
 --create-boot-disk image-id=$IMAGE_ID \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --metadata serial-port-enable=1
