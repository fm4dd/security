'===========================================================================
' domaingroup_userlist.vbs v1.0   @2017 frank4dd
'
' Description: This script collects all accounts belonging to a group from a
'              selected active directory domain. 
'
' Run script:  C:\> cscript domaingroup_userlist.vbs /g:"Domain Users"
'
' Example output:
' 
' D:\VB>cscript domain_group_userlist.vbs
' Microsoft (R) Windows Script Host Version 5.8
' Copyright (C) Microsoft Corporation. All rights reserved.
' 
' Running domain_group_userlist.vbs for domain DC=frank4dd,DC=com ...
' ==========================================================
'
' LDAP://192.168.1.9/DC=frank4dd,DC=com
'
' SELECT member FROM 'LDAP://192.168.1.9/DC=japan,DC=corp,DC=manulife,DC=com'
' WHERE CN='Domain Admins'
' 1 User Name: John Smith       Status: Active
' 2 User Name: John Doe         Status: Active
' 3 User Name: patchadmin       Status: Active
' ==========================================================
' End of domaingroup_userlist.vbs, run on Domain DC=frank4dd,DC=com.
' Extracted 3 members from group [Domain Admins].
' Active: 3 Disabled: 0
' ==========================================================
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
'
' TODO: Error handling for connection problems, e.g. wrong creds
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
domainController  = "mypdc01"
domainDnsName     = "frank4dd.com"
selectedDomain    = "DC=frank4dd,DC=com"

'===========================================================================
' If it isn't a local/trusted domain, best to specify dedicated creds.
'===========================================================================
domainUserID      = "frank4dd\johndoe"
domainUserPW      = "correctPassword"

'===========================================================================
' Check Commandline argument /g:groupname for the AD group to analyze.
' If nothing given, we use the "Domain Admin" group.
'===========================================================================
If WScript.Arguments.Named.Exists("G") Then
  GroupName = WScript.Arguments.Named.Item("G")
Else
  GroupName = "Domain Admins"
End If

'===========================================================================
' For getting User details, we retrieve the fields given in UserFields.
'===========================================================================
GroupFields = "member"
UserFields  = "sAMAccountName,displayName,userAccountControl"

'===========================================================================
' Create the file handles: stdout, stderr and the CSV file for the results.
'===========================================================================
Set fso    = CreateObject("Scripting.FileSystemObject")
Set stdout = fso.GetStandardStream (1)
Set stderr = fso.GetStandardStream (2)
localPath  = left(WScript.ScriptFullName,_
             (Len(WScript.ScriptFullName))-(len(WScript.ScriptName)))

'===========================================================================
' Start Console and file output: Create the CSV text file header line
'===========================================================================
stdout.WriteLine "Running " & WScript.ScriptName & " for domain " & _
                  selectedDomain & " ..."
stdout.WriteLine "=========================================================="
stdout.WriteLine

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

'===========================================================================
' Configure the LDAP query through the ADO provider.  See also
' http://support.microsoft.com/kb/187529
'===========================================================================
Set objConnection                    = CreateObject("ADODB.Connection")
objConnection.ConnectionTimeout      = 5            '-- default is 15secs --
objConnection.Provider               = ("ADsDSOObject")
objConnection.Properties("User ID")  = domainUserID
objConnection.Properties("Password") = domainUserPW
'objConnection.Properties("Encrypt Password") = TRUE
'objConnection.Properties("ADSI Flag") = 3 

objConnection.Open "Active Directory Provider"

Set objCommand                       = CreateObject("ADODB.Command")
objCommand.CommandTimeout            = 10            '-- default is 30secs --
objCommand.ActiveConnection          = objConnection
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE
objCommand.Properties("Page Size")   = 3000
objCommand.CommandText               = "SELECT " & GroupFields & _
                                       " FROM 'LDAP://" & domainConnect & _
                                       "' WHERE CN='" & GroupName & "'"

' Debug line: write query command to console
stdout.WriteLine objCommand.CommandText

'===========================================================================
' Execute the Query
'===========================================================================
Set objRecordSet = objCommand.Execute 

groupCount    = 0
memberCount   = 0
disabledCount = 0
activeCount   = 0

Do Until objRecordSet.EOF
  groupCount = groupCount + 1
  arrMemberOf = objRecordSet.Fields("member").Value

  '=========================================================================
  ' Run through each group member and query their details
  '=========================================================================
  For Each strMember in arrMemberOf
    memberCount = memberCount + 1
    'stdout.WriteLine memberCount & " " & strMember
    
    ' Build query for info of a single user    
    Set objCommand2                      = CreateObject("ADODB.Command")
    objCommand2.CommandTimeout            = 10            '-- default is 30secs --
    objCommand2.ActiveConnection          = objConnection
    objCommand2.Properties("Searchscope") = ADS_SCOPE_SUBTREE
    objCommand2.Properties("Page Size")   = 3000
    objCommand2.CommandText               = "SELECT " & UserFields & _
                                            " FROM 'LDAP://" & domainConnect & _
                                            "' WHERE distinguishedName='" & strMember & "'"
    ' stdout.WriteLine objCommand2.CommandText
    Set userRecordSet = objCommand2.Execute
    
    '=========================================================================
    ' Check the userAccountControl various flags, especially for "Disabled"
    '=========================================================================
    UacFlag = userRecordSet.Fields("userAccountControl").Value

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
  
    '=========================================================================
    ' Generate the query output to console, select fields to be included
    '=========================================================================
    stdout.WriteLine memberCount & " User Name: " & _
    userRecordSet.Fields("displayName").Value & Chr(9) & " Status: " & sStatus
    
  Next
  objRecordSet.MoveNext 
Loop 

objRecordSet.Close

stdout.WriteLine
stdout.WriteLine "=========================================================="
stdout.WriteLine "End of " & WScript.ScriptName & ", run on Domain " & selectedDomain & "."
If groupCount = 0 Then
  stdout.WriteLine "Cannot find group [" & GroupName & "]."
Else
  stdout.WriteLine "Extracted " & memberCount & " members from group [" & GroupName & "]."
  stdout.WriteLine "Active: " & activeCount & " Disabled: " & disabledCount
  stdout.WriteLine "=========================================================="
End If
stdout.Close
stderr.Close

'===========================================================================
' End of Main
'===========================================================================