#!/usr/bin/perl
#
# create OTP environment file for heat (greg.procunier@gmail.com)
#

my @cluster = (
                'cfme-bastion-0.idm.example.com',
                'cfme-database-0.idm.example.com',
                'cfme-database-1.idm.example.com',
                'cfme-portal-0.idm.example.com',
                'cfme-portal-1.idm.example.com',
                'cfme-worker-0.idm.example.com',
                'cfme-worker-1.idm.example.com',
                'cfme-worker-2.idm.example.com'
              );

qx 'klist 2>/dev/null';
my $rc = $?;
$rc = $rc >> 8 unless ($rc == -1);

die "Please kinit as an admin user before running this script\n"
  if($rc != 0);


open(my $fh, '>', 'ipa_enrollment.yaml') or
  die "Unable to open ipa_enrollment.yaml for writing: $!\n";

print $fh "parameter_defaults:\n";
print $fh "  ipa_enrollment:\n";
foreach my $node (@cluster) {

  qx "ipa host-del $node";
  $result = qx "ipa host-add $node --force --random --raw";

  if($result =~ /\s+randompassword:\s+(\S+)/) {
    print "Writing OTP Secret for $node\n";
    print $fh "    $node:\n";
    print $fh "      name: $node\n";
    print $fh "      otp: '$1'\n";
  }
}

close $fh;
