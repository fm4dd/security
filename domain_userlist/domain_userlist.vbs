'===========================================================================
' domain_userlist.vbs v1.1   @2013 by Frank4dd http://fm4dd.com/programming
'
' Description: This script collects all active and disabled accounts from a
'              selected active directory domain. The results are saved into
'              a local CSV file for further data mining in MS Excel.
'
' Run script:  C:\> cscript domain_userlist.vbs
'
' This script exists thanks to the research and publishing of other authors.
' It is free for use and enhancements. Although care has been taken during
' development, there is no warranty that it will work in all circumstances.
'
' Troubleshooting: Remember that AD records can always contain strange and
' unexpected values (i.e. from operator typo's, etc) that could prevent a
' correct displayed CVS format. In that case, a good approach is to open the
' CSV results file with a editor and validate the problematic line(s)
' through a direct record lookup using a LDAP client against AD.
'===========================================================================
On Error Resume Next 

'===========================================================================
' This script is intended to run on the Windows commandline under cscript.
' If run under wscript (user doubleclick), show a warning message and exit.
'===========================================================================
strScriptHost = LCase(Wscript.FullName)
If Right(strScriptHost, 11) = "wscript.exe" Then
    Wscript.Echo WScript.ScriptName & " should run only under cscript. Exiting..."
    Wscript.Quit
End If

'===========================================================================
' Global variables
'===========================================================================
Dim fso, myFile, selectedDomain, selectedFields, csvResultFile, csvHeaderLine
Dim objConnection, objCommand, objRecordSet 

'===========================================================================
' Global constants: Active Directory userAccountControl flag values, see
' http://support.microsoft.com/kb/305144
'===========================================================================
Const ADS_UF_PASSWD_CANT_CHANGE = &H40
Const ADS_UF_ACCOUNTDISABLE     = &H0002 
Const ADS_UF_DONT_EXPIRE_PASSWD = &H10000
Const ADS_SCOPE_SUBTREE         = 2

'===========================================================================
' Here we set the domain to query. For queries within the local domain, the
' domain controller is not necessary, we can set domainController = "local".
' If it is a trusted domain in our environment we need to set the Controllers
' DNS name or IP address. Example:
' domainController  = "mypdc01"
' domainDnsName     = "frank4dd.com"
' selectedDomain    = "DC=frank4dd,DC=com"
'===========================================================================
domainController  = "192.168.10.21"
domainDnsName     = "frank4dd.com"
selectedDomain    = "DC=frank4dd,DC=com"

'===========================================================================
' The name (and optional path) for the CSV result file.
'===========================================================================
csvResultFile     = "Domain_Accounts.csv"

'===========================================================================
' Definition of the AD user account fields to retrieve, and our Name for it.
' For a more complete listing of possible fields and their description, see 
' http://fm4dd.com/security/check-id-active-directory.htm#query
' The number of csvHeaderNames should match the value output at script end.
'===========================================================================
selectedFields    = "CN,sAMAccountName,displayName,userPrincipalName," & _
                    "userAccountControl,whenCreated,whenChanged," & _
                    "pwdLastSet, accountExpires,description"

csvHeaderLine     = "#,Status,User Name (CN),Account Name,Display Name," & _
                    "Principal Name,Creation Date,Last Update," & _
                    "Account Flags,PW Last Change,PW Expiry," & _
                    "Account Expiry,Description"


'===========================================================================
' Create the file handles: stdout, stderr and the CSV file for the results.
'===========================================================================
Set fso    = CreateObject("Scripting.FileSystemObject")
Set stdout = fso.GetStandardStream (1)
Set stderr = fso.GetStandardStream (2)
Set myFile = fso.CreateTextFile(csvResultFile, True)
localPath  = left(WScript.ScriptFullName,_
             (Len(WScript.ScriptFullName))-(len(WScript.ScriptName)))

'===========================================================================
' Start Console and file output: Create the CSV text file header line
'===========================================================================
stdout.WriteLine "Running " & WScript.ScriptName & " for domain " & _
                  selectedDomain & " ..."
stdout.WriteLine "=========================================================="
stdout.WriteLine
myFile.WriteLine csvHeaderLine

'===========================================================================
' Get domain's password age settings through the WinNT provider. See also
' http://www.rlmueller.net/WinNT_Binding.htm
'===========================================================================
If (domainController = "local") Then
  domainConnect = domainDnsName
Else
  domainConnect = domainController & "/" & selectedDomain
End If

Set objDomain   = GetObject("LDAP://" & domainConnect)

' debug output connection string
stdout.WriteLine "LDAP://" & domainConnect

Set objMaxPwdAge = objDomain.Get("maxPwdAge")

' Convert the received Integer8 64bit value into days.
' Account for bug in IADslargeInteger property methods.
lngHighAge = objMaxPwdAge.HighPart
lngLowAge = objMaxPwdAge.LowPart
If (lngLowAge < 0) Then
    lngHighAge = lngHighAge + 1
End If
intMaxPwdAge = -((lngHighAge * 2^32) _
    + lngLowAge)/(600000000 * 1440)

' debug output for intMaxPwdAge
stdout.WriteLine "Domain max password age: " & intMaxPwdAge

'===========================================================================
' Configure the LDAP query through the ADO provider.  See also
' http://support.microsoft.com/kb/187529
'===========================================================================
Set objConnection                    = CreateObject("ADODB.Connection")
objConnection.ConnectionTimeout      = 5            '-- default is 15secs --
objConnection.Provider               = ("ADsDSOObject")
objConnection.Open "Active Directory Provider"

Set objCommand                       = CreateObject("ADODB.Command")
objCommand.CommandTimeout            = 10            '-- default is 30secs --
objCommand.ActiveConnection          = objConnection
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE
objCommand.Properties("Page Size")   = 3000
objCommand.CommandText               = "SELECT " & selectedFields & _
                                       " FROM 'LDAP://" & domainConnect & _
                                       "' WHERE objectCategory='user'" 

' Debug line: write query command to console
stdout.WriteLine objCommand.CommandText

'===========================================================================
' Execute the Query
'===========================================================================
Set objRecordSet = objCommand.Execute 

'===========================================================================
' Loop through all records found in AD. Write shortened record values for
' progress control to console, and write the results into the CSV file.
'===========================================================================
recordCount = 0
activeCount = 0
disabledCount = 0

Do Until objRecordSet.EOF
  Dim sStatus, dName, cnName, uDesc, UacFlag, pCantChg, pLastChg, pExpiry
  recordCount = recordCount + 1

  '=========================================================================
  ' Get the date of last password set, skip if it is zero
  '=========================================================================
  pLastChgDate = Integer8Date(objRecordSet.Fields("pwdLastSet").Value)

  If (pLastChgDate = #1/1/1601#) Then
    pLastChgDate = "Unset"
  End If

  '=========================================================================
  ' Check the userAccountControl various flag settings here
  '=========================================================================
  UacFlag = objRecordSet.Fields("userAccountControl").Value

  ' Account disabled?
  If (UacFlag AND ADS_UF_ACCOUNTDISABLE) <> 0 Then
    sStatus = "Disabled"
    disabledCount = disabledCount+1
  Else
    sStatus = "Active"
    activeCount = activeCount+1
  End If

  pExpiry = "Unset"

  ' PW never expires?
  If (UacFlag AND ADS_UF_DONT_EXPIRE_PASSWD) <> 0 Then
    pExpiry = "Never"
  End If

  ' pLastChgDate = 0 and DONT_EXPIRE flag does not exist?
  If (pExpiry = "Unset") AND (pLastChgDate = "Unset") Then
    pExpiry = "ChgNextLogin"
  End If

  ' None of the cases above, calculate expiration
  If (pExpiry = "Unset") Then
    ' Calculate the PW expiry: last change date + PW policy MaxPwdAge
    pExpiry = DateValue(pLastChgDate + intMaxPwdAge)
    ' debug line
    ' stdout.WriteLine "pExpiry = " & pLastChgDate & "+" & intMaxPwdAge
  End If

  ' PW cannot change?
  If (UacFlag AND ADS_UF_PASSWD_CANT_CHANGE) <> 0 Then 
    pCantchg = "Set"
  Else
    pCantChg = " "
  End If

  '=========================================================================
  ' The displayName may have Commas troubling Excel, replace with space
  '=========================================================================
  dName = ""
  dName = Replace(cStr(objRecordSet.Fields("displayName").Value), ",", " ")

  '=========================================================================
  ' The CN may have strange values (duplicates) as below:
  'mahonkh
  'CNF:5f77a3e7-1fa1-4b02-a37f-cd9ac14b5ed1
  ' It may also have commas, we replace them with space for valid CSV
  '=========================================================================
  cnName = ""
  cnName = Replace(cStr(objRecordSet.Fields("CN").Value), vblf, " ")
  cnName = Replace(cnName, ",", " ")

  '=========================================================================
  ' The Description may have a commas or ", replace commas and " with space.
  ' Because this field has the type "advariant", we need to loop through it.
  '=========================================================================
  uDesc = ""
  For Each SubValue in objRecordSet.Fields("description").Value
    uDesc = uDesc & Replace(SubValue, ",", " ")
    uDesc = Replace(uDesc, """", " ")
  Next

  '=========================================================================
  ' If the account expiration is disabled, We set a readable name for '0'
  '=========================================================================
  If objRecordSet.Fields("accountExpiry").Value = "0" Then
    sExpiry = "Never"
  Else
    sExpiry = objRecordSet.Fields("accountExpiry").Value
  End If

  '=========================================================================
  ' Generate the query output to console, select fields to be included
  '=========================================================================
  stdout.WriteLine recordCount & " " & sStatus & " " & _
                   objRecordSet.Fields("sAMAccountname").Value & _
                   " " & dName & " " & " " & uDesc

  '=========================================================================
  ' Write the individual field and processed values to the CSV file.
  ' The number of fields should match the header line descriptions above.
  '=========================================================================
  myFile.WriteLine recordCount & "," & _
                   sStatus & "," & _
                   cnName & "," & _
                   objRecordSet.Fields("sAMAccountName").Value & "," & _
                   dName & "," & _
                   objRecordSet.Fields("userPrincipalName") & "," & _
                   objRecordSet.Fields("whenCreated") & "," & _
                   objRecordSet.Fields("whenChanged") & "," & _
                   objRecordSet.Fields("userAccountControl").Value & "," & _
                   pLastChgDate & "," & _
                   pExpiry & "," & _
                   sExpiry & "," & _
                   uDesc
  objRecordSet.MoveNext 
Loop 

objRecordSet.Close
myFile.Close

stdout.WriteLine
stdout.WriteLine "=========================================================="
stdout.WriteLine "End of " & WScript.ScriptName & ", run on Domain" & selectedDomain & "."
stdout.WriteLine "Extracted " & recordCount & " Records, " & _
                 disabledCount & " disabled, " & _
                 activeCount & " active into file " & _
                 localPath & csvResultFile & "."
stdout.WriteLine "=========================================================="

stdout.Close
stderr.Close

'===========================================================================
' End of Main
'===========================================================================

'===========================================================================
' Function to convert Integer8 (64-bit) value to a date, adjusted for local
' time zone bias. This function is necessary because the object "pwdLastSet"
' is stored as a Windows internal time object. See also
' http://msdn.microsoft.com/en-us/library/windows/desktop/ms679430(v=vs.85).aspx
'===========================================================================
Function Integer8Date(objDate)
  Dim lngAdjust, lngDate, lngHigh, lngLow
  lngHigh = objDate.HighPart
  lngLow = objdate.LowPart

  ' Obtain local Time Zone bias from machine registry.
  Set objShell = CreateObject("Wscript.Shell")
  lngBiasKey = objShell.RegRead("HKLM\System\CurrentControlSet\Control\" _
  & "TimeZoneInformation\ActiveTimeBias")

  If UCase(TypeName(lngBiasKey)) = "LONG" Then
    lngBias = lngBiasKey
  ElseIf UCase(TypeName(lngBiasKey)) = "VARIANT()" Then
    lngBias = 0
    For k = 0 To UBound(lngBiasKey)
      lngBias = lngBias + (lngBiasKey(k) * 256^k)
    Next
  End If

  lngAdjust = lngBias

  ' Account for error in IADslargeInteger property methods.
  If lngLow < 0 Then
    lngHigh = lngHigh + 1
  End If

  If (lngHigh = 0) And (lngLow = 0) Then
    lngAdjust = 0
  End If

  lngDate = #1/1/1601# + (((lngHigh * (2 ^ 32)) _
    + lngLow) / 600000000 - lngAdjust) / 1440

  Integer8Date = CDate(lngDate)
End Function
