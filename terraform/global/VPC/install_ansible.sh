#! /bin/bash

sudo apt-get update
sudo apt install python
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get --assume-yes install ansible
