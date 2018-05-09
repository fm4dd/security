'===========================================================================
' 20180418 frank4dd: VBS script to extract Windows patch list into CSV format
' 20180509 frank4dd: sort output by installation date
'
' https://msdn.microsoft.com/en-us/library/aa394391(v=vs.85).aspx
' This script queries the Win32_QuickFixEngineering class, which
' returns the QFE updates supplied by Component Based Servicing (CBS). 
'
' on a CMD prompt, type: cscript list-patches.vbs > patchlist.csv
'
' D:\04 VM local\VM Shared\code\VB>cscript list-patches.vbs
' Microsoft (R) Windows Script Host Version 5.8
' Copyright (C) Microsoft Corporation. All rights reserved.
'
' Running list-patches.vbs
' ===================================================================
'Installation Date, Computer, Description, Hot Fix ID, Installed By:
' 2018/04/20,PCAH86899,KB3138612,Update,NT AUTHORITY\SYSTEM
' ...
' 2018/05/08,PCAH86899,KB4093118,Security Update,NT AUTHORITY\SYSTEM
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
Dim fso, stdout, stderr, localPath

'===========================================================================
' Create the file handles: stdout, stderr and the CSV file for the results.
'===========================================================================
Set fso    = CreateObject("Scripting.FileSystemObject")
Set stdout = fso.GetStandardStream (1)
Set stderr = fso.GetStandardStream (2)
localPath  = left(WScript.ScriptFullName,_
             (Len(WScript.ScriptFullName))-(len(WScript.ScriptName)))
             
'===========================================================================
' Create a disconnected recordset for sorting the resultset by date.
' Field size definition matches Win32_QuickFixEngineering class properties.
' DataList.Fields.Append Name, Type, DefinedSize, Attrib, Value
' For Type, string = 200 (adVarChar), see DataTypeEnum
' Type Date = 7 (adDate)
'===========================================================================
SET DataList = CreateObject("ADOR.Recordset")
DataList.Fields.Append "CSName", 200, 256         ' string, MaxLen 256
DataList.Fields.Append "Description", 200, 255    ' string
DataList.Fields.Append "HotFixID", 200, 260       ' string, MaxLen 260
DataList.Fields.Append "InstalledOn", 7           ' date, needs conversion
DataList.Fields.Append "InstalledBy", 200, 255    ' string
DataList.Open

'===========================================================================
' Start Console and file output: Create the CSV output
'===========================================================================
stdout.WriteLine "Running " & WScript.ScriptName
stdout.WriteLine "==================================================================="

strComputer = "." 
Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 

'===========================================================================
' Do the data query
'=========================================================================== 
Set colQuickFixes = objWMIService.ExecQuery _ 
    ("Select * from Win32_QuickFixEngineering")

'===========================================================================
' Feed query result into the data set
'===========================================================================   
For Each qf in colQuickFixes
   DataList.AddNew
   DataList("CSName")      = qf.CSName
   DataList("Description") = qf.Description
   DataList("HotFixID")    = qf.HotFixID
   DataList("InstalledOn") = CDate(qf.InstalledOn)
   DataList("InstalledBy") = qf.InstalledBy
   DataList.Update
Next

'===========================================================================
' sort the data set by sort criteria
'===========================================================================
DataList.Sort = "InstalledOn"
DataList.MoveFirst


'===========================================================================
' output the (sorted) dataset
'                   & DataList.Fields.Item("Description") & "," _
'===========================================================================
stdout.WriteLine "Installation Date, Computer, HotFix ID, Description, Installed By:"

Do While DataList.EOF = FALSE
    stdout.WriteLine DataList.Fields.Item("InstalledOn") & "," _ 
                   & DataList.Fields.Item("CSName") & "," _
                   & DataList.Fields.Item("HotFixID") & "," _
                   & DataList.Fields.Item("Description") & "," _
                   & DataList.Fields.Item("InstalledBy")
   DataList.MoveNext
Loop

stdout.WriteLine "==================================================================="
stdout.Close
stderr.Close

'===========================================================================
' End of Main
'===========================================================================
