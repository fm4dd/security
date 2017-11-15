# IPMI response examples with ipmitool

Below is ipmitool commandline output as an example of data returned.

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin lan print
Set in Progress         : Set Complete
Auth Type Support       : NONE MD2 MD5 PASSWORD 
Auth Type Enable        : Callback : 
                        : User     : MD2 MD5 PASSWORD OEM 
                        : Operator : MD2 MD5 PASSWORD OEM 
                        : Admin    : MD2 MD5 PASSWORD OEM 
                        : OEM      : 
IP Address Source       : Static Address
IP Address              : 192.168.12.104
Subnet Mask             : 255.255.255.0
MAC Address             : c4:71:fe:b1:26:6c
SNMP Community String   : Sh1nkwc88mc
IP Header               : TTL=0x40 Flags=0x00 Precedence=0x00 TOS=0x10
BMC ARP Control         : ARP Responses Disabled, Gratuitous ARP Disabled
Gratituous ARP Intrvl   : 2.0 seconds
Default Gateway IP      : 192.168.12.254
Default Gateway MAC     : 00:00:00:00:00:00
Backup Gateway IP       : 0.0.0.0
Backup Gateway MAC      : 00:00:00:00:00:00
802.1q VLAN ID          : Disabled
802.1q VLAN Priority    : 0
RMCP+ Cipher Suites     : 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
Cipher Suite Priv Max   : aaaaaaaaaaaaaaa
                        :     X=Cipher Suite Unused
                        :     c=CALLBACK
                        :     u=USER
                        :     o=OPERATOR
                        :     a=ADMIN
                        :     O=OEM
Bad Password Threshold  : Not Available
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin sel
SEL Information
Version          : 1.5 (v1.5, v2 compliant)
Entries          : 3008
Free Space       : 0 bytes 
Percent Used     : 100%
Last Add Time    : 02/03/2014 06:32:52
Last Del Time    : 05/18/2011 11:43:02
Overflow         : true
Supported Cmds   : 'Reserve' 
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin fru
FRU Device Description : Builtin FRU Device (ID 0)
 Chassis Type          : Rack Mount Chassis
 Chassis Part Number   : 74-7340-02
 Chassis Serial        : QCI1516A43Z
 Chassis Extra         : Cisco Systems Inc
 Board Mfg Date        : Sun May 18 03:13:00 1997
 Board Mfg             : Cisco Systems Inc
 Board Product         : R200-1120402W
 Board Serial          : QCI1515A3Y5
 Board Part Number     : 74-7340-02
Board Extra           : AV02
 Board Extra           : 0000000000
 Product Manufacturer  : Cisco Systems Inc
 Product Name          : R200-1120402W
 Product Part Number   : 74-7340-02
 Product Version       : 0
 Product Serial        : QCI1516A43Z
 Product Asset Tag     : Unknown


FRU Device Description : FRU_HD_BP (ID 1)
 Device not present (Timeout)

FRU Device Description : FRU_MB (ID 2)
 Board Mfg Date        : Sun May 18 03:13:00 1997
 Board Mfg             : Cisco Systems Inc
 Board Product         : R200-1120402W
 Board Serial          : QCI1515A3Y5
 Board Part Number     : 74-7340-02
Board Extra           : AV02
 Board Extra           : 0000000000
 Product Manufacturer  : Cisco Systems Inc
 Product Name          : R200-1120402W
 Product Part Number   : 74-7340-02
 Product Version       : 0
 Product Serial        : QCI1516A43Z
 Product Extra         : A0V02

FRU Device Description : PSU1 (ID 3)
 Product Manufacturer  : Cisco Systems Inc
 Product Name          : R2X0-PSU2-650W-SB
 Product Part Number   : 74-7541-02
 Product Version       : A0
 Product Serial        : QCI15391P5C
 Product Extra         : V01
 Product Extra         : 
�

FRU Device Description : PSU2 (ID 4)
 Product Manufacturer  : Cisco Systems Inc
 Product Name          : R2X0-PSU2-650W-SB
 Product Part Number   : 74-7541-02
 Product Version       : A0
 Product Serial        : QCI15391P5N
 Product Extra         : V01
 Product Extra         : 
�

FRU Device Description : FRU_FP (ID 5)
 Unknown FRU header version 0xff

FRU Device Description : FRU_MP0 (ID 6)
 Device not present (Timeout)

FRU Device Description : FRU_MP1 (ID 7)
 Device not present (Timeout)
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin pef
 0x51 | 16 | 8 | 6d03a492-68a6-11e0-a8ca-c471feb1266c | Alert,Power-off,Reset,Power-cycle,OEM-defined
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin mc info
Device ID                 : 32
Device Revision           : 15
Firmware Revision         : 1.04
IPMI Version              : 2.0
Manufacturer ID           : 5771
Manufacturer Name         : Unknown (0x168B)
Product ID                : 5 (0x0005)
Product Name              : Unknown (0x5)
Device Available          : yes
Provides Device SDRs      : yes
Additional Device Support :
    Sensor Device
    SDR Repository Device
    SEL Device
    FRU Inventory Device
    IPMB Event Receiver
    IPMB Event Generator
Aux Firmware Rev Info     : 
    0x00
    0x01
    0xb4
    0x0a
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin mc getenables
Receive Message Queue Interrupt          : disabled
Event Message Buffer Full Interrupt      : disabled
Event Message Buffer                     : disabled
System Event Logging                     : enabled
OEM 0                                    : disabled
OEM 1                                    : disabled
OEM 2                                    : disabled
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin dcmi power reading

    Instantaneous power reading:                     8 Watts
    Minimum during sampling period:                  8 Watts
    Maximum during sampling period:                188 Watts
    Average power reading over sample period:        8 Watts
    IPMI timestamp:                           Tue Nov 14 16:49:58 2017
    Sampling period:                          00000001 Seconds.
    Power reading state is:                   activated
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P admin shell
ipmitool> 
ipmitool> sensor
P3V_BAT_SCALED   | na         |            | na    | 2.178     | 2.350     | na        | na        | 3.168     | na        
P12V_SCALED      | na         |            | na    | 10.679    | 11.033    | na        | na        | 12.921    | 13.334    
P5V_SCALED       | na         |            | na    | 4.675     | 4.844     | na        | na        | 5.157     | 5.278     
P3V3_SCALED      | na         |            | na    | 3.097     | 3.192     | na        | na        | 3.381     | 3.492     
P5V_STBY_SCALED  | na         |            | na    | 4.675     | 4.844     | na        | na        | 5.157     | 5.278     
VR_CPU1_IOUT     | na         |            | na    | na        | na        | na        | 152.680   | 164.040   | 175.400   
VR_CPU2_IOUT     | na         |            | na    | na        | na        | na        | 152.680   | 164.040   | 175.400   
PV_VCCP_CPU1     | na         |            | na    | 0.706     | 0.725     | na        | na        | 1.392     | 1.431     
PV_VCCP_CPU2     | na         |            | na    | 0.706     | 0.725     | na        | na        | 1.392     | 1.431     
P1V5_DDR3_CPU1   | na         |            | na    | 1.343     | 1.431     | na        | na        | 1.558     | 1.646     
P1V5_DDR3_CPU2   | na         |            | na    | 1.343     | 1.431     | na        | na        | 1.558     | 1.646     
P1V1_IOH         | na         |            | na    | 1.029     | 1.068     | na        | na        | 1.137     | 1.166     
P1V8_AUX         | na         |            | na    | 1.695     | 1.744     | na        | na        | 1.852     | 1.911     
IOH_THERMALERT_N | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
IOH_THERMTRIP_N  | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
P2_THERMTRIP_N   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
P1_THERMTRIP_N   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
IRQ_P2_RDIM_EVNT | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
IRQ_P1_RDIM_EVNT | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
IRQ_P2_VRHOT     | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
IRQ_P1_VRHOT     | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
CPUS_PRCHT_N     | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
CATERR_N         | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
DDR3_P2_D1_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P2_D2_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P2_E1_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P2_E2_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P2_F1_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P2_F2_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P1_A1_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P1_A2_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P1_B1_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P1_B2_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P1_C1_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
DDR3_P1_C2_ECC   | na         |            | na    | na        | na        | na        | na        | 10.000    | 15.000    
IOH_TEMP_SENS    | na         |            | na    | na        | na        | na        | 80.000    | 85.000    | 90.000    
P2_TEMP_SENS     | na         |            | na    | na        | na        | na        | 62.000    | 72.000    | 82.000    
P1_TEMP_SENS     | na         |            | na    | na        | na        | na        | 87.000    | 92.000    | 97.000    
DDR3_P2_D1_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P2_D2_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P2_E1_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P2_E2_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P2_F1_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P2_F2_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P1_A1_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P1_A2_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P1_B1_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P1_B2_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P1_C1_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
DDR3_P1_C2_TMP   | na         |            | na    | na        | na        | na        | 68.000    | 70.000    | 75.000    
P2_PRESENT       | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
P1_PRESENT       | 0x0        | discrete   | 0x0280| na        | na        | na        | na        | na        | na        
DDR3_P2_D1_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P2_D2_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P2_E1_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P2_E2_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P2_F1_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P2_F2_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P1_A1_PRS   | 0x0        | discrete   | 0x0280| na        | na        | na        | na        | na        | na        
DDR3_P1_A2_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P1_B1_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P1_B2_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P1_C1_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
DDR3_P1_C2_PRS   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
MAIN_POWER       | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
BIOS_POST_CMPLT  | 0x0        | discrete   | 0x0280| na        | na        | na        | na        | na        | na        
SEL_FULLNESS     | 100.000    | unspecified | cr    | na        | na        | na        | na        | 80.000    | na        
LED_HLTH_STATUS  | 0x0        | discrete   | 0x1280| na        | na        | na        | na        | na        | na        
LED_FPID         | 0x0        | discrete   | 0x4180| na        | na        | na        | na        | na        | na        
BIOSPOST_TIMEOUT | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
POWER_ON_FAIL    | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
PSU1_STATUS      | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
PSU2_STATUS      | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
PSU_REDUNDANCY   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
2U_PRESENT       | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
SLOT_PRESENT_0   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
SLOT_PRESENT_1   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
SLOT_PRESENT_2   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
SLOT_PRESENT_3   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
SLOT_PRESENT_4   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_01_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_02_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_03_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_04_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
PSU1_VOUT        | na         |            | na    | na        | na        | na        | na        | 13.000    | 15.000    
PSU1_IOUT        | na         |            | na    | na        | na        | na        | 53.000    | 58.000    | 60.000    
PSU1_TEMP_1      | 25.000     | degrees C  | ok    | na        | na        | na        | 60.000    | 65.000    | 70.000    
PSU1_FAN_1       | na         |            | na    | na        | na        | na        | na        | na        | na        
PSU1_POUT        | na         |            | na    | na        | na        | na        | 652.000   | 680.000   | 700.000   
PSU1_PIN         | na         |            | na    | na        | na        | na        | 652.000   | 680.000   | 700.000   
PSU2_VOUT        | na         |            | na    | na        | na        | na        | na        | 13.000    | 15.000    
PSU2_IOUT        | na         |            | na    | na        | na        | na        | 53.000    | 58.000    | 60.000    
PSU2_TEMP_1      | 23.000     | degrees C  | ok    | na        | na        | na        | 60.000    | 65.000    | 70.000    
PSU2_FAN_1       | na         |            | na    | na        | na        | na        | na        | na        | na        
PSU2_POUT        | na         |            | na    | na        | na        | na        | 652.000   | 680.000   | 700.000   
PSU2_PIN         | na         |            | na    | na        | na        | na        | 652.000   | 680.000   | 700.000   
W793_FAN1_TACH1  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN1_TACH2  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN2_TACH1  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN2_TACH2  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN3_TACH1  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN3_TACH2  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN4_TACH1  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN4_TACH2  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN5_TACH1  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
W793_FAN5_TACH2  | na         |            | na    | 600.000   | 800.000   | na        | na        | na        | na        
LED_PSU_STATUS   | 0x0        | discrete   | 0x2180| na        | na        | na        | na        | na        | na        
LED_DIMM_STATUS  | 0x0        | discrete   | 0x2180| na        | na        | na        | na        | na        | na        
LED_CPU_STATUS   | 0x0        | discrete   | 0x2180| na        | na        | na        | na        | na        | na        
HDD_05_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_06_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_07_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_08_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_09_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_10_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_11_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_12_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_13_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_14_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_15_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
HDD_16_STATUS    | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
1U_PRESENT       | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
FP_AMBIENT_TEMP  | na         |            | na    | na        | na        | na        | 40.000    | 45.000    | 55.000    
POWER_USAGE      | 8.000      | Watts      | ok    | na        | na        | na        | na        | 680.000   | 700.000   
VICP81E_0_PRS    | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
VICP81E_0_OVRTMP | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
VICP81E_0_TMP1   | na         | degrees C  | na    | na        | na        | na        | 80.000    | 90.000    | 100.000   
VICP81E_0_TMP2   | na         | degrees C  | na    | na        | na        | na        | 80.000    | 90.000    | 100.000   
VICP81E_0_TMP3   | na         | degrees C  | na    | na        | na        | na        | 80.000    | 90.000    | 100.000   
VICP81E_1_PRS    | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na        
VICP81E_1_OVRTMP | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
VICP81E_1_TMP1   | na         | degrees C  | na    | na        | na        | na        | 0.000     | 0.000     | 0.000     
VICP81E_1_TMP2   | na         | degrees C  | na    | na        | na        | na        | 0.000     | 0.000     | 0.000     
VICP81E_1_TMP3   | na         | degrees C  | na    | na        | na        | na        | 0.000     | 0.000     | 0.000     
2U_HDD_PRESENT   | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
2U_SLOT_PRESENT  | na         | discrete   | na    | na        | na        | na        | na        | na        | na        
ipmitool> 
```
```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.1 -U admin -P admin sel -v
Get Auth Capabilities error
Error issuing Get Channel Authentication Capabilities request
Error: Unable to establish IPMI v2 / RMCP+ session
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin1 -P admin sel -v
RAKP 2 message indicates an error : unauthorized name
Error: Unable to establish IPMI v2 / RMCP+ session
```

```
root@lts1604:/home/fm/sf_VM_Shared/code/Perl# ipmitool -I lanplus -C 0 -H 192.168.12.104 -U admin -P test sel -v
Running Get PICMG Properties my_addr 0x20, transit 0, target 0x20
Error response 0xc1 from Get PICMG Properities
Running Get VSO Capabilities my_addr 0x20, transit 0, target 0x20
Invalid completion code received: Invalid command
Discovered IPMB address 0x0
SEL Information
Version          : 1.5 (v1.5, v2 compliant)
Entries          : 3008
Free Space       : 0 bytes 
Percent Used     : 100%
Last Add Time    : 02/03/2014 06:32:52
Last Del Time    : 05/18/2011 11:43:02
Overflow         : true
Supported Cmds   : 'Reserve' 
```
