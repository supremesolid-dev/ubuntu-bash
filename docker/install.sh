#!/bin/bash

setenforce 0 >> /dev/null 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get install -y ca-certificates curl 
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker.service
systemctl enable containerd.service

DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
NEW_DAEMON_JSON_CONTENT='{
"iptables": false,
"log-driver": "json-file",
	"log-opts": {
		"max-size": "10m",
		"max-file": "3"
	}
}'
echo "$NEW_DAEMON_JSON_CONTENT" | sudo tee "$DOCKER_DAEMON_JSON" > /dev/null

systemctl restart docker.service
systemctl restart containerd.service