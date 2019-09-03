#!/bin/sh
# My build harness
# prereq: 01-cloudforms-config.yaml has been customized
# prereq: 02-cloudforms-project.yaml has been deployed

# assumption #0 - you are a cloud operator and your profile is downloaded 
source /home/stack/overcloud/cloudforms/cloudforms-openrc.sh

# assumption #1 - you are a domain admin
kdestroy
kinit admin

# assumption #2 - you have ssh keys copied to your satellite from the builder host
# assumption #3 - your sudo is configured for NOPASSWORD
read -r -d '' WORK <<'__EOF__'
declare -a cfme

cfme=( cfme-bastion-0.idm.example.com cfme-database-0.idm.example.com  cfme-database-1.idm.example.com  cfme-portal-0.idm.example.com  cfme-portal-1.idm.example.com  cfme-worker-0.idm.example.com  cfme-worker-1.idm.example.com  cfme-worker-2.idm.example.com )

for i in "${cfme[@]}"
do
  sudo hammer host delete --name $i >/dev/null 2>&1
  echo -n "."
done
echo
__EOF__

if [[ $# -ne 1 ]]
then
  echo "wiping old nodes from satellite"
  ssh gprocuni@satellite.example.com "${WORK}"
fi

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
# assumption #4 - this file is downloaded out of contrib and is in the pwd of build.sh
perl ./ipa_enrollment.pl

openstack stack create \
  -e 'https://raw.githubusercontent.com/gprocunier/cloudforms-heat-deployment/master/01-cloudforms-config.yaml' \
  -e 'ipa_enrollment.yaml' \
  -t 'https://raw.githubusercontent.com/gprocunier/cloudforms-heat-deployment/master/03-cloudforms-cluster.yaml' \
  --wait \
  --timeout 10 \
  cloudforms-cluster
