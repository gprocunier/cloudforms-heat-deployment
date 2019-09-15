#!/bin/sh
# My build harness
# prereq: 01-cloudforms-config.yaml has been customized
# prereq: 02-cloudforms-project.yaml has been deployed

# assumption #0 - you are a cloud operator and your profile is downloaded 
source /home/stack/overcloud/cloudforms/cloudforms-openrc.sh

# assumption #1 - you are a domain admin
kdestroy
kinit admin

echo "Hit enter to deploy cloudforms-cluster" && read

# Delete pre-existing stack and entertain with a pleasant spinner
while [[ ! -z $(openstack stack show cloudforms-cluster -c id -f value 2>/dev/null) ]]
do
  openstack stack delete --yes --wait  cloudforms-cluster >/dev/null 2>&1 &
  deletepid="$!"
  i=1
  sp="/-\|"
  echo -n 'Deleting previous cloudforms-cluster  '
  while [ -d /proc/"$deletepid" ]
  do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 0.2
  done 
done
printf "\b\b\nCreating...\n"

# This generates the node OTP and is why we need kinit admin or equiv
# assumption #2 - this file is downloaded out of contrib and is in the pwd of build.sh
perl ./ipa_enrollment.pl

openstack stack create \
  -e 'https://raw.githubusercontent.com/gprocunier/cloudforms-heat-deployment/raw/master/01-cloudforms-config.yaml' \
  -e 'ipa_enrollment.yaml' \
  -t 'https://raw.githubusercontent.com/gprocunier/cloudforms-heat-deployment/raw/master/03-cloudforms-cluster.yaml' \
  --wait \
  cloudforms-cluster

# assumption #3 - get-private-key.sh is downloaded out of contrib and in the pwd of build.sh
if [[ ! -z $(openstack stack show cloudforms-cluster -c id -f value 2>/dev/null) ]]
then
  [[ -f cloudforms-server-key.rsa ]] && rm -f cloudforms-server-key.rsa
  echo "extracting private key"
  ./get-private-key.sh 
  echo "copying private key to bastion"
  scp -i ./cloudforms-server-key.rsa cloudforms-server-key.rsa cloud-user@cfme-bastion-0.idm.example.com:.
fi
