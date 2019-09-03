#!/bin/bash
# extract the keypair from the cloudforms-cluster-keypairs stack (greg.procunier@gmail.com)

source ./cloudforms-openrc.sh

keypair=$(openstack stack list -f json | jq -r '.[] | select(.["Stack Name"] | contains("cloudforms-cluster-keypairs")) | .ID')

openstack stack show "${keypair}" -f json -c outputs | jq -r '.outputs[] | select(.output_key | contains("cloudforms-private-key")) | .output_value' | tee cloudforms-server-key.rsa
chmod 400 cloudforms-server-key.rsa
