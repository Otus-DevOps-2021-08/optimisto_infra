#!/bin/bash

sudo systemctl stop mongod
sudo sed -i "s,\\(^[[:blank:]]*bindIp:\\) .*,\\1 0.0.0.0," /etc/mongod.conf
sudo systemctl start mongod
