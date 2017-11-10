# check_snmp_access.pl

## Man page for the check_snmp_access.pl tool

Copyright (c) 2017 Frank4DD<support[at]frank4dd.com>

### check_snmp_access.pl

* * *

Many professional-grade infrastructure devices such as switches, printers, or video equipment implement the SNMP protocol for monitoring. Vendors often enable it by default for out-of-the-box functionality, using the SNMPv1 and v2c default community strings ("public"). For security conscious environments, this can be a problem since it aids adversaries through effortless information gathering. This Perl script automates the large-scale identification and verification, e.g. to confirm remediation efforts.

#### Usage:

`check_snmp_access.pl [network] [start-ip] [end-ip]`

`check_snmp_access.pl -f [ip_list_file]`

#### Options:

[network]
      The first three octets of a IP address, e.g. 192.168.1.

[start-ip]
      The first host to check. the program will add this number it to the network octets to start the loop. "1" will translate together with the network 192.168.1 to 192.168.1.1 as the first IP to be checked.

[end-ip]
      The last host to check. The program adds this number to the network octets to stop the loop. "254" will  translate together with the network 192.168.1 to 192.168.1.254 as the last IP to be checked.

-f [ip_list_file]
      Instead of a network range, a file name containing the IPs to be checked can be given as an argument. The file should have the IP listed one per line.

#### Usage Example:

Running the program:

<pre>root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ./check-snmp-access.pl -f testiplist 
Checking 192.168.250.96... Host 192.168.250.96 alive... No SNMP access.
Checking 192.168.37.25... Host 192.168.37.25 alive... SNMP found... Descr: Product: GW 4 FXO;SW Version: 6.00A.037.003
Checking 192.168.37.37... Host 192.168.37.37 alive... SNMP found... Descr: IBM OS/400 V7R1M0
Checking 192.168.37.38... Host 192.168.37.38 alive... SNMP found... Descr: IBM OS/400 V7R1M0
Checking 192.168.37.39... Host 192.168.37.39 alive... SNMP found... Descr: IBM OS/400 V7R1M0
Checking 192.168.10.228... Host 192.168.10.228 does not exist.
...</pre>

#### Notes:

For Perl to open ICMP sockets to do the initial ping, the script requires root (Unix) or local administrator (Windows) privileges. If this script runs under Windows, open the commandline console with right-click, selecting "Run as administrator". In Unix/Linux, run it through "sudo".

See also http://fm4dd.com/security
