#!/bin/bash

setenforce 0 >> /dev/null 2>&1

export DEBIAN_FRONTEND=noninteractive

sudo apt update

sudo apt install nginx -y