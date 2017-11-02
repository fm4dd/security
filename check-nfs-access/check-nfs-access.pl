#!/usr/bin/perl -w
# ------------------------------------------------------------ #
# check_nfs_access.pl v1.1 20171030 frank4dd  GPLv3            #
#                                                              #
# This script checks for servers with accessible nfs file      #
# shares. Access to these shares should be restricted.         #
#                                                              #
# Requires:	/sbin/showmount provided by nfs-common package #
#                                                              #
# v1.0 20171102 initial release                                #
# ------------------------------------------------------------ #
use Net::Ping;

$num_args = $#ARGV + 1;
my @ip_list;

if ($ARGV[0] eq "-f") {
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
  # We got a network range to verify. For ease of programming,   #
  # its a /24 network, sometimes a smaller subnet range. We get  #
  # the values on the command line, but we could also hardcode:  #
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
  my $ptimeout = 1;
  if ($p->ping($ip, $ptimeout)) {
    print "Host $ip alive... ";
  } else {
    print "Host $ip does not exist.\n";
    next;
  }
  $p->close();

  open my $NFS, "/sbin/showmount -e $ip|"; 
  chomp (@nfs_list = <$NFS>);
  foreach $share(@nfs_list) {
    if($share =~ m/\(everyone\)/) {
      $share =~ s/\t/ /g; # replace tabs with space
      $share =~ s/ +/ /g; # replace multiple space with one
      print " share: " .$share;
    }
  }
  print "\n";
  close $NFS or die "Cannot close /sbin/showmount: $!";
}

# ------------------------------------------------------------ #
# This function prints the programs usage and help message     #
# ------------------------------------------------------------ #
sub usage {
  print "Usage-1: check_nfs_access.pl <network-base> <start_ip> <end_ip>\n";
  print "Usage-2: check_nfs_access.pl -f <ip-address-file>\n\n";
  print "Example: check_nfs_access.pl 192.168.1 20 44\n";
  print "This will run the check on these IP's: 192.168.1.20-44.\n\n";
  print "Example: check_nfs_access.pl -f ./testfile\n";
  print "This will run the check on IP's listed in testfile, one per line.\n\n";
  exit 1;
}
