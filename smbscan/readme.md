root@lts1404:/home/fm # java -cp .:../dist/jcifs.jar smbscan FMDOM2 frank4dd mypass 192.168.10 20 22 csv wt
Received arg csv - Using CSV format with separator: ,
Received arg wt - Adding write tests.
TEST: 192.168.10.20 Ping: OK TCP-445: OK NAME: JPNFMMGR01 DOMAIN: FMDOM2 SHARE: MyTraceFiles EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080472113.txt No Write Access
 SHARE: C$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080472388.txt No Write Access
 SHARE: F$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080473100.txt No Write Access
 SHARE: D$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080473359.txt No Write Access
 SHARE: temp EXPORT: No Access FOLDER: analyzed 10 ACE READ: checked 5/5 share entries WRITE: test1450080474636.txt Write Access OK
 SHARE: ADMIN$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080474854.txt No Write Access
 SHARE: Q$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080475274.txt No Write Access
TEST: 192.168.10.21 Ping: OK TCP-445: OK NAME: JPNRSV001 DOMAIN: FMDOM2 SHARE: SYSVOL EXPORT: No Access FOLDER: analyzed 9 ACE READ: checked 5/6 share entries WRITE: test1450080475690.txt No Write Access
 SHARE: C$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080475978.txt No Write Access
 SHARE: D$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080476166.txt No Write Access
 SHARE: E$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080476336.txt No Write Access
 SHARE: ADMIN$ EXPORT: No Access FOLDER: No Access READ: No Read Access WRITE: test1450080476604.txt No Write Access
 SHARE: NETLOGON EXPORT: No Access FOLDER: analyzed 9 ACE READ: checked 5/173 share entries WRITE: test1450080477023.txt No Write Access

