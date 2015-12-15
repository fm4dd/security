#!C:\Program Files\perl\bin\Perl.exe -w
# ------------------------------------------------------------ #
# check_console_defaults.pl v1.0 20121020 frank4dd  GPLv3      #
#                                                              #
# This script checks for reachable server management console   #
# systems. Access to these systems should be restricted, and   #
# default username/passwords should have changed immediately.  #
#                                                              #
# Works with iDRAC v6, CIMC v1.2, iLO v2                       #
# ------------------------------------------------------------ #
use Net::Ping;
use LWP::UserAgent;

# ------------------------------------------------------------ #
# Below is the network range we will verify. This is typically #
# a class-C network, sometimes a smaller subnet range. We give #
# the values on the command line, but we could also hardcode.. #
# my $basenet = "192.168.240";                                 #
# my $start_host = 1;                                          #
# my $end_host = 25;                                           #
# ------------------------------------------------------------ #
$num_args = $#ARGV + 1;
if ($num_args != 3) {
  print "Usage: check_console_defaults.pl <network-base> <start_ip> <end_ip>\n\n";
  print "Example: check_console_defaults.pl 192.168.1 20 44\n";
  print "This will run the check on these IP's: 192.168.1.20-44.\n";
  exit -1;
}

my $basenet=$ARGV[0];
my $start_host=$ARGV[1];
my $end_host=$ARGV[2];

# ------------------------------------------------------------ #
# Below are the HTML signatures for server management console  #
# systems. The script checks 3 vendors: Cisco, Dell and HP as  #
# the most commonly available server vendors in the industry.  #
#                                                              #
# Cisco is simple, because we get a login page right away.     #
# Dell is tricky, because the initial response is a empty page #
# containing a conditional javasacript redirect to support SSO.#
# ------------------------------------------------------------ #
my $cimc_id = "<title>Cisco Integrated Management Controller Login</title>";
my $idrac_id = "          top.document.location.href = \"/sclogin.html\";";
my $hpilo_id = "<TITLE>HP Integrated Lights-Out 2 Login</TITLE>";

# ------------------------------------------------------------ #
# Below are the default usernames and passwords for management # 
# console systems. Cisco and Dell use primitive default values #
# while HP uses the serial printed on the servers service tag. #
# We don't know the HP serial, will check for "password" only. #
# Cisco CIMC default: admin/password                           #
# Dell iDRAC default: root/calvin                              #
# HP iLO default:     Administrator/serial-tag-code            #
# ------------------------------------------------------------ #

my $host = $start_host;
while($host<=$end_host) {
  $ip = $basenet.".".$host;
  print "Checking $ip... ";

  # ------------------------------------------------------------ #
  # Before checking the web interface, we first ping the host to #
  # ensure it exists. Otherwise, the web check 'hangs' and waits #
  # with a long, hard to interrupt timeout. Our ping timeout is  #
  # set to 1 second only, providing a fast scan (ptimeout = 1;). #
  # ------------------------------------------------------------ #
  my $p=Net::Ping->new('icmp');
  my $ptimeout = 1;
  if ($p->ping($ip, $ptimeout)) {
    print "Host $ip alive... ";
  } else {
    print "Host does not exist.\n";
    $host++;
    next;
  }
  $p->close();

  # ------------------------------------------------------------ #
  # All modern remote management console systems run under SSL,  #
  # in 99.9% using the default selfsigned certs. We ignore them. #
  # Cisco CIMC web interface delivers content with compression,  #
  # we need to accept & handle the gzip-encoded server response. #
  # ------------------------------------------------------------ #
  my $ua = LWP::UserAgent->new(ssl_opts =>{verify_hostname => 0});
  $ua->timeout(2);
  my $can_accept = HTTP::Message::decodable;

  my $https_url = "https://".$ip."/";
  my $ssl_response = $ua->get($https_url, 'Accept-Encoding' => $can_accept,);

  if(! $ssl_response->is_success) {
    print "No SSL web page found.\n";
    $host++;
    next;
  }

  # debug
  #print "\n".$ssl_response->decoded_content."\n";

  if($ssl_response->decoded_content =~ m/$cimc_id/i) {
    print "CIMC found! ";
    &check_cimc_login;
  } 
  elsif($ssl_response->decoded_content =~ m/$idrac_id/i) {
    print "iDrac found! ";
    &check_idrac_login;
  }
  elsif($ssl_response->decoded_content =~ m/$hpilo_id/i) {
    print "HP iLO found! ";
  }
  else {
    print "SSL Web page is not console mgmt.";
  }
  print "\n";
  $host++;
}

# ------------------------------------------------------------ #
# CIMC login function to check access with default values      #
# works... :-)                                                 #
# ------------------------------------------------------------ #
sub check_cimc_login {
  
  # ----------------------------------------------------------- #
  # The login attempt receives two xml responses for OK & FAIL: #
  # ----------------------------------------------------------- #
  my $login_ok =   "<authResult>0</authResult> <forwardUrl>index.html</forwardUrl> </root>";
  my $login_fail = "<authResult>1</authResult> <forwardUrl>index.html</forwardUrl>  <errorMsg></errorMsg></root>";
  my $ua = LWP::UserAgent->new(ssl_opts =>{verify_hostname => 0});
  $ua->timeout(2);
  my $can_accept = HTTP::Message::decodable;

  my $login_url = "https://".$ip."/data/login";
  my $login_res = $ua->post( $login_url, { 'user' => 'admin', 'password' => 'password' } ); 
  my $logindata = $login_res->decoded_content(); 

  # debug
  # print "\n".$logindata."\n";

  if($logindata =~ m/$login_ok/) {
    print "...Default Login success!";
  }
  elsif($logindata =~ m/$login_fail/) {
    print "...Default Login failed.";
  }
  else {
    print "Unknown response.";
  }
}

# ------------------------------------------------------------ #
# This login function checks the iDRAC default password access.#
# Incidentally, the function is *very* similar to Cisco. DELL  #
# was first, so maybe Cisco engineers were doing some re-eng   #
# when they build their CIMC? Javascript looks copy&paste...   #
# works... :-)                                                 #
# ------------------------------------------------------------ #
sub check_idrac_login {
  
  # ----------------------------------------------------------- #
  # The login attempt receives two xml responses for OK & FAIL: #
  # ----------------------------------------------------------- #
  my $login_ok =   "<authResult>0</authResult> <forwardUrl>index.html</forwardUrl> </root>";
  my $login_fail = "<authResult>1</authResult> <forwardUrl>index.html</forwardUrl>  <errorMsg></errorMsg></root>";

  my $ua = LWP::UserAgent->new(ssl_opts =>{verify_hostname => 0});
  $ua->timeout(2);
  my $can_accept = HTTP::Message::decodable;
  my $login_url = "https://".$ip."/data/login";

  # ----------------------------------------------------------- #
  # here we make the HTTP request, using DELL's default values: #
  # ----------------------------------------------------------- #
  my $login_res = $ua->post( $login_url, Content => 'user=root&password=calvin' );
  my $logindata = $login_res->decoded_content(); 

  # debug
  # print "\n".$logindata."\n";

  if($logindata =~ m/$login_ok/) {
    print "...Default Login success!";
  }
  elsif($logindata =~ m/$login_fail/) {
    print "...Default Login failed.";
  }
  else {
    print "Unknown response.";
  }
}
