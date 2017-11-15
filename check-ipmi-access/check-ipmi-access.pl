#!/usr/bin/perl -w
# ------------------------------------------------------------ #
# check_ipmi_access.pl v1.0 20171113 frank4dd  GPLv3           #
#                                                              #
# This script checks for servers with accessible ipmi          #
# ports. It depends on the commandline program ipmitool        #
# (apt-get install ipmitool).                                  #
#                                                              #
# ipmitool example output:                                     #
# ipmitool -I lanplus -C 0 -H 10.128.12.104 -U admin -P "" sel #
# | grep Version	                                       #
# Version          : 1.5 (v1.5, v2 compliant)                  #
#                                                              #
# v1.0 20171113 initial release                                #
# ------------------------------------------------------------ #
use Net::Ping;
use POSIX ":sys_wait_h";

# Some boards respond slowly, wait up to 20 secs for response
my $ipmi_timeout=20;
my $ipmi_warn=-1;
my $writemode=0;
my $help=0;

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
  # Before checking for IPMI access, we first ping the host to   #
  # ensure it exists. Otherwise the IPMI check 'hangs' and waits #
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

  # ------------------------------------------------------------ #
  # Calling ipmitool. We need Interface type "-I lanplus", set   #
  # ciphersuite "-C 0" to turn off all encryption, integrity and #
  # authentication, "-v" is set to see if IPMI responds or not.  #
  # ------------------------------------------------------------ #
  open my $IPMI, "ipmitool -I lanplus -C 0 -H $ip -U admin -P \"\" sel -v 2>&1 |"; 
  waitpid(-1, 0); # wait for process to finish
  chomp (@ipmi_list = <$IPMI>);

  if ($? == 0) {
    foreach $line(@ipmi_list) {
      if($line =~ m/Version/) {
        $line =~ s/\t/ /g; # replace tabs with space
        $line =~ s/ +/ /g; # replace multiple space with one
        print " IPMI found... sel-output: $line\n";
      }
    }
  }
  else { 
    foreach $line(@ipmi_list) {
      # If we connect to a system that may not respond on port 623
      if($line =~ m/Error issuing Get Channel Authentication Capabilities request/) {
        print "No IPMI access... $line\n";
      }
      # If we connect to IPMI, but the username is wrong
      elsif($line =~ m/RAKP 2 message indicates an error : unauthorized name/) {
        print " IPMI found... $line\n";
      }
    } 
  }
}

# ------------------------------------------------------------ #
# This function prints the programs usage and help message     #
# ------------------------------------------------------------ #
sub usage {
  print "Usage-1: check_ipmi_access.pl <network-base> <start_ip> <end_ip>\n";
  print "Usage-2: check_ipmi_access.pl -f <ip-address-file>\n\n";
  print "Example: check_ipmi_access.pl 192.168.1 20 44\n";
  print "This will run the check on these IP's: 192.168.1.20-44.\n\n";
  print "Example: check_ipmi_access.pl -f ./testfile\n";
  print "This will run the check on IP's listed in testfile, one per line.\n\n";
  exit 1;
}
