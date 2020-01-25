#!/usr/bin/env bash

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
cd /home/ubuntu/.ssh/
echo "y" | ssh-keygen -t rsa -m PEM -C "ubuntu key" -P "" -f "ubuntu_rsa"
cat ubuntu_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
 printf "$PRIVATE_IP " > ubuntu_known_host.pub 
cat /home/ubuntu/.ssh/ubuntu_rsa.pub >> ubuntu_known_host.pub
