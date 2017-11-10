# check_nfs_access.pl

## Man page for the check_nfs_access.pl tool

Copyright (c) 2017 Frank4DD<support[at]frank4dd.com>

### check_nfs_access.pl

* * *

NFS is still a common file sharing protocol for midrange UNIX systems. This script checks for world-readable file shares that may inadvertantly expose data. Although NFS is no longer a common protocol and shares would be unlikely visible to normal Wintel-based end users, it takes little effort to anyone looking with intent.

#### Usage:

`check_nfs_access.pl [network] [start-ip] [end-ip]`

`check_nfs_access.pl -f [ip_list_file]`

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

<pre>root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ./check-nfs-access.pl -f testiplist 
Checking 192.168.30.130... Host 192.168.30.130 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.131... Host 192.168.30.131 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.139... Host 192.168.30.139 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.141... Host 192.168.30.141 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.146... Host 192.168.30.146 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.56... Host 192.168.30.56 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.57... Host 192.168.30.57 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.59... Host 192.168.30.59 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.30.62... Host 192.168.30.62 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.1... Host 192.168.31.1 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.123... Host 192.168.31.123 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.3... Host 192.168.31.3 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.35... Host 192.168.31.35 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.46... Host 192.168.31.46 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.56... Host 192.168.31.56 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.31.85... Host 192.168.31.85 alive...  share: /export/images (everyone) share: /export/spot (everyone)
Checking 192.168.34.241... Host 192.168.34.241 does not exist.
Checking 192.168.34.242... Host 192.168.34.242 does not exist.
Checking 192.168.34.243... Host 192.168.34.243 does not exist.
Checking 192.168.34.244... Host 192.168.34.244 does not exist.
...</pre>

#### Notes:

For Perl to open ICMP sockets to do the initial ping, the script requires root (Unix) or local administrator (Windows) privileges. If this script runs under Windows, open the commandline console with right-click, selecting "Run as administrator". In Unix/Linux, run it through "sudo".

This script uses the `showmount -e` system command, which in turn requires the NFS tools package (nfs-common) to be installed. For Debian/Ubuntu, this would do: `sudo apt-get install nfs-common`.

See also http://fm4dd.com/security
