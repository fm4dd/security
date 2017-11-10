#!/usr/bin/perl -w
# ------------------------------------------------------------ #
# check_snmp_access.pl v1.0 20171102 frank4dd  GPLv3           #
#                                                              #
# This script checks for servers with accessible SNMP          #
# service, using the default community string "public".        #
# SNMP should be protected from general access through         #
# non-defaut community strings and host restrictions,          #
# ideally even through setup of v3 auth and encryption.        #
#                                                              #
# v1.0 20171102 initial release                                #
# ------------------------------------------------------------ #
use Net::Ping;
use Net::SNMP;

#my @query_oid = ( "1.3.6.1.2.1.1.1.0" ); # SNMP MIB-2 System sysDescr
my @query_oid = ( "1.3.6.1.2.1.1.5.0" ); # SNMPv2-MIB::sysName.0
#my @query_oid = ( "1.3.6.1.2.1.25.3.2.1.3.1" ); # HOST-RESOURCES-MIB::hrDeviceDescr.1
my $port = 161;
my $community = "public";
my $snmp_timeout = 2;
my $ping_timeout = 1;

$num_args = $#ARGV + 1;
my @ip_list;

if ($ARGV[0] && $ARGV[0] eq "-f") {
  if ($num_args != 2) { usage(); }
  # ------------------------------------------------------------ #
  # We have been called with a file containing the IP to check.  #
  # ------------------------------------------------------------ #
  my $filename = $ARGV[1];
  open (FH, "< $filename") or die "Error: Can't open $filename for read: $!";
  chomp (@ip_list = <FH>);
  close FH or die "Cannot close $filename: $!";
}
else {
  if ($num_args != 3) { usage(); }
  # ------------------------------------------------------------ #
  # Below is the network range we will verify. This is typically #
  # a class-C network, sometimes a smaller subnet range. We give #
  # the values on the command line, but we could also hardcode.. #
  # my $basenet = "192.168.240";                                 #
  # my $start_host = 1;                                          #
  # my $end_host = 25;                                           #
  # ------------------------------------------------------------ #
  my $basenet=$ARGV[0];
  my $start_host=$ARGV[1];
  my $end_host=$ARGV[2];
  my $host = $start_host;
  my $i = 0;

  while($host<=$end_host) {
    $ip = $basenet.".".$host;
    $ip_list[$i] = $ip;
    $host++;
    $i++;
  }
}

if (@ip_list == 0) {
  print "Error: No IP's to process.\n";
  exit 1;
}

foreach $ip(@ip_list) {
  print "Checking $ip... ";

  # ------------------------------------------------------------ #
  # Before checking for NFS access, we first ping the host to    #
  # ensure it exists. Otherwise, the NFS check 'hangs' and waits #
  # with a long, hard to interrupt timeout. Our ping timeout is  #
  # set to 1 second only, providing a fast scan (ptimeout = 1;). #
  # ------------------------------------------------------------ #
  my $p=Net::Ping->new('icmp');
  if ($p->ping($ip, $ping_timeout)) {
    print "Host $ip alive... ";
  } else {
    print "Host $ip does not exist.\n";
    next;
  }
  $p->close();

  # ------------------------------------------------------------ #
  # Here we make the SNMP query and see if the device responds.  #
  # ------------------------------------------------------------ #
  # SNMPv1 Login, get a session
  ($session, $error) = Net::SNMP->session(
    -hostname  => $ip,
    -version   => 1,
    -community => $community,
    -port      => $port,
    -timeout   => $snmp_timeout
  );

  if (!defined($session)) {
    printf("Error creating SNMP session: %s.\n", $error);
    next;
  }

  # query the OID here
  my $result = $session->get_request(-varbindlist => \@query_oid);

  # check the access result
  if (!defined($result)) {
    if ($session->error =~ m/No response from remote host/i)
      { printf("No SNMP access.\n"); }
    else
      { printf("SNMP found... Error: %s.\n", $session->error); }
    $session->close;
    next;
  }
  $session->close;
  print "SNMP found... Descr: ".$result->{$query_oid[0]}."\n";
}

# ------------------------------------------------------------ #
# This function prints the programs usage and help message     #
# ------------------------------------------------------------ #
sub usage {
  print "Usage-1: check_snmp_access.pl <network-base> <start_ip> <end_ip>\n";
  print "Usage-2: check_snmp_access.pl -f <ip-address-file>\n\n";
  print "Example: check_snmp_access.pl 192.168.1 20 44\n";
  print "This will run the check on these IP's: 192.168.1.20-44.\n\n";
  print "Example: check_snmp_access.pl -f ./testfile\n";
  print "This will run the check on IP's listed in testfile, one per line.\n\n";
  exit 1;
}
