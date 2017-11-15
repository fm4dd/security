# check_ipmi_access.pl

## Man page for the check_ipmi_access.pl tool

Copyright (c) 2017 Frank4DD<support[at]frank4dd.com>

### check_ipmi_access.pl

* * *

The Intelligent Platform Management Interface (IPMI) is a set of computer interface specifications that provides management and monitoring capabilities independently of the host system. It is often embedded with a BMC (Baseboard Management Console). A BMC is a server hardware console with a network interface that provides out-of-band server management: to reboot the server, access the BIOS or console screen. Server vendors such as Cisco or HP had their respective BMC boards (CIMC and ILO) run the IPMI service by default, which listens on UDP port 623. In 2013, a number of vulnerabilities surfaced and turned IPMI into a risk that subsequently lead to it preferably disabled.

This script looks for IPMI in a range of IP's as a quick way for verification and reporting.

#### Usage:

`check_ipmi_access.pl [network] [start-ip] [end-ip]`

`check_ipmi_access.pl -f [ip_list_file]`

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

<pre>root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ./check-ipmi-access.pl -f testiplist
Checking 192.168.12.125... Host 192.168.12.125 alive... No IPMI access... Error issuing Get Channel Authentication Capabilities request
Checking 192.168.12.131... Host 192.168.12.131 alive...  IPMI found... sel-output: Version : 1.5 (v1.5, v2 compliant)
Checking 192.168.12.154... Host 192.168.12.154 alive...  IPMI found... sel-output: Version : 1.5 (v1.5, v2 compliant)
Checking 192.168.12.164... Host 192.168.12.164 alive...  IPMI found... sel-output: Version : 1.5 (v1.5, v2 compliant)
Checking 192.168.12.171... Host 192.168.12.171 alive...  IPMI found... sel-output: Version : 1.5 (v1.5, v2 compliant)
Checking 192.168.12.172... Host 192.168.12.172 alive...  IPMI found... sel-output: Version : 1.5 (v1.5, v2 compliant)
Checking 192.168.12.25... Host 192.168.12.25 alive...  IPMI found... RAKP 2 message indicates an error : unauthorized name
Checking 192.168.12.26... Host 192.168.12.26 alive...  IPMI found... RAKP 2 message indicates an error : unauthorized name
...</pre>

Running the program:

#### Notes:

For Perl to open ICMP sockets to do the initial ping, the script requires root (Unix) or local administrator (Windows) privileges. If this script runs under Windows, open the commandline console with right-click, selecting "Run as administrator". In Unix/Linux, run it through "sudo".

This script uses the `ipmitool` system command, which needs to be installed. For Debian/Ubuntu, this would do: `sudo apt-get install ipmitool`.

TODO: add a list of IPMI default user/password combinations to check...

See also http://fm4dd.com/security
