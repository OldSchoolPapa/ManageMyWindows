#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         OldSchoolPapa

 Script Function:

 Remove Flags of a 3rd Part Window and attach it to a new black empty Gui Container as a Child Window
 Specialy Made for PokerStars Client Software but compatible with similar Window Styles.
 Must be Run as an independant process from the main script to attach to the window(s) if multiple windows in order to destroy the container once the window is closed

 _ContainerGuiAsParent($hWnd,$Width,$Height,$x,$y)

 $hWnd   : Handle of The window to attach to the new container
 $Width  : Window Client Width  (Without Visible/Invisible Borders)
 $Height : Window Client Height (Without Title Bars and Visible/Invisible Borders)
 $x      : X Coordinate of the window on screen
 $y      : Y Coordinate of the window on screen

 More Window Flags can be Added/Removed following Windows API:
 https://docs.microsoft.com/fr-fr/windows/desktop/winmsg/window-styles
 https://docs.microsoft.com/fr-fr/windows/desktop/winmsg/extended-window-styles

 SetParent Function:
 https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setparent

 No Rest For The Wicked.

#ce ----------------------------------------------------------------------------

#NoTrayIcon

#include <C:\Program Files (x86)\AutoIt3\Include\WindowsConstants.au3>
#include <C:\Program Files (x86)\AutoIt3\Include\WinAPISysWin.au3>
#include <C:\Program Files (x86)\AutoIt3\Include\GUIConstantsEx.au3>
#include <C:\Program Files (x86)\AutoIt3\Include\ColorConstants.au3>
#include <C:\Program Files (x86)\AutoIt3\Include\WinAPIShPath.au3>
#include <C:\Program Files (x86)\AutoIt3\Include\Array.au3>

_ContainerGuiAsParent($CmdLine[1], $CmdLine[2], $CmdLine[3], $CmdLine[4], $CmdLine[5])

Func _ContainerGuiAsParent($hWnd, $Width, $Height, $x, $y)

   $hWnd = HWnd($hWnd)

   If Not WinExists($hWnd) Then
		  Exit
   EndIf

	Local $strTitle = WinGetTitle($hWnd) & " _Container"

	Local $hGUI = GUICreate($strTitle,$Width, $Height, $x, $y,  $WS_CLIPCHILDREN + $WS_POPUPWINDOW + $WS_CLIPSIBLINGS, -1)

	GUISetBkColor ($COLOR_BLACK)

	$iStyle  =  _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	$ExStyle =  _WinAPI_GetWindowLong($hWnd, $GWL_EXSTYLE)

	If BitAND($iStyle, $WS_BORDER) = $WS_BORDER Then
	   $iStyle = BitXOR($iStyle, $WS_BORDER)
	EndIf

	If BitAND($iStyle, $WS_DLGFRAME) = $WS_DLGFRAME Then
	   $iStyle = BitXOR($iStyle, $WS_DLGFRAME)
	EndIf

	If BitAND($iStyle, $WS_SYSMENU) = $WS_SYSMENU Then
	   $iStyle = BitXOR($iStyle, $WS_SYSMENU)
	EndIf

	If BitAND($iStyle, $WS_THICKFRAME) = $WS_THICKFRAME Then
	   $iStyle = BitXOR($iStyle, $WS_THICKFRAME)
	EndIf

	If BitAND($ExStyle, $WS_EX_WINDOWEDGE) = $WS_EX_WINDOWEDGE Then
	   $ExStyle = BitXOR($ExStyle, $WS_EX_WINDOWEDGE)
	EndIf

	_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, $iStyle )
	_WinAPI_SetWindowLong($hWnd, $GWL_EXSTYLE, $ExStyle)

	;_WinAPI_SetWindowPos($hWnd, $HWND_TOP, 0, 0, 0, 0, BitOR($SWP_FRAMECHANGED, $SWP_NOMOVE, $SWP_NOSIZE))

	WinMove($hWnd, "", Default, Default)

	$OrigParent = DllCall("user32.dll", "int", "SetParent", "hwnd", $hWnd, "hwnd", $hGUI)

	WinMove($hWnd, "", 0, 0)

	GUISetState(@SW_SHOW, $hGUI)
	GUISetState(@SW_ENABLE, $hGUI)

	While 1

	  $msg = GUIGetMsg()

      If $msg = $GUI_EVENT_CLOSE Then
		 ExitLoop
	  EndIf

	   If Not WinExists($hWnd) Then
		  ExitLoop
	   EndIf

	   If WinActive($hWnd) Then
          WinSetOnTop($hWnd, "", 1)
		  WinSetOnTop($hGUI, "", 0)
       EndIf

	   Sleep(25)

    WEnd

    GUIDelete($hGUI)

 EndFunc
