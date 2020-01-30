#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)


tee /etc/consul.d/jenkins-node-22.json > /dev/null <<"EOF"
{
  "service": {
    "id": "jenkins-node-22",
    "name": "jenkins-node",
    "tags": ["jenkins"],
    "port": 22,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 22",
        "tcp": "localhost:22",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

consul reload
