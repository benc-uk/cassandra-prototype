#!/bin/bash
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install -y influxdb
sudo sed -i 's/# index-version = "inmem"/index-version = "tsi1"/g' /etc/influxdb/influxdb.conf
sudo service influxdb start
