#! /bin/bash

# install and configure nginx
sudo apt-get update
sudo apt-get --assume-yes install nginx
sudo service nginx start
HOSTNAME="$(curl --silent http://169.254.169.254/latest/meta-data/hostname)"
echo "<html><head><title>OpsSchool Rules</title></head><body><h1>OpsSchool Rules</h1><p>Hostname:"${HOSTNAME}"</p></body></html>" | sudo tee /var/www/html/index.html 

# install s3cmd
sudo apt --assume-yes install python-pip
sudo pip install "s3cmd==2.0.2"

# install logrotate changes and force them into activity
sudo cp /home/ubuntu/.s3cfg /root/.s3cfg
sudo cp /home/ubuntu/nginx /etc/logrotate.d/nginx
sudo logrotate -f /etc/logrotate.conf
