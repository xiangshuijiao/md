VarSetCapacity(APPBARDATA, A_PtrSize=4 ? 36:48) ; 这行代码必须放第一行，用于#b隐藏显示任务栏
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode 2   
global FPRINTF_FILE_PATH = "/tmp/1.txt" ; 默认fprintf会写入的路径，可以用NumberEnter+c修改这个值
global JKN_FLAGS = "jkn1"
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;左Shift强制切换到英文输入法，
;右Shift强制切换到中文输入法，
;		仅适用于win10,win7请参考如下链接
;		参考链接：https://www.zhihu.com/question/41446565
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	#IfWinActive
	; 左Shift强制切换到英文输入法，右Shift强制切换到中文输入法
	#SingleInstance force
	#UseHook
	#Include %A_ScriptDir%

	timeInterval := 500

	; 英文模式
	~LShift:: 
	return
	~LShift up::

		if (A_TimeSincePriorHotkey < timeInterval && A_Priorkey = "LShift") {
			if ( GetKeyState("CapsLock", "T") ) {
				SetCapsLockState,Off
			}
			
			if ( WinExist("ahk_class SoPY_Comp") ) {
				Send {Enter}
			}
			
			IME_SET(0)
		}
		
	return

	; 切换到搜狗输入法，设置中文模式
	~$RShift:: 
	return
	~$RShift up:: 


		if ( A_TimeSincePriorHotkey < timeInterval && A_Priorkey = "RShift" ) {
			if ( GetKeyState("CapsLock", "T") ) {
				SetCapsLockState,Off
			}
			
			;send ^{Space} ;这里发送下 ctrl space，利用搜狗再做一次切换，解决一些软件下无法切换到中文
			IME_SET(1)
		}

	return

	;--
	; 以下都是参考链接中的文件IME.ahk中的全部内容,全都是函数定义。
	;--

	GetGUIThreadInfo_hwndActive(WinTitle="A")
	{
		ControlGet, hwnd, HWND,,, %WinTitle%
		if (WinActive(WinTitle)) {
			ptrSize := !A_PtrSize ? 4 : A_PtrSize
			VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
			NumPut(cbSize, stGTI,  0, "UInt")
			return hwnd := DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", &stGTI)
					 ? NumGet(stGTI, 8+PtrSize, "Ptr") : hwnd
		}
		else {
			return hwnd
		}
	}
	;--
	; IME状态的获取
	;  WinTitle="A"    対象Window
	;  返回值          1:ON / 0:OFF
	;--
	IME_GET(WinTitle="A")  {
		hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
		return DllCall("SendMessage"
			  , Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr,hwnd)
			  , UInt, 0x0283  ;Message : WM_IME_CONTROL
			  , UPtr, 0x005   ;wParam  : IMC_GETOPENSTATUS
			  ,  Ptr, 0)      ;lParam  : 0
	}

	;--
	; IME状态的设置
	;   SetSts          1:ON / 0:OFF
	;   WinTitle="A"    対象Window
	;   返回值          0:成功 / 0以外:失败
	;--
	IME_SET(SetSts, WinTitle="A")    {
		hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
		return DllCall("SendMessage"
			  , Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr, hwnd)
			  , UInt, 0x0283  ;Message : WM_IME_CONTROL
			  , UPtr, 0x006   ;wParam  : IMC_SETOPENSTATUS
			  ,  Ptr, SetSts) ;lParam  : 0 or 1
	}

	;==
	;    0000xxxx    假名输入
	;    0001xxxx    罗马字输入方式
	;    xxxx0xxx    半角
	;    xxxx1xxx    全角
	;    xxxxx000    英数
	;    xxxxx001    平假名
	;    xxxxx011    片假名

	; IME输入模式(所有IME共有)
	;   DEC  HEX    BIN
	;     0 (0x00  0000 0000)  假名   半英数
	;     3 (0x03  0000 0011)         半假名
	;     8 (0x08  0000 1000)         全英数
	;     9 (0x09  0000 1001)         全字母数字
	;    11 (0x0B  0000 1011)         全片假名
	;    16 (0x10  0001 0000)   罗马字半英数
	;    19 (0x13  0001 0011)         半假名
	;    24 (0x18  0001 1000)         全英数
	;    25 (0x19  0001 1001)         平假名
	;    27 (0x1B  0001 1011)         全片假名

	;  ※ 区域和语言选项 - [详细信息] - 高级设置
	;     - 将高级文字服务支持应用于所有程序
	;    当打开时似乎无法获取该值
	;    (谷歌日语输入β必须在此打开，所以无法获得值)

	;--
	; 获取IME输入模式
	;   WinTitle="A"    対象Window
	;   返回值          输入模式
	;--

	; 测试时 win10 x64 自带输入法 中文返回 1, 英文返回 0.
	; win7 x32
	; 中文简体 美式键盘  返回 0。
	; 
	;               QQ拼音输入法中文输入模式   QQ拼音英文输入模式     搜狗输入法中文      搜狗输入法英文
	; 半角+中文标点        1025                                        268436481(1025)
	; 半角+英文标点           1　                    1024              268435457(1)        268435456(0)
	; 全角+中文标点        1033                                        268436489(1033)
	; 全角+英文标点           9                      1032              268435465(9)        268435464(8)

	;                智能ABC中文输入标准模式    智能ABC中文输入双打模式    智能ABC英文标准   智能ABC英文双打
	; 半角+中文标点        1025                   -2147482623(1025)          1024               -2147482624
	; 半角+英文标点           1                   -2147483647(1)                0               -2147483648
	; 全角+中文标点        1033                   -2147482615(1033)          1032               -2147482616
	; 全角+英文标点           9                   -2147483639(9)                8               -2147483640


	IME_GetConvMode(WinTitle="A")   {
		hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
		return DllCall("SendMessage"
			  , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
			  , "UInt", 0x0283  ;Message : WM_IME_CONTROL
			  ,  "Int", 0x001   ;wParam  : IMC_GETCONVERSIONMODE
			  ,  "Int", 0) & 0xffff     ;lParam  : 0 ， & 0xffff 表示只取低16位
	}

	;--
	; IME输入模式设置
	;   ConvMode        输入模式
	;   WinTitle="A"    対象Window
	;   返回值          0:成功 / 0以外:失败
	;--
	IME_SetConvMode(ConvMode, WinTitle="A")   {
		hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
		return DllCall("SendMessage"
			  , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
			  , "UInt", 0x0283      ;Message : WM_IME_CONTROL
			  , "UPtr", 0x002       ;wParam  : IMC_SETCONVERSIONMODE
			  ,  "Ptr", ConvMode)   ;lParam  : CONVERSIONMODE
	}
}

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;左ctrl + 左shift 输出中文标点,
;		unicode查询：http://tool.chinaz.com/tools/unicode.aspx
;		http://ahkcn.sourceforge.net/docs/Hotstrings.htm
;
;双击 ,.\; 替换为对应的中文标点
;		注意：仅在中文输入状态下生效
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	#IfWinActive
	; （）
	$<^<+9::
		keywait +
		send {U+ff08}
		;send {U+ff09}{left 1}
	return
	$<^<+0::
		keywait +
		send {U+ff09}
	return

	;【】
	$<^<+[::
		keywait +
		send {U+3010}
		;send {U+3011}{left 1}
	return
	$<^<+]::
		keywait +
		send {U+3011}
	return

	; “”
	$<^<+'::
		keywait +
		send {U+201c}
		;send {U+201d}{left 1}
	return

	; ！
	$<^<+!::
		keywait +
		send {U+ff01}
	return

	; ：
	$<^<+;::
		keywait +
		send {U+ff1a}
	return

	; ？
	$<^<+/::
		keywait +
		send {U+ff1f}
	return

	; ，
	$<^<+,::
		keywait +
		send {U+ff0c}
	return

	; 。
	$<^<+.::
		keywait +
		send {U+3002}
	return

	; 、
	$<^<+\::
		keywait +
		send {U+3001}
	return

/*
	#IfWinNotExist ahk_class SoPY_Comp
	:z0*?:,,::
		ime_s := IME_GET()
		if (ime_s = 1) {
			send {U+ff0c}
		}
	return

	:z0*?:..::
		ime_s := IME_GET()
		if (ime_s = 1) {
			send {U+3002}
		}
	return

	:z0*?:\\::
		ime_s := IME_GET()
		if (ime_s = 1) {
			send {U+3001}
		}
	return

	:b1z0*?:;;::
		ime_s := IME_GET()
		if (ime_s = 1) {
			send {U+ff1b}
		}
	return
	#IfWinNotExist
*/
}

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;`+h：代替ctrl+Home返回文档首页
;`+q：代替alt+F4关闭软件
;`+y：有道词典鼠标取词开关
;`+2、3：最大化最小化窗口
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	
	#IfWinActive
	$`::Send, `` ; 发送模拟按键 `，第一个`是转义字符的前缀，第二个`表示转义字符本身
	$~::Send, ~
	
	` & a::
	` & b::
	` & c::
	` & d::
	` & e::
	` & f::
	` & g::
	` & i::
	` & j::
	` & k::
	` & l::
	` & m::
	` & n::
	` & o::
	` & p::
	` & r::
	` & s::
	` & t::
	` & u::
	` & v::
	` & w::
	` & x::
	` & z::
		return
	
	` & h::Send, ^{Home}
	` & q::Send, !{F4}
	` & y::Send, !+y
	

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;		`+2、3最大化最小化窗口
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	#IfWinActive
	;缩小窗口函数
	min(array)
		{
		WinGet, active_id, id, A ;获取当前窗口id
		WinGetClass, active_ahk_class, A ;获取当前窗口类
		if active_ahk_class = Progman ;判断是否桌面
			{
			return array ;返回数组
			}
		array[Nub] += 1 ;索引加1
		Nu := array[Nub] ;临时赋值
		array[Nu] := active_id 
		WinMinimize, ahk_id %active_id% ;缩小当前窗口
		return array ;返回数组
		}
	;放大窗口函数
	max(array)
		{
		Nu := array[Nub]
		loop 15
		{
		active_id := array[Nu]
		IfWinExist, ahk_id %active_id%
			{
			WinMaximize, ahk_id %active_id%
			Nu -= 1
			Break
			}
		Else
			{
			if Nu = 0
				Break
			Else
				Nu -= 1
			}
		}
	array[Nub] := Nu
	return array
	}
	;初始化
	array := Object()
	array[Nub] := 0
	

	;` & 2::array := max(array) ;放大
	` & 2::Send, !{Space}x ;alt+2代替alt+空格+x，最大化当前窗口
	` & 3::array := min(array) ;最小
*/
}

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;F1+字母：打开、激活、或隐藏软件
;F1+数字：
;		替换win+数字切换到任务栏软件
;		按键` 这里作为修饰键，和alt、shift、win、ctrl一样，要先按着不动然后再按另一个键1才能触发`
;		参考：https://wyagd001.github.io/zh-cn/docs/KeyList.htm
;		注意：
;			如果在Snipaste、everything等部分软件中不生效，
;			肯定是因为没有用管理员权限运行autohotkey脚本，
;			找到AutoHotkey.exe，右键->属性->默认管理员权限运行即可
;`+F1：输入F1
;		参考：https://www.cnblogs.com/hyaray/p/6660301.html    
;		titleClass参数可以用autohotkey软件自带的工具Window Spy进行确认
;^+z：everything
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	#IfWinActive
	;$F1::Send, {F1}
	` & F1::Send, {F1}
	
	#MaxThreadsPerHotkey 5
	F1 & a::
	F1 & d::
	F1 & f::
	F1 & g::
	F1 & h::
	F1 & i::
	F1 & j::
	F1 & k::
	F1 & l::
	F1 & m::
	
	F1 & q::
	F1 & r::
	F1 & u::
	F1 & v::
	F1 & y::
	F1 & z::
		return
	F1 & c::hyf_onekeyWindow("D:\3-big-software\7-chrome\Chrome\App\chrome.exe", "Chrome_WidgetWin_1", "\S") ;Chrome
	F1 & s::hyf_onekeyWindow("C:\Program Files (x86)\Source Insight 4.0\sourceinsight4.exe", "si4_Frame", "\S") ;Source Insight 4.0
	F1 & x::hyf_onekeyWindow("D:\3-big-software\20-Xmind\XMind2020\XMind.exe", "Chrome_WidgetWin_1", "\S") ;XMind
	F1 & t::hyf_onekeyWindow("C:\Program Files\Typora\Typora.exe", "Chrome_WidgetWin_1", "\S") ;Typora
	F1 & n::hyf_onekeyWindow("C:\Program Files\Notepad++\notepad++.exe", "Notepad++", "\S") ;Notepad++ 
	F1 & b::hyf_onekeyWindow("C:\Program Files\Beyond Compare 4\BCompare.exe", "TViewForm", "\S") ;Beyond Compare 4
	F1 & w::hyf_onekeyWindow("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\wps.exe", "OpusApp", "\S") ;wps
	F1 & e::hyf_onekeyWindow("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\et.exe", "XLMAIN", "\S") ;excel
	;F1 & p::hyf_onekeyWindow("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\wpp.exe", "PP11FrameClass", "\S") ;ppt
	F1 & p::hyf_onekeyWindow("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\wpspdf.exe", "QWidget", "\S") ;pdf
	F1 & o::hyf_onekeyWindow("C:\Program Files\Microsoft Office\Office16\OUTLOOK.EXE", "rctrl_renwnd32", "\S") ;outlook
	
	^+z::only_for_everything() ;everything
	
	
	#a:: ;显示所有WinHide和!WinActive的窗口
		show_specific_hide_software("D:\3-big-software\7-chrome\Chrome\App\chrome.exe", "Chrome_WidgetWin_1", "\S", "chrome.exe") ;Chrome
		show_specific_hide_software("C:\Program Files (x86)\Source Insight 4.0\sourceinsight4.exe", "si4_Frame", "\S", "sourceinsight4.exe") ;Source Insight 4.0
		show_specific_hide_software("D:\3-big-software\20-Xmind\XMind2020\XMind.exe", "Chrome_WidgetWin_1", "\S", "XMind.exe") ;XMind
		show_specific_hide_software("C:\Program Files\Typora\Typora.exe", "Chrome_WidgetWin_1", "\S", "Typora.exe") ;Typora
		show_specific_hide_software("C:\Program Files\Notepad++\notepad++.exe", "Notepad++", "\S", "notepad++.exe") ;Notepad++ 
		show_specific_hide_software("C:\Program Files\Beyond Compare 4\BCompare.exe", "TViewForm", "\S", "BCompare.exe") ;Beyond Compare 4	
		show_specific_hide_software("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\wps.exe", "OpusApp", "\S", "wps.exe") ;wps
		show_specific_hide_software("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\et.exe", "XLMAIN", "\S", "et.exe") ;excel
		;show_specific_hide_software("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\wpp.exe", "PP11FrameClass", "\S", "wpp.exe") ;ppt
		show_specific_hide_software("D:\3-big-software\23-wps\WPSOffice2019.11.8.2.8875_Green\WPS Office 2019\office6\wpspdf.exe", "QWidget", "\S", "wpspdf.exe") ;pdf
		show_specific_hide_software("C:\Program Files\Microsoft Office\Office16\OUTLOOK.EXE", "rctrl_renwnd32", "\S", "OUTLOOK.EXE") ;outlook
	return
	
	F1 & 1::send_win_number_and_winMaximize("#1")	; ~表示触发热键时, 热键中按键原有的功能不会被屏蔽
	F1 & 2::send_win_number_and_winMaximize("#2")
	F1 & 3::send_win_number_and_winMaximize("#3")
	F1 & 4::send_win_number_and_winMaximize("#4")
	F1 & 5::send_win_number_and_winMaximize("#5")
	F1 & 6::send_win_number_and_winMaximize("#6")
	F1 & 7::send_win_number_and_winMaximize("#7")
	F1 & 8::send_win_number_and_winMaximize("#8")
	F1 & 9::send_win_number_and_winMaximize("#9")
	F1 & 0::send_win_number_and_winMaximize("#0")

	
	hyf_onekeyWindow(exePath, titleClass := "", titleReg := "")
	{ ;有些窗口用Ahk_exe exeName判断不准确，所以自定义个titleClass
		SplitPath, exePath, exeName, , , noExt
		If !hyf_processExist(exeName)
		{
			;hyf_tooltip("启动中，请稍等...")
			Run,% exePath
			;打开后自动运行 TODO
			funcName := noExt . "_runDo"
			If IsFunc(funcName)
			{
				;hyf_tooltip("已自动执行函数：" . funcName)
				Func(funcName).Call()
			}
			Else If titleClass
			{
				
				Sleep, 1000 
				
				If titleReg
					titleClass := "Ahk_id " . hyf_getMainIDOfProcess(exeName, titleClass, titleReg)
				Else If titleClass
					titleClass := "Ahk_class " . titleClass
				Else
					titleClass := "Ahk_exe " . exeName
				
				WinWait, %titleClass%, , 1
				WinActivate %titleClass%
				WinMaximize %titleClass%
			}
		}
		Else If WinActive("Ahk_exe " . exeName)
		{
			funcName := noExt . "_hideDo"
			If IsFunc(funcName)
				Func(funcName).Call()
			/*
			; 用WinMinimize解决wps WinHide后桌面留有阴影的问题
			if (exeName == "wps.exe" or exeName == "et.exe" or exeName == "wpp.exe")
			{
				if (0)
				{
					MsgBox, 成功匹配
				}
				WinMinimize	
			}
			*/
			
			; 隐藏所有的窗口
			DetectHiddenWindows, On
			WinGet, arr, List, Ahk_exe %exeName%
			Loop,% arr
			{
				n := arr%A_Index%
				WinGetClass, classLoop, Ahk_id %n%
				;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . cls
				If (classLoop = titleClass)
				{
					If !StrLen(titleReg) ;不需要判断标题
						break
					WinGetTitle, titleLoop, Ahk_id %n%
					;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . titleLoop
					If (titleLoop ~= titleReg)
					{
						WinHide Ahk_id  %n%			
					}
				}
				Continue
			}
			
			
			;WinHide
			;WinMinimize ;用WinMinimize代替winhide，避免两个sourceinsight都被隐藏后无法用快捷键同事调出两个窗口，而且这样还能同时使用快捷键鼠标操作任务栏的已打开的程序。
			;激活鼠标所在窗口 TODO
			MouseGetPos, , , idMouse
			WinActivate Ahk_id %idMouse%
		}
		Else
		{
			; 显示所有的隐藏窗口
			DetectHiddenWindows, On
			WinGet, arr, List, Ahk_exe %exeName%
			Loop,% arr
			{
				n := arr%A_Index%
				WinGetClass, classLoop, Ahk_id %n%
				;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . cls
				If (classLoop = titleClass)
				{
					If !StrLen(titleReg) ;不需要判断标题
						break
					WinGetTitle, titleLoop, Ahk_id %n%
					;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . titleLoop
					If (titleLoop ~= titleReg)
					{
						WinShow Ahk_id  %n%
						WinMaximize Ahk_id  %n%
						WinActivate Ahk_id  %n%					
					}
				}
				Continue
			}
	
			funcName := noExt . "_activeDo"
			If IsFunc(funcName)
			{
				;hyf_tooltip("已自动执行函数：" . funcName)
				Func(funcName).Call()
			}
		}		
		
		/*
		Else
		{
			If titleReg
				titleClass := "Ahk_id " . hyf_getMainIDOfProcess(exeName, titleClass, titleReg)
			Else If titleClass
				titleClass := "Ahk_class " . titleClass
			Else
				titleClass := "Ahk_exe " . exeName
			WinShow %titleClass%
			WinMaximize %titleClass%
			WinActivate %titleClass%
			funcName := noExt . "_activeDo"
			If IsFunc(funcName)
			{
				;hyf_tooltip("已自动执行函数：" . funcName)
				Func(funcName).Call()
			}
		}
		*/
		return
	}
	 
	hyf_processExist(n) ;判断进程是否存在（返回PID）
	{ ;n为进程名
		Process, Exist, %n% ;比IfWinExist可靠
		Return ErrorLevel
	}
	 
	hyf_tooltip(str, t := 1, ExitScript := 0, x := "", y := "")  ;提示t秒并自动消失
	{
		t *= 1000
		ToolTip, %str%, %x%, %y%
		SetTimer, hyf_removeToolTip, -%t%
		If ExitScript
		{
			Gui, Destroy
			Exit
		}
	}
	 
	hyf_getMainIDOfProcess(exeName, cls, titleReg := "") ;获取类似chrome等多进程的主程序ID
	{
		DetectHiddenWindows, On
		WinGet, arr, List, Ahk_exe %exeName%
		Loop,% arr
		{
			n := arr%A_Index%
			WinGetClass, classLoop, Ahk_id %n%
			;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . cls
			If (classLoop = cls)
			{
				If !StrLen(titleReg) ;不需要判断标题
					Return n
				WinGetTitle, titleLoop, Ahk_id %n%
				;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . titleLoop
				If (titleLoop ~= titleReg)
					Return n
			}
			Continue
		}
		Return False
	}
	 
	hyf_removeToolTip() ;清除ToolTip
	{
		ToolTip
	}
	
	;Everything.exe进程
	;不存在则启动，
	;已经active则隐藏
	;存在却未active则发送^+z使用软件Everything内置的显示Everything界面的快捷键。
	only_for_everything()
	{
		If !hyf_processExist("Everything.exe")	or WinActive("Ahk_exe " . "Everything.exe")
		{
			hyf_onekeyWindow("D:\Documents\4-Green Softwore\everything\Everything.exe", "EVERYTHING", "\S")
		}
		Else
		{
			Send, ^+z
			WinActivate, A
			WinMaximize, A
		}
		return
	}
	
	show_specific_hide_software(exePath, titleClass, titleReg, exeName)
	{		
		if (0)
		{
			If hyf_processExist(exeName)
				MsgBox, hyf_processExist(exeName)=1
			If !WinActive("Ahk_exe  " . exeName)
				MsgBox, !WinActive("Ahk_exe  " . exeName)=1
		}
		
		If hyf_processExist(exeName) and !WinActive("Ahk_exe  " . exeName)
		{
			hyf_onekeyWindow(exePath, titleClass, titleReg)	
		}
		return
	}
	
	;发送win+数字切换程序并进行最大化
	send_win_number_and_winMaximize(send_key, ahk_exe_value="")
	{
		SendInput % send_key
		
		sleep 100
		WinGet, active_id, id, A ;获取当前窗口id
		WinMaximize, ahk_id %active_id% ;缩小当前窗口
		;WinMaximize, % ahk_exe_value
	}
	
	
	; 按键次数决定要执行的操作
	; 参考链接：https://www.autohotkey.com/boards/viewtopic.php?t=4286
	; 全局变量、静态变量、局部变量：https://segmentfault.com/a/1190000005107934
	global x1 := "", x2 := "", x3 := "", x4 := "", x5 := "", x6 := "", x7 := "", x8 := "", x9 := ""
	global intCount = 0
	global operation_type = 0 ; 1：打开激活隐藏软件，2：常用字符串
	different_key_times_different_operation(v0 := 0, v1 := "", v2 := "", v3 := "", v4 := "" ;以逗号或任何其他表达式运算符(除了 ++ 和 --) 开头的行会自动与其正上方的行合并.
											, v5 := "", v6 := "", v7 := "", v8 := "", v9 := "")
	{
		; 变量何时使用%%，何时不用%%：https://wyagd001.github.io/zh-cn/docs/Variables.htm
		operation_type = %v0%
		x1 = %v1%
		x2 = %v2%
		x3 = %v3%
		x4 = %v4%
		x5 = %v5%
		x6 = %v6%
		x7 = %v7%
		x8 = %v8%
		x9 = %v9%
		if (intCount > 0) 
		{
			intCount += 1
			return
		}

		intCount = 1
		SetTimer, KeyWinC, 200 
		return
	}
	KeyWinC:
		SetTimer, KeyWinC, off 
		;/*
		if (operation_type = 1) ; 1：打开激活隐藏软件
		{
			if (intCount = 1) 
				hyf_onekeyWindow(x1, x2, x3)
			else if (intCount = 2) 
				hyf_onekeyWindow(x4, x5, x6)
			else if (intCount = 3)
				hyf_onekeyWindow(x7, x8, x9)
		}
		else if (operation_type = 2) ; 2：win加数字切换任务栏程序
		{
			if (intCount = 1) 
				Send, %x1%
			else if (intCount = 2) 
				Send, %x2%
		}
		;*/
		
		if (0)
			MsgBox, intCount=%intCount%
		intCount = 0
	return

}

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;NumpadEnter+字母、数字：常用字符串
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	#IfWinActive
	$NumpadEnter::NumpadEnter      

	NumpadEnter & 2::
	
	NumpadEnter & 4::
	NumpadEnter & 5::
	NumpadEnter & 6::
	NumpadEnter & 7::
	NumpadEnter & 8::
	NumpadEnter & 9::
	NumpadEnter & 0::
	NumpadEnter & b::
	NumpadEnter & d::
	NumpadEnter & e::
	
	NumpadEnter & g::
	NumpadEnter & h::
	NumpadEnter & i::
	NumpadEnter & k::
	NumpadEnter & l::
	NumpadEnter & m::
	NumpadEnter & n::
	NumpadEnter & o::
	NumpadEnter & q::
	NumpadEnter & r::
	NumpadEnter & s::
	NumpadEnter & u::
	NumpadEnter & v::
	NumpadEnter & x::
	NumpadEnter & y::
	NumpadEnter & z::
		return
	
	NumpadEnter & 1::function_for_the_NumpadEnter_short_key("1")
	NumpadEnter & j::function_for_the_NumpadEnter_short_key("j")
	NumpadEnter & a::function_for_the_NumpadEnter_short_key("a")
	NumpadEnter & p::function_for_the_NumpadEnter_short_key("p")
	NumpadEnter & t::function_for_the_NumpadEnter_short_key("t")
	NumpadEnter & c::function_for_the_NumpadEnter_short_key("c")
	NumpadEnter & f::function_for_the_NumpadEnter_short_key("f")
	NumpadEnter & 3::function_for_the_NumpadEnter_short_key("3")
	NumpadEnter & ?::function_for_the_NumpadEnter_short_key("?") ;给出帮助信息
	NumpadEnter & NumpadDel::function_for_the_NumpadEnter_short_key("NumpadDel")
	NumpadEnter & NumpadDot::function_for_the_NumpadEnter_short_key("NumpadDot")
	


	function_for_the_NumpadEnter_short_key(short_key)
	{
		; 将输入法切换为英文，取消大小写锁定
		if ( GetKeyState("CapsLock", "T") ) {
			SetCapsLockState,Off
		}
		if ( WinExist("ahk_class SoPY_Comp") ) {
			Send {Enter}
		}
		IME_SET(0)	

		; 变量何时使用%%，何时不用%%：https://wyagd001.github.io/zh-cn/docs/Variables.htm
		if(short_key = "1")
			Send, 12345670`n
		else if(short_key = "3")
			Send, \\PC3.jkn\bba
		else if(short_key = "j")
			different_key_times_different_operation(2, "Jkn12345`n", "Jkn12345`tJkn12345`n")
		else if(short_key = "a")
			Send, admin`n1234`n
		else if(short_key = "p")
			Send, `nprintf(`"\n%JKN_FLAGS% [`%s][`%d] \n`", __FUNCTION__, __LINE__);  ; 特殊字符、转义字符https://ahkcn.github.io/docs/commands/_EscapeChar.htm
		else if(short_key = "f")
			Send, `nFILE* fp_jkn = fopen(`"%FPRINTF_FILE_PATH%`", "a{+}"); fprintf(fp_jkn, `"\n%JKN_FLAGS% [`%s][`%d] \n`", __FUNCTION__, __LINE__); fclose(fp_jkn);  ; 特殊字符、转义字符https://ahkcn.github.io/docs/commands/_EscapeChar.htm
		else if(short_key = "t")
			Send, tftp -i 192.168.1.1 put{Space}{Space}  
		else if(short_key = "?")
			MsgBox "
(

【1】12345670
【3】\\PC3.jkn\bba
【j】Jkn12345
【a】admin 1234
【p】printf
【f】fprintf
【t】tftp -i 192.168.1.1 put{Space}{Space}
【.b1】\\pc3.jkn\bba\docker1\BBA_2_5_Platform_BCM\platform\targets\EX221-G2uV1\THSP\image
【.b2】\\pc3.jkn\bba\docker2\BBA_2_5_Platform_BCM\platform\targets\EX221-G2uV1\THSP\image
【.p1】\\pc3.jkn\bba\docker1\PON_trunk_bba_2_5\EN7528DU_SDK\tplink\output\XC220G3vv1\image
【.p2】\\pc3.jkn\bba\docker2\PON_trunk_bba_2_5\EN7528DU_SDK\tplink\output\XC220G3vv1\image
【.ab】ab1127586911
【.y0】Y0nN1uWqDCsi
【.ji】jiangkainan@tp-link.com.cn
【.git】git grep -n -I  ""{left 1}
【.t1】tail -n 100 /tmp/jkn.script.PON_trunk_bba_2_5.feature_XC220_mesh.log`n
【.t2】tail -n 100 /tmp/jkn.script.PON_trunk_bba_2_5.linux_XC220-G3v_v1.log`n
【.t3】tail -n 100 /tmp/jkn.script.BBA_2_5_Platform_BCM.EX220_USSP_v1.2.log`n

)"  
; 注意：括号前后各一个折行也会显示出来所以是必不可少的，不加则显示会有问题
		else if (short_key = "NumpadDel" or short_key = "NumpadDot")
		{
			; InputBox, UserInput
			Input, UserInput, T4 L5, {Space}{NumpadEnter} ; 4秒无输出则超时，最长接受5字符输入，输入以空格或者小键盘的enter结尾
			; 下面是路径
			if (UserInput = "b1")
				Send, \\pc3.jkn\bba\docker1\BBA_2_5_Platform_BCM\platform\targets\EX221-G2uV1\THSP\image
			else if (UserInput = "b2")
				Send, \\pc3.jkn\bba\docker2\BBA_2_5_Platform_BCM\platform\targets\EX221-G2uV1\THSP\image
			else if (UserInput = "p1")
				Send, \\pc3.jkn\bba\docker1\PON_trunk_bba_2_5\EN7528DU_SDK\tplink\output\XC220G3vv1\image
			else if (UserInput = "p2")
				Send, \\pc3.jkn\bba\docker2\PON_trunk_bba_2_5\EN7528DU_SDK\tplink\output\XC220G3vv1\image
			; 下面是账号密码
			else if (UserInput = "ab")
				Send, ab1127586911
			else if (UserInput = "y0")
				Send, Y0nN1uWqDCsi
			else if (UserInput = "ji")
				Send, jiangkainan@tp-link.com.cn
			else if (UserInput = "git")
				Send, git grep -n -I  ""{left 1}
			else if (UserInput = "t1")
				Send, tail -n 100 /tmp/jkn.script.PON_trunk_bba_2_5.feature_XC220_mesh.log`n
			else if (UserInput = "t2")
				Send, tail -n 100 /tmp/jkn.script.PON_trunk_bba_2_5.linux_XC220-G3v_v1.log`n
			else if (UserInput = "t3")
				Send, tail -n 100 /tmp/jkn.script.BBA_2_5_Platform_BCM.EX220_USSP_v1.2.log`n
		}
		return
	}
}


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;NumpadSub 修改全局变量的值
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	#IfWinActive
	$NumpadSub::NumpadSub      
	
	NumpadSub & 1::
	NumpadSub & a::
	NumpadSub & p::
	NumpadSub & t::
	NumpadSub & c::
	
	NumpadSub & 2::
	NumpadSub & 3::
	NumpadSub & 4::
	NumpadSub & 5::
	NumpadSub & 6::
	NumpadSub & 7::
	NumpadSub & 8::
	NumpadSub & 9::
	NumpadSub & 0::
	NumpadSub & b::
	NumpadSub & d::
	NumpadSub & e::
	NumpadSub & g::
	NumpadSub & h::
	NumpadSub & i::
	NumpadSub & k::
	NumpadSub & l::
	NumpadSub & m::
	NumpadSub & n::
	NumpadSub & o::
	NumpadSub & q::
	NumpadSub & r::
	NumpadSub & s::
	NumpadSub & u::
	NumpadSub & v::
	NumpadSub & x::
	NumpadSub & y::
	NumpadSub & z::
		return
		
	NumpadSub & f::function_for_the_NumpadSub_short_key("f")
	NumpadSub & j::function_for_the_NumpadSub_short_key("j")
	NumpadSub & ?::function_for_the_NumpadSub_short_key("?")
	
	function_for_the_NumpadSub_short_key(short_key)	
	{
		; 将输入法切换为英文，取消大小写锁定
		if ( GetKeyState("CapsLock", "T") ) {
			SetCapsLockState,Off
		}
		if ( WinExist("ahk_class SoPY_Comp") ) {
			Send {Enter}
		}
		IME_SET(0)	

		if(short_key = "?")
		{
			MsgBox "
(

【f】FPRINTF_FILE_PATH
【j】JKN_FLAGS

)"  
; 注意：括号前后各一个折行也会显示出来所以是必不可少的，不加则显示会有问题
			return
		}
		
		; 变量何时使用%%，何时不用%%：https://wyagd001.github.io/zh-cn/docs/Variables.htm
		InputBox, UserInput
		if(short_key = "f")
			FPRINTF_FILE_PATH = %UserInput%
		else if(short_key = "j")
			JKN_FLAGS = %UserInput%
		return
	}
}

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Win+F1，每隔1s鼠标左键单击一次，再次按则取消
;Win+F2，每隔1s鼠标左键双击一次，再次按则取消
;Win+F3，取消所有的单击和双击
;Win+F9：显示器切换为DP输入 
;Win+F10：显示器切换为HDMI输入 
;		仅适用于DELL U2417H显示器
;		代码中/1为显示器的序号，DP与HDMI为指定的输入源
;Win+F12：只关闭屏幕，不sleep也不休眠
;Win+Shift+F12：Lock and sleep
;win+h：显示、隐藏桌面图标和任务栏
;win+t：窗口置顶, 再按取消
		;取消资源管理器的退格键功能
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	#IfWinActive
	#F1::
	Sending:=!Sending ;每次切换Sending的值为 TRUE/FALSE
	If Sending
	{
	SetTimer SendKey,1000 ;SetTimer是AHK中的定时器
	}
	Else
	SetTimer SendKey,Off
	Return
	SendKey:
	MouseClick, left
	Return

	#F2::
	Sending:=!Sending ;每次切换Sending的值为 TRUE/FALSE
	If Sending
	{
	SetTimer SendDoubleKey,1000 ;SetTimer是AHK中的定时器
	}
	Else
	SetTimer SendDoubleKey,Off
	Return
	SendDoubleKey:
	MouseClick, left
	MouseClick, left
	Return
	
	#F3::
	Sending:=!Sending ;每次切换Sending的值为 TRUE/FALSE
	SetTimer SendDoubleKey,Off
	SetTimer SendDoubleKey,Off
	Return

	;#F9::
	;    Run, "C:\Program Files (x86)\Dell\Dell Display Manager\ddm.exe" /1:SetActiveInput DP
	;Return
	;#F10::
	;    Run, "C:\Program Files (x86)\Dell\Dell Display Manager\ddm.exe" /1:SetActiveInput HDMI   
	;Return


	#IfWinActive
	#F12::
		; 只关闭屏幕，不sleep也不休眠
		SendMessage, 0x112, 0xF170, 2,, Program Manager
		; Sleep/Suspend:
		;DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
		; Hibernate:
		;DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
		Return
	#+F12::
		; Lock:
		Run rundll32.exe user32.dll`,LockWorkStation
		Sleep 1000
		; Sleep/Suspend:
		DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
		; Hibernate:
		;DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
		Return


	;https://blog.csdn.net/liuyukuan/article/details/60867270
	#h::
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	If HWND =
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
	If DllCall("IsWindowVisible", UInt, HWND)
		WinHide, ahk_id %HWND%
	Else
		WinShow, ahk_id %HWND%
	;用于隐藏任务栏
	VarSetCapacity( APPBARDATA, 36, 0 )
	IfWinNotExist, ahk_class Shell_TrayWnd
	{
		NumPut( (ABS_ALWAYSONTOP := 0x2), APPBARDATA, 32, "UInt" )           ;Enable "Always on top" (& disable auto-hide)
		DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
		WinShow ahk_class Shell_TrayWnd
	}
	Else
	{
		NumPut( ( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" )            ;Disable "Always on top" (& enable auto-hide to hide Start button)
		DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
		WinHide ahk_class Shell_TrayWnd
	}
	Return
	
	
	
	#t::winset,ALwaysOnTop,, A ;;A表示当前窗口的标题

	;#IfWinActive ahk_exe explorer.exe
	;BackSpace::
	;return
	
	;https://qastack.cn/superuser/654170/how-to-toggle-the-auto-hide-status-of-the-windows-taskbar
	;VarSetCapacity(APPBARDATA, A_PtrSize=4 ? 36:48) ; 这行代码必须放第一行，用于#b隐藏显示任务栏
	#b::
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 ; ABM_GETSTATE
										   , "Ptr", &APPBARDATA
										   , "Int")
		? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40) ; 2 - ABS_ALWAYSONTOP, 1 - ABS_AUTOHIDE
		, DllCall("Shell32\SHAppBarMessage", "UInt", 10 ; ABM_SETSTATE
										, "Ptr", &APPBARDATA)
	KeyWait, % A_ThisHotkey
	Return
}

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;软件内部快捷键替换
;修改vs快捷键：
;		ctrl&shift&c注释，ctrl&shift&x取消注释，ctrl&k格式化代码
;修改pycharm快捷键：
;		ctrl&shift&c注释，ctrl&shift&x取消注释，ctrl&k格式化代码，F5运行代码，F9调试时跳到光标处
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
	; vs
	#IfWinActive ahk_exe C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe
	{
		^+c::Send, {Ctrl down}k{Ctrl up}{Ctrl down}c{Ctrl up}
		^+x::Send, {Ctrl down}k{Ctrl up}{Ctrl down}u{Ctrl up}
		^k::Send, {Ctrl down}k{Ctrl up}{Ctrl down}f{Ctrl up}
		return
	}

	; pycharm
	#IfWinActive ahk_exe C:\Program Files\JetBrains\PyCharm 2018.2.3\bin\pycharm64.exe
	{
		^+c::Send, {Ctrl down}/{Ctrl up}
		^+x::Send, {Ctrl down}/{Ctrl up}
		^k::Send, ^!l
		F5::Send, ^+{F10}
		F9::Send, !{F9}
		return
	}
	
	; source insight
	#IfWinActive ahk_exe C:\Program Files (x86)\Source Insight 4.0\sourceinsight4.exe
	{
		F8::Send, +{F8}
		F9::Send, +{F9}
		
		; ^+f：在所有文件中搜索的快捷键本来就有
		; F3、F4：往后、往前搜索的快捷键本来就有
		; 下面的快捷键需要自己在sourceinsight中自己设置
		; 		^!+r：项目重命名
		; 		^!+s：更改项目设置
		; 		^!+a：增删文件
		; 		^!+b：Project: Synchronize Files...
		` & r::Send, ^!+r
		` & s::Send, ^!+s
		` & a::Send, ^!+a
		` & b::Send, ^!+b

		return
	}
	
	;notepad 
	#IfWinActive ahk_exe C:\Program Files\Notepad++\notepad++.exe
	{
		; ^!+r	：文件重命名，
		; ^+r	：软件自带的文本替换快捷键
		` & r::Send, ^!+r

		return
	}
	
}


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;鼠标操作：
;		点击关闭按钮执行最小化操作，用Alt+F4来关闭窗口
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

{}


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;另一台电脑运行的脚本备份
;功能：
;		后台静默执行cmd命令并获取输出，执行过程没有黑窗口，关闭NumLock后：
;		数字2、3分别把network2、network3设置为指定的静态IP
;		数字5、6分别把network2、network3设置为dhcp
;		数字8、9弹窗显示network2、network3的IP
;参考链接:
;		AHK获取CMD命令结果三种方法【RunAnyCtrl】 https://www.autohotkey.com/boards/viewtopic.php?t=48132
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{
/*

; AHK获取CMD命令结果三种方法【RunAnyCtrl】 https://www.autohotkey.com/boards/viewtopic.php?t=48132
StdoutToVar_CreateProcess(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0) {
    DllCall( "CreatePipe",           PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1                 )

            VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24,  0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz,      si,  0,                          "UInt" )
    NumPut( 0x100,     si,  (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 60 : 88, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 64 : 96, "Ptr"  )

    If ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
                                  , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
        Return ""
      , DllCall( "CloseHandle", Ptr,hStdOutWr )
      , DllCall( "CloseHandle", Ptr,hStdOutRd )

    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before reading the stdout.
    While ( 1 )
    { ; Before reading, we check if the pipe has been written to, so we avoid freezings.
        If ( !DllCall( "PeekNamedPipe", Ptr,hStdOutRd, Ptr,0, UInt,0, Ptr,0, UIntP,nTot, Ptr,0 ) )
            Break
        If ( !nTot )
        { ; If the pipe buffer is empty, sleep and continue checking.
            Sleep, 100
            Continue
        } ; Pipe buffer is not empty, so we can read it.
        VarSetCapacity(sTemp, nTot+1)
        DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,nTot, PtrP,nSize, Ptr,0 )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)
    }
    
    ; * SKAN has managed the exit code through SetLastError.
    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,0)                  )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,A_PtrSize)          )
    DllCall( "CloseHandle",        Ptr,hStdOutRd                     )
    Return sOutput
}

;注意要先将网络适配器的名称分别改为network2和network3

; number1：把以太网2、3设置为dhcp
#IfWinActive 
$NumpadEnd::
StdoutToVar_CreateProcess("cmd /c  ipconfig  /release network2") ; release旧的ip地址
StdoutToVar_CreateProcess("cmd /c  ipconfig  /release network3") ; release旧的ip地址
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 delete address network2 192.168.0.222 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 delete address network2 192.168.1.222 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 delete address network2 192.168.66.222 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 delete address network3 192.168.0.233 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 delete address network3 192.168.1.233 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 delete address network3 192.168.66.233 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ip set address network2 dhcp")
StdoutToVar_CreateProcess("cmd /c  netsh interface ip set dns network2 dhcp")
StdoutToVar_CreateProcess("cmd /c  netsh interface ip set address network3 dhcp")
StdoutToVar_CreateProcess("cmd /c  netsh interface ip set dns network3 dhcp")
return


; number2：把以太网2、3设置为静态IP
$NumpadDown::
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 set address network2 static 192.168.0.222 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 add address network2 192.168.1.222 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 add address network2 192.168.66.222 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 set address network3 static 192.168.0.233 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 add address network3 192.168.1.233 255.255.255.0")
StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 add address network3 192.168.66.233 255.255.255.0")
return

; number3：查看以太网2、3的IP
$NumpadPgDn::MsgBox  % StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 show ipaddress interface=network2")  StdoutToVar_CreateProcess("cmd /c  netsh interface ipv4 show ipaddress interface=network3")


$NumpadClear::
$NumpadRight::
$NumpadUp::
$NumpadPgUp::
$NumpadIns::
$NumpadLeft::
$NumpadHome::
$NumpadDel::
$NumpadAdd::
$NumpadSub::
$NumpadDiv::
$NumpadMult::
	return
	
*/
}