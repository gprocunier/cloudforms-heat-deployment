#!/bin/bash
# apply first boot configuration to the hosts (greg.procunier@gmail.com)
# 
# v2 handle otp by  ___IPA_PRINCIPAL___ will being set based on heat


### Common init steps
/usr/bin/hostnamectl set-hostname ___FQDN___ || exit 1
/usr/bin/curl -k "___KATELLO_URI___" -o /tmp/katello-ca-consumer-latest.noarch.rpm || exit 1
/usr/bin/rpm -ivh /tmp/katello-ca-consumer-latest.noarch.rpm || exit 1
/usr/bin/subscription-manager register --org="___RHSM_ORG___" --activationkey="___RHSM_KEY___" --force || exit 1
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


### Role Specific steps

NODETYPE="___ROLE___"

case "$NODETYPE" in

  bastion)
    echo "Configuring node as type: bastion"
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
