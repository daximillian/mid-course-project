#!/usr/bin/python3

import json
import requests
import subprocess
import sys

def create_credentials(hostname, filename):
    """Create SSH credentials for a Jenkins user."""
    with open(filename) as private_key:    
        data = {
        'credentials': {
            'scope': "GLOBAL",
            'username': "ubuntu",
            'privateKeySource': {
                'privateKey': private_key.read(),
                'stapler-class': "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource"
            },
            'stapler-class': "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
        }
    }

        payload = {
            'json': json.dumps(data),
            'Submit': "OK",
        }

        credential_request = requests.post("http://admin:admin@{}:{}/credentials/store/system/domain/_/createCredentials".format(hostname, 8080), data=payload)
    if credential_request.status_code != requests.codes.ok:
        print(credential_request.text)



if __name__ == '__main__':
    create_credentials(sys.argv[1], sys.argv[2])

