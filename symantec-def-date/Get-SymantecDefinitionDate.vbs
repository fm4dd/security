'===========================================================================
' Get-SymantecDefinitionDate.vbs                            @2017 frank4dd
'
' Gets the date and revision of the Symantec AV definitions from registry.
' Takes the host to query as a commandline argument.

' Usage: i). Open the command line window (Command Prompt)
'       ii). Run this vbscript file using built-in commandline utility CScript 
'       
' Example:
' D:\code\VB>cscript Get-SymantecDefinitionDate.vbs /s:192.168.9.2
' Microsoft (R) Windows Script Host Version 5.8
' Copyright (C) Microsoft Corporation. All rights reserved.
'
' Host: 192.168.9.2 SEP AV Pattern File Date: 2017-03-30 Revision: 19
'
' Errors:
' Since remote registry access requires admin privileges (local/domain), failure
' will result in VBScript error:  SWbemLocator: Access is denied.
'
' Reg Keys for Definition date: 
' SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\AV\
' PatternFileDate       REG_BINARY    2f 02 1e 00 00 00 00 00
' PatternFileRevision   REG_DWORD     0x00000019
' 
' Reg Keys for SEP Version: 
' SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion\
' PRODUCTVERSION        REG_SZ        12.1.4112.4156
'===========================================================================
strScriptHost = LCase(Wscript.FullName)
If Right(strScriptHost, 11) = "wscript.exe" Then
    Wscript.Echo WScript.ScriptName & " should run only under cscript. Exiting..."
    Wscript.Quit
End If

'===========================================================================
' Check Commandline argument for query to a remote target host / IP
'===========================================================================
If WScript.Arguments.Named.Exists("S") Then
   '========================================================================
   ' Set the host, privileged user and password for remote registry access
   '========================================================================
   strComputer=UCase(WScript.Arguments.Named.Item("S"))
   '========================================================================
   ' Here we set a remote local admin. Alternatively, set "DOMAIN\adminname"
   '========================================================================
   strUser = strComputer & "\Administrator"
   strPassword = "password"
   '========================================================================
   ' Try to access the remote system with the credentials above
   '========================================================================
   Set objWbemLocator = CreateObject("WbemScripting.SWbemLocator")
   Set objWMIService = objwbemLocator.ConnectServer(strComputer, strNamespace, strUser, strPassword)
Else
   '========================================================================
   ' No host given, we only query the local system using current local user
   '========================================================================
   strComputer = "127.0.0.1"
End If

strNamespace = "\root\default:StdRegProv"

const HKEY_LOCAL_MACHINE = &H80000002
Set StdOut = WScript.StdOut
Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" _ 
    & strComputer & strNamespace)
    
Dim objReg
Dim dateValue
strKeyPath = "SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\AV"
strValName = "PatternFileDate"
Ret = objReg.GetBinaryValue(HKEY_LOCAL_MACHINE, strKeyPath, strValName, dateValue)

'===========================================================================
' Check if we got a return value. If the keypath / keyname is wrong, nothing
' is returned for dateValue, and the subsequent binary conversion fails.
'===========================================================================
If Ret = 0 AND isArray(dateValue) Then

   '========================================================================
   ' PatternFileDate data example: REG_BINARY 2f 02 1e 00 00 00 00 00
   ' Only the first 3 bytes contain the date: year, month, day
   ' Year is counted from 1970 (epoch). Month starts from 0 instead of 1.
   '========================================================================
   ' 0x2f = 47 decimal = 1970 + 47 = 2017
   pattern_year = 1970 + dateValue(0)
   ' 0x02 =  2 decimal = 1 + 2 = 3 (March)
   pattern_mon  = 1 + dateValue(1)
   ' add a leading zero if month < 10
   If pattern_mon < 10 Then pattern_mon = "0" & pattern_mon
   ' 0x1e = 30 decimal = 30 (day of month)
   pattern_day  = dateValue(2)
   ' add a leading zero if day < 10
   If pattern_day < 10 Then pattern_day = "0" & pattern_day
   
Else
   WScript.Echo "Cannot Read: HKLM\" & strKeyPath & "\" & strValName _
                & " Error: " & Err.Number
   WScript.Quit
End If

Dim revValue
strKeyPath = "SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\AV"   
strValName = "PatternFileRevision"
Ret = objReg.GetDWORDValue(HKEY_LOCAL_MACHINE, strKeyPath, strValName, revValue)

'===========================================================================
' Check if the registry key exists and if we got a return value. 
'===========================================================================
If Ret = 0 Then
   revision = revValue 
Else
   WScript.Echo "Cannot Read: HKLM\" & strKeyPath & "\" & strValName _
                & " Error: " & Err.Number
   WScript.Quit
End If

'===========================================================================
' Output the Symantec AV pattern file date and revision
'===========================================================================
WScript.Echo "Host: " & strComputer & " Symantec Endpoint Protection AV Pattern File Date: " _
             & pattern_year & "-" & pattern_mon & "-" & pattern_day & " Revision: " & revision

WScript.Quit