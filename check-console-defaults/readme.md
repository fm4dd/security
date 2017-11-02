# check_console_defaults.pl

## Man page for the check_console_defaults.pl tool

Copyright (c) 2012 Frank4DD<support[at]frank4dd.com>

### check_console_defaults.pl

* * *

One potentially fatal mistake is to connect the server's management console into an end-user reachable network, unconfigured and without further protection. With outsourcing and shortage of resource, its not uncommone to discover dozens or more PRD servers accessible with vendor default passwords.

#### Usage:

`check_console_defaults.pl [network] [start-ip] [end-ip]`  

`check_console_defaults.pl -f [ip_list_file]`

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

<pre>D:\Code> check_console_defaults.pl 192.168.24 1 254
...
Checking 192.168.24.3... Host does not exist.
Checking 192.168.24.4... Host 192.168.24.4 alive... CIMC found! ...Default Login success!
Checking 192.168.24.5... Host 192.168.24.5 alive... CIMC found! ...Default Login success!
Checking 192.168.24.6... Host 192.168.24.6 alive... CIMC found! ...Default Login failed.
Checking 192.168.24.7... Host does not exist.
Checking 192.168.24.8... Host does not exist.
Checking 192.168.24.9... Host does not exist.
Checking 192.168.24.10... Host 192.168.24.10 alive... iDrac found! ...Default Login success!
Checking 192.168.24.11... Host does not exist.
Checking 192.168.24.12... Host 192.168.24.12 alive... iDrac found! ...Default Login success!
Checking 192.168.24.13... Host 192.168.24.13 alive... iDrac found! ...Default Login failed.
Checking 192.168.24.14... Host 192.168.24.14 alive... iDrac found! ...Default Login failed.
Checking 192.168.24.15... Host does not exist.
...
Checking 192.168.24.76... Host does not exist.
Checking 192.168.24.77... Host 192.168.24.77 alive... No SSL web page found.
Checking 192.168.24.78... Host 192.168.24.78 alive... No SSL web page found.
Checking 192.168.24.79... Host does not exist.
Checking 192.168.24.80... Host does not exist.
...</pre>

#### Notes:

For Perl to open ICMP sockets to do the initial ping, the script requires root (Unix) or local administrator (Windows) privileges. If this script runs under Windows, open the commandline console with right-click, selecting "Run as administrator". In Unix/Linux, run it through "sudo".

See also http://fm4dd.com/security/check-console-defaults.htm
