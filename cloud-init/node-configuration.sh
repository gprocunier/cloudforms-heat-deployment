#!/bin/bash
# apply first boot configuration to the hosts (greg.procunier@gmail.com)
# 
# v2 handle otp by  ___IPA_PRINCIPAL___ will being set based on heat
# v3 set root password from OS::Heat::Randomstring


### Common init steps
/usr/bin/hostnamectl set-hostname ___FQDN___ || exit 1
echo ___ROOTPW___ | passwd root --stdin
/usr/bin/curl -k "___KATELLO_URI___" -o /tmp/katello-ca-consumer-latest.noarch.rpm || exit 1
/usr/bin/rpm -ivh /tmp/katello-ca-consumer-latest.noarch.rpm || exit 1

# occasional satellite registration failures shouldnt tank the whole build
while [[ $reg_rc -eq 1 ]]
do
  /usr/bin/subscription-manager register --org="___RHSM_ORG___" --activationkey="___RHSM_KEY___" --force
  reg_rc=$?
done

/bin/yum -y install ipa-client || exit 1
/sbin/ipa-client-install --domain="___DNS_DOMAIN___" \
                         --realm="___IPA_REALM___" \
                         --server="___IPA_SERVER___" \
                         --hostname="___FQDN___" \
                         --ip-address="___FLOATING_IP___" \
                         --password="___IPA_PASSWORD___" \
                         --mkhomedir \
                         --force-join \
                         --unattended ___IPA_PRINCIPAL___

# Required for OS::Heat::SoftwareDeployment / Ansible postgres_query
/usr/bin/subscription-manager repos --enable=rhel-7-server-openstack-13-rpms
/bin/yum -y install \
  os-collect-config \
  os-refresh-config \
  os-apply-config \
  python-heat-agent \
  python-heat-agent-ansible \
  python-heat-agent-apply-config \
  python-heat-agent-hiera \
  python-heat-agent-json-file \
  python-heat-agent-puppet \
  python2-zaqarclient \
  python-psycopg2


systemctl enable os-collect-config
systemctl start --no-block os-collect-config
### Role Specific steps

NODETYPE="___ROLE___"

case "$NODETYPE" in

  bastion)
    echo "Configuring node as type: bastion"
    /bin/yum -y install ansible
    ;;
  database)
    echo "Configuring node as type: database"
    ;;
  portal)
    echo "Configuring node as type: portal"
    ;;
  worker)
    echo "Configuring node as type: worker"
    ;;
  *)
    echo "NODETYPE not defined"
    ;;
esac
