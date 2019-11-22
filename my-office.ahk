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
^#a:: 
{   ;MsgBox "zzzzz"
	Winset, Alwaysontop, Toggle, A ; win + ctrl + a
	Return
}
;^#Z:: Winset, Alwaysontop, off, ; win + shift + S
;Return



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
F1::Return
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

;===========================================================================
EnvGet, userProfile, USERPROFILE
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

<#q::RunOrActivateOrMinimizeProgram("C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe")
<#a::RunOrActivateOrMinimizeProgram("C:\Program Files (x86)\Microsoft Office\Office16\lync.exe")
;<#<!e::ToggleWinMinimize("ahk_class CabinetWClass")
<#<!c::ToggleWinMinimize("ahk_class ConsoleWindowClass")


;===========================================================================
; Skype shortcuts
;===========================================================================
#SingleInstance force
;
;   This Skype shortcuts will make pressing Ctrl+Up and Ctrl+Down work
;   to switch between conversation windows.
;
;   To do that normally we need to focus the Recent panel with Alt+2
;   (Alt+1 will focus the contacts panel)
;   Next we press up or down to switch between conversations
;   Then press enter to move the focus to the input box on the selected
;   conversation
;
;
;   *Note: this only works with the conversations in the "Recent" panel

ConversationUp()
{
    Send, {AltDown}2{AltUp}
    Sleep, 100
    Send, {Up}{Enter}
    return
}

ConversationDown()
{
    Send, {AltDown}2{AltUp}
    Sleep, 100
    Send, {Down}{Enter}
    return
}

SelectUserFind()
{
    Send, {AltDown}2{AltUp}
    Send, {AltDown}2{AltUp}
    Sleep, 100
    Loop 20
    {
        Send, {Up}
    }
}

#IfWinActive ahk_class LyncConversationWindowClass


#IfWinActive


#IfWinActive ahk_class tSkMainForm
;Ctrl+Down move one conversation down
^Down::ConversationDown()

;Ctrl+Up move one conversation up
^Up::ConversationUp()

;Ctrl+Tab move one conversation down
^Tab::ConversationDown()

;Ctrl+Shift+Tab move one conversation up
^+Tab::ConversationUp()

;Ctrl+Shift+F selects user search box

^+F::SelectUserFind()
#IfWinActive

;---Hotstrings----
::nhd::Netherlands{SPACE}Help{SPACE}Desk
::assts::I hope you are doing OK. I've been assigned to assists with your ticket.
::clrf::Could{SPACE}you{SPACE}please{SPACE}clarify{SPACE}how{SPACE}the{SPACE}issue{SPACE}could{SPACE}be{SPACE}reproduced?
::flfr::Please{SPACE}feel{SPACE}free{SPACE}to{SPACE}contact{SPACE}us{SPACE}if{SPACE}you{SPACE}have{SPACE}any{SPACE}questions{SPACE}or{SPACE}problems.
::cntm::Please feel free to contact me via SfB or Teams when it is convenience for you to discuss details.
::sr2hr::Sorry{SPACE}to{SPACE}hear{SPACE}you{SPACE}have{SPACE}faced{SPACE}with{SPACE}the{SPACE}issue.
::drbr::Dear{SPACE}brothers,
::hndl::We{SPACE}are{SPACE}glad{SPACE}to{SPACE}inform{SPACE}you{SPACE}your{SPACE}request{SPACE}has{SPACE}been{SPACE}handled!
::ltmk::Please{SPACE}let{SPACE}me{SPACE}know{SPACE}if{SPACE}I{SPACE}can{SPACE}help{SPACE}somehow{SPACE}else.
::pllt::Please let us know if some additional information or help needs to be provided.
::thff::Thank{SPACE}you{SPACE}so{SPACE}much{SPACE}for{SPACE}your{SPACE}efforts.
::prtm::Please{SPACE}feel{SPACE}free{SPACE}to{SPACE}propose{SPACE}a{SPACE}more{SPACE}convenient{SPACE}time{SPACE}for{SPACE}you.
::trst::We'd also appreciate knowing any other troubleshooting steps you have already tried.
::ltuspr::Please let us know if it may cause your problems.
;---End Of Hotstrings----


;------------------------------------
; Move mouse
^#Left::MouseMove, -200, 0,, R
^#Right::MouseMove, 200, 0,, R
^#Up::MouseMove, 0, -200,, R
^#Down::MouseMove, 0, 200,, R

;LWin & LAlt & z:: ; minimize window under the cursor
;  MouseGetPos, , , id
;  WinMinimize, ahk_id %id%, , Program Manager
;return

;------------------------------------
; activate the window currently under mouse cursor / see: https://autohotkey.com/board/topic/60521-how-to-activate-the-window-currently-under-mouse-cursor/
LWin & z::
	MouseGetPos,,, WinUMID
	WinActivate, ahk_id %WinUMID%
return

LWin & Numpad0::
	sendInput {alt down}{esc}{alt up}
return

LWin & NumpadDot::
	sendInput {alt down}{shift down}{esc}{alt up}{shift up}
return

;------------------------------------
; activate the window currently under mouse cursor
; global 
;wndMouseCrs := false
#f::  
    ;global wndMouseCrs
    ;MsgBox %wndMouseCrs%
	;wndMouseCrs := not ( wndMouseCrs )
	;MsgBox % If wndMouseCrs ? "TRUE" "FALSE"
    MouseGetPos,,, WinUMID
	WinActivate, ahk_id %WinUMID%

return

#Persistent
	SetTimer, ActivateWinUM, 100
return

ActivateWinUM:
	global wndMouseCrs
	MsgBox % If wndMouseCrs ? "TRUE" "FALSE"
	if ( wndMouseCrs ) {
		MouseGetPos,,, WinUMID
		WinActivate, ahk_id %WinUMID%
	}
return