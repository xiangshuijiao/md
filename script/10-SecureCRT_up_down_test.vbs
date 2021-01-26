# $language = "VBScript"
# $interface = "1.0"

Sub Main

	' Send the unix "date" command and wait for the prompt that indicating 
	' that it completed. In general we want to be in synchronous mode before
	' doing send/wait operations.
	'
	crt.Screen.Synchronous = True

	Dim total
	Dim timeout
	Dim c
	Dim success
  
	' total = 3000
	total = 5000
	c = 0
	timeout = 0
	success = True
	
Do
	If c >= total Then
		crt.Dialog.MessageBox "Test " & total & " times successfully", "Power Switch Test", ICON_INFO Or BUTTON_OK
		Exit Sub
	End If
	
	If success <> True Then
		crt.Dialog.MessageBox "Test Fail, " & c & " times successfully", "Power Switch Test", ICON_INFO Or BUTTON_OK
		Exit Sub
	End If
	
	success = Test()
	
	c = c + 1
Loop

End Sub

Function Test()
	' login
	crt.Screen.WaitForString "tpigmpversionprobe"
	crt.Sleep 3*1000 ' 3 second
	Do
		While True
			crt.Screen.Send( vbCR )
			If crt.Screen.WaitForString( "XC220-G3v login:", 10) <> False Then
				crt.Screen.Send("admin" & vbCR)
				If crt.Screen.WaitForString( "Password:", 10) <> False Then
					crt.Screen.Send("1234" & vbCR)
					Exit Do
				End If
			End If
		Wend
	Loop
	crt.Screen.Send( vbCR )
	crt.Screen.WaitForString("#")
	
	' run command
	crt.Screen.Send("echo 1 > /proc/sys/kernel/core_uses_pid" & vbCR)
	crt.Screen.Send("echo ""/tmp/core-%e-%p-%t"" > /proc/sys/kernel/core_pattern" & vbCR)
	crt.Screen.Send("ulimit -c unlimited" & vbCR)
	crt.Screen.Send("ulimit -a" & vbCR)

	' ping test 
	REM crt.Sleep 3*1000
	REM crt.Screen.Send("ping 192.168.1.100" & vbCR)
	REM If crt.Screen.WaitForString("time=", 10*60) <> True Then
		REM Test = False
		REM Exit Function
	REM End If
	REM crt.Screen.SendKeys("^C")
	REM crt.Screen.Send( vbCR )
	REM crt.Screen.WaitForString("#")
	
	' check if the process exists
	crt.Sleep 3*60*1000 ' 3min
	crt.Screen.Send("ps -T" & vbCR)
	If crt.Screen.WaitForString("cos", 20) <> True Then
		Test = False
		Exit Function
	End If
	crt.Sleep 3*1000
	crt.Screen.Send("ps -T" & vbCR)
	If crt.Screen.WaitForString("httpd", 20) <> True Then
		Test = False
		Exit Function
	End If
	crt.Sleep 3*1000
	crt.Screen.Send("ps -T" & vbCR)
	If crt.Screen.WaitForString("dnsProxy", 20) <> True Then
		Test = False
		Exit Function
	End If
	
	
	crt.Screen.Send("reboot" & vbCR)
	 
	Test=True
End Function
