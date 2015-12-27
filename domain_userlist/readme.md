# domain_userlist.vbs

## Man page for the domain_userlist.vbs tool

Copyright (c) 2013 Frank4DD<support[at]frank4dd.com>

### domain_userlist.vbs

* * *

This script connects to domain controllers through LDAP and downloads the full list of Domain users, together with their password settings into a CSV file for easy user sorting. It works for acount extraction within the local domain, and with trusted domains, common in larger environments.

Using CSV and Excel is handy to drill down on users excempted from password change, to check when a password changed, or to see if a account has been disabled timely.

#### Usage:

`cscript domain_userlist.vbs`  

#### Options:

These are currently hardcoded inside the script (see line 56-58):

[domainController]  
      The domain controller IP

[domainDnsName]  
      The domains DNS name

[selectedDomain]  
      The LDAP-style CN of the domain to query

#### Usage Example:

Running the program:

<pre>D:\Code\VBS>cscript domain_userlist.vbs
Microsoft (R) Windows Script Host Version 5.8
Copyright (C) Microsoft Corporation. All rights reserved.

Running domain_userlist.vbs for domain DC=frank4dd,DC=com ...
===============================================================================

1 Active IUSR_MCLSSERVER1 Internet Server Anonymous Access
2 Disabled krbtgt Key Distribution Center Service Account
...
6726 Active mizmike Mike Mizonus  Hired 2010/01/03

===============================================================================
End of get_domain_userlist.vbs, run on Domain DC=frank4dd,DC=com.
Extracted 6726 Records, 3712 disabled, 3014 active into file D:\Domain_Accounts.csv.
===============================================================================</pre>

#### Output Example:

The results file shown in Excel:

![](images/domain-userlist-csvfile1.png)![](images/domain-userlist-csvfile2.png)

#### Notes:

Extracting 50,000 accounts takes a bit since windows limits bulk retrieval of records (Windows 2003: 1000 records, 5000 since Windows 2008).
This is controlled through the __MaxPageSize__ value.
