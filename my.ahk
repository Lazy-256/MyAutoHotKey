; ref https://gist.github.com/Rplus/6147549
; ref: http://www.howtogeek.com/howto/28663/create-a-hotkey-to-resize-windows-to-a-specific-size-with-autohotkey/
;----------------------------------------------------------------
; AutoHotkey Version: 1.x
; Language:       English
; Author:         Lowell Heddings <geek@howtogeek.com>
; Description:    Resize Active Window
;
;----------------------------------------------------------------

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

;----------------------------------------------------------------
;  EXAMPLES
;----------------------------------------------------------------
; Note: all examples using Alt+Win+U as the hotkey
;
; #!u::ResizeWin(800,600)
;    - Resize a window to 800 width by 600 height
;
; #!u::ResizeWin(640)
;    - Resize a window to 640 width, leaving the height the same
;
; #!u::ResizeWin(0,600)
;    - Resize a window to 600 height, leaving width the same
;
;----------------------------------------------------------------
ResizeWin(Width = 0, Height = 0, Direction = 1, WinMoveDir = 0)
{
  WinGetPos,X,Y,W,H,A
  if ( %Height% = 0 )
    Height := H

  if ( WinMoveDir = 0  ) {
    if ( %Width% = 0 )
      Width := W + Direction * 100

    WinMove,A,,%X%,%Y%,%Width%,%Height%
  } else {
    ; меняем размер окна справа
    if ( Width = 0 ) {
      Width := W - Direction * 100
    }  
    XX := (X + Direction * 100)
    WinMove,A,,%XX%,%Y%,%Width%,%Height% 
  }
}

; This function is modified from the original: http://www.autohotkey.com/board/topic/85457-detecting-the-screen-the-current-window-is-on/ by irl404 and Leef_me
getCurrentMonitor()
{
  SysGet, numberOfMonitors, MonitorCount
  WinGetPos, winX, winY, winWidth, winHeight, A
  winMidX := winX + winWidth / 2
  winMidY := winY + winHeight / 2
  Loop %numberOfMonitors%
  {
    SysGet, monArea, Monitor, %A_Index%
    if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop)
      return A_Index
  }
  SysGet, primaryMonitor, MonitorPrimary
  MsgBox, "No Monitor Found"
  return 1
}

ResizeWinLOrR(Direction = 1)
{
  ; размер раб стола
  currentMonitor := getCurrentMonitor()

  SysGet, currentMonitorWorkArea, MonitorWorkArea, %currentMonitor%
  currentMonitorWorkWidth := currentMonitorWorkAreaRight - currentMonitorWorkAreaLeft
  currentMonitorWorkHeight := currentMonitorWorkAreaBottom - currentMonitorWorkAreaTop
  
  ;  если прав х >= ширины экрана, то меняем размер окна слева, иначе справа
  WinGetPos,X,Y,W,H,A
  ;MsgBox % currentMonitorWorkWidth
  ;MsgBox % (X + W)
  if ( (X+W) >= (currentMonitorWorkWidth)) {
    ResizeWin(,,Direction, -1)
  } else {
    ResizeWin(,,Direction, 0)
    }
  
}

; Resize Window
!#Left::ResizeWinLOrR(-1)    ; ResizeWinLOrRDide(-1)   ; ResizeWin(,,-1) 
!#Right::ResizeWinLOrR()     ; ResizeWinLOrRDide()   ; ResizeWin()

; Always on Top
#A:: Winset, Alwaysontop, , A ; win + A
Return

; Toggle hidden files in Windows Explorer, http://www.autohotkey.com/community/viewtopic.php?t=73186
; -----------------------------------------------------------------------------
<^h::
IfWinActive, ahk_class CabinetWClass
{
	RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
	If HiddenFiles_Status = 2 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
	Else 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
	WinGetClass, eh_Class,A
	If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA" OR A_OSVersion = "WIN_7" OR A_OSVersion = "WIN_10")
		send, {F5}
	Else PostMessage, 0x111, 28931,,, A
}
Else SendInput ^h
Return

; Disable annoying keyboard keys
; -----------------------------------------------------------------------------
; F1::Return
;CapsLock::Return
;Launch_Mail::Return
;Launch_App2::Return
;Browser_Home::Return

; Move window to other monitor / Maximize window / Close window
; -----------------------------------------------------------------------------
;!#a:: SendInput #+{Left}
!#q:: SendInput #{Up}
<^<!Enter::
	SendInput !{F4} ;WinClose, A
	Return
	
; Close active window
!q::Send !{F4}

LWin & z:: ; minimize window under the cursor
  MouseGetPos, , , id
  WinMinimize, ahk_id %id%, , Program Manager
return

; -----------------------------------------------------------------------------
EnvGet, userProfile, USERPROFILE
;EnvGet, prgm, ProgramFiles
;EnvGet, prgm86, ProgramFiles(x86)
;MsgBox %prgm%

; Software := userProfile . "\Dropbox\software\"

; Launch or toggle program, http://lifehacker.com/5468862/create-a-shortcut-key-for-restoring-a-specific-window
; -----------------------------------------------------------------------------
ToggleWinMinimize(WindowTitle)
{
	SetTitleMatchMode,2
	DetectHiddenWindows, Off
	IfWinActive, %WindowTitle%
	WinMinimize, %WindowTitle%
	Else
	IfWinExist, %WindowTitle%
	{
		WinActivate
	}
	Return
}

RunOrActivateOrMinimizeProgram(Program, WorkingDir="", WindowSize="")
{
	SplitPath Program, ExeFile
	Process, Exist, %ExeFile%
	PID = %ErrorLevel%
	if (PID = 0)
	{
		Run, %Program%, %WorkingDir%, %WindowSize%
	}
	else
	{
		SetTitleMatchMode,2
		DetectHiddenWindows, Off
		IfWinActive, ahk_pid %PID%
		WinMinimize, ahk_pid %PID%
		Else
		IfWinExist, ahk_pid %PID%
		WinActivate, ahk_pid %PID%
		Return
	}
}

<#q::RunOrActivateOrMinimizeProgram("C:\Program Files\WindowsApps\Evernote.Evernote_6.16.8094.0_x86__q4d96b2w5wcc2\VFS\Evernote.exe")
;<#<!e::ToggleWinMinimize("ahk_class CabinetWClass")
<#<!c::ToggleWinMinimize("ahk_class ConsoleWindowClass")

;---------------------------------------------
; see: https://gist.github.com/ek-db/86b7f6bd80de3710ba3973bea7b07460

<#<!e::
IfWinNotExist, ahk_class CabinetWClass
	Run, explorer.exe
GroupAdd, explorers, ahk_class CabinetWClass
if WinActive("ahk_exe explorer.exe")
	GroupActivate, explorers, r
else
	WinActivate ahk_class CabinetWClass ;you have to use WinActivatebottom if you didn't create a window group.
Return

;F1:: send {LWin down}{LCtrl down}{Left}{LCtrl up}{LWin up}  ; switch to previous virtual desktop
;F2:: send {LWin down}{LCtrl down}{Right}{LCtrl up}{LWin up}   ; switch to next virtual desktop

;--------------------------------------------------
; see: https://gist.github.com/elken/74e056c560a19bb7027cc35df58ef0e4
; see: https://github.com/Ciantic/VirtualDesktopAccessor/tree/master/x64/Release

;FileInstall, VirtualDesktopAccessor.dll, "C:\Program Files\VirtualDesktopAccessor\VirtualDesktopAccessor.dll", 1

DetectHiddenWindows, On
hwnd:=WinExist("ahk_pid " . DllCall("GetCurrentProcessId","Uint"))
hwnd+=0x1000<<32

hVirtualDesktopAccessor := DllCall("LoadLibrary", Str, "C:\Program Files\VirtualDesktopAccessor\VirtualDesktopAccessor.dll", "Ptr") 
GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnCurrentVirtualDesktop", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
RegisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnregisterPostMessageHook", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedWindow", "Ptr")
RestartVirtualDesktopAccessorProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RestartVirtualDesktopAccessor", "Ptr")
; GetWindowDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetWindowDesktopNumber", "Ptr")
activeWindowByDesktop := {}

; Restart the virtual desktop accessor when Explorer.exe crashes, or restarts (e.g. when coming from fullscreen game)
explorerRestartMsg := DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated")
OnMessage(explorerRestartMsg, "OnExplorerRestart")
OnExplorerRestart(wParam, lParam, msg, hwnd) {
    global RestartVirtualDesktopAccessorProc
    DllCall(RestartVirtualDesktopAccessorProc, UInt, result)
}

MoveCurrentWindowToDesktop(number) {
	global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc, activeWindowByDesktop
	WinGet, activeHwnd, ID, A
	activeWindowByDesktop[number] := 0 ; Do not activate
	DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, number)
	DllCall(GoToDesktopNumberProc, UInt, number)
}

GoToPrevDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, UInt)
	if (current = 0) {
		GoToDesktopNumber(7)
	} else {
		GoToDesktopNumber(current - 1)      
	}
	return
}

GoToNextDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, UInt)
	if (current = 7) {
		GoToDesktopNumber(0)
	} else {
		GoToDesktopNumber(current + 1)    
	}
	return
}

GoToDesktopNumber(num) {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc, IsPinnedWindowProc, activeWindowByDesktop

	; Store the active window of old desktop, if it is not pinned
	WinGet, activeHwnd, ID, A
	current := DllCall(GetCurrentDesktopNumberProc, UInt) 
	isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
	if (isPinned == 0) {
		activeWindowByDesktop[current] := activeHwnd
	}

	; Try to avoid flashing task bar buttons, deactivate the current window if it is not pinned
	if (isPinned != 1) {
		WinActivate, ahk_class Shell_TrayWnd
	}

	; Change desktop
	DllCall(GoToDesktopNumberProc, Int, num)
	return
}

; Windows 10 desktop changes listener
DllCall(RegisterPostMessageHookProc, Int, hwnd, Int, 0x1400 + 30)
OnMessage(0x1400 + 30, "VWMess")
VWMess(wParam, lParam, msg, hwnd) {
	global IsWindowOnCurrentVirtualDesktopProc, IsPinnedWindowProc, activeWindowByDesktop

	desktopNumber := lParam + 1
	
	; Try to restore active window from memory (if it's still on the desktop and is not pinned)
	WinGet, activeHwnd, ID, A 
	isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
	oldHwnd := activeWindowByDesktop[lParam]
	isOnDesktop := DllCall(IsWindowOnCurrentVirtualDesktopProc, UInt, oldHwnd, UInt)
	if (isOnDesktop == 1 && isPinned != 1) {
		WinActivate, ahk_id %oldHwnd%
	}

	; Menu, Tray, Icon, Icons/icon%desktopNumber%.ico
	
	; When switching to desktop 1, set background pluto.jpg
	; if (lParam == 0) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\saturn.jpg", UInt, 1)
	; When switching to desktop 2, set background DeskGmail.png
	; } else if (lParam == 1) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskGmail.png", UInt, 1)
	; When switching to desktop 7 or 8, set background DeskMisc.png
	; } else if (lParam == 2 || lParam == 3) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskMisc.png", UInt, 1)
	; Other desktops, set background to DeskWork.png
	; } else {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskWork.png", UInt, 1)
	; }
}

; Switching desktops:
; <Win + Ctrl + F1 = Switch to desktop 1
<#F1::GoToDesktopNumber(0)
<#F2::GoToDesktopNumber(1)

; Moving windowes:
; <Win + Ctrl + F1 = Move current window to desktop 1, and go there
*<#F1::MoveCurrentWindowToDesktop(0)
*<#F2::MoveCurrentWindowToDesktop(1)
