#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

tee /etc/consul.d/jenkins-master-8080.json > /dev/null <<"EOF"
{
  "service": {
    "id": "jenkins-master-8080",
    "name": "jenkins-master",
    "tags": ["jenkins"],
    "port": 8080,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 8080",
        "tcp": "localhost:8080",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "http",
        "name": "HTTP on port 8080",
        "http": "http://localhost:8080/",
        "interval": "30s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

consul reload
