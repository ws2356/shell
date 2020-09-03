#!/bin/bash

sudo apt-get update

sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -aG docker "$USER"

docker run -e PASSWORD=XXXXXXXX -e SERVER_ADDR=0.0.0.0  -e SERVER_PORT=1080 -e  METHOD=aes-256-cfb -p 2022:1080  -d --name ssO--restart always  shadowsocks/shadowsocks-libev
