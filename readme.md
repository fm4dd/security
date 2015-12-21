# Security

This repository contains security-related software.
http://fm4dd.com/security/

### check-console-defaults

* * *

[check-console-defaults](check-console-defaults): One potentially fatal mistake is to connect the server's management console into an end-user reachable network, unconfigured and without further protection. It may sound incredible, but in a real-life case, several dozens of PRD servers turned out to be accessible that way. 

### domain-userlist

* * *

[domain-userlist](domain-userlist): By default, Windows allows allows any domain user to retrieve full Windows Domain information about all users, groups, and other AD information. By scripting, we can obtain almost all information available in Active Directory. This script downloads the full list of Domain users, together with their password settings into a CSV file for easy user sorting. It works for acount extraction within the local domain and with trusted domains, common in larger environments.

### smbscan

* * *

[smbscan](smbscan): Windows file sharing is the most common way for file exchange between users in a office network. Security however usually is lost in everyday use. As a result, sensitive files get shared with everyone. This script identifies open file shares, and determines whats is behind them. The automation supports a quicker idenitifcation of security problems, and speeds up the lock down of sensitive information.
