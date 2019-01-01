#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         OldSchoolPapa

 Script Function:

          Remove Flags of a 3rd Part Window to remove the title bar and borders Then redraw the window's region using GDI+
          Specialy Made for PokerStars Client Software but compatible with similar Window's Styles.

          $hWnd    : Handle of The window
          $CWidth  : Window Client Width  (Without Visible/Invisible Borders)
          $CHeight : Window Client Height (Without Title Bars and Visible/Invisible Borders)

          More Window Flags can be Added/Removed following Windows API:
          https://docs.microsoft.com/fr-fr/windows/desktop/winmsg/window-styles
          https://docs.microsoft.com/fr-fr/windows/desktop/winmsg/extended-window-styles

          No Rest For The Wicked.
#ce ----------------------------------------------------------------------------

#include <WindowsConstants.au3>
#include <WinAPISysWin.au3>
#include <GDIPlus.au3>
#include <WinAPIGdi.au3>
#include <WinAPIHObj.au3>


Func _RemoveTitleBorders($hWnd, $CWidth, $CHeight)

    If Not WinExists($hWnd) Then
	 	  Return
    EndIf

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

	_GDIPlus_Startup()

    $hRgn = _WinAPI_CreateRectRgn(0, 0, $CWidth , $CHeight)
    _WinAPI_SetWindowRgn($hWnd, $hRgn)

    _WinAPI_DeleteObject($hRgn)
	_GDIPlus_Shutdown()

EndFunc
