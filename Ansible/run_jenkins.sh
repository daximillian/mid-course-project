#!/usr/bin/env bash
# set -e

docker swarm leave --force
docker swarm init

echo "admin" | docker secret create jenkins-user -
echo "admin" | docker secret create jenkins-pass -

docker stack deploy -c ~/jenkins.yml jenkins