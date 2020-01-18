#! /bin/bash
echo "Installing dependencies ..."
sudo apt-get update
sudo apt-get install -y unzip curl jq dnsutils

echo "Determining Consul version to install ..."
CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
if [ -z "$CONSUL_DEMO_VERSION" ]; then
    CONSUL_DEMO_VERSION=$(curl -s "${CHECKPOINT_URL}"/consul | jq .current_version | tr -d '"')
fi

echo "Fetching Consul version ${CONSUL_DEMO_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_DEMO_VERSION}/consul_${CONSUL_DEMO_VERSION}_linux_amd64.zip -o consul.zip

echo "Installing Consul version ${CONSUL_DEMO_VERSION} ..."
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul

sudo mkdir /etc/consul.d
sudo chmod a+w /etc/consul.d

# Specify a Consul version
CONSUL_DEMO_VERSION = ENV['CONSUL_DEMO_VERSION']