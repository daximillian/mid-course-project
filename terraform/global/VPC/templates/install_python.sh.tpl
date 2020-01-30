#! /bin/bash

sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository --yes --update ppa:deadsnakes/ppa
sudo apt-get install -y python3.6
sudo apt-get install -y python3-pip