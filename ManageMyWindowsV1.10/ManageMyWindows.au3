#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         OldSchoolPapa

 Script Function:

	Manage Specific Visible Window(s) (Also Poker Tables) in order to Tile / Cascade Them on specific(s) Monitor(s) with a pre-configured size.

 Note:
    To calculate more accurately the correct positions of windows on screen i use _WinAPI_GetSystemMetrics to get the System size of borders ...
	More informations about those flags can be found on Micro$oft Documentation
	https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-getsystemmetrics

	Make sure before to run or compile the source than the folder "Lib" with it's files are in the main ManageMyWindow's folder

	In addition i might add in futur a setup for keyboard shortcus and personalised setup to stack tables or might not :p

	No Rest For The Wicked.

#ce ----------------------------------------------------------------------------

#pragma compile(inputboxres, true)"

#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiButton.au3>
#include <ButtonConstants.au3>
#include <FontConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <WinAPISys.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>

#include <./Lib/WinManager.au3>

Opt("WinTitleMatchMode",-2) ; 1 = start, 2 = subStr, 3 = exact, 4 = advanced, -1 to -4 = Nocasesensitive (Advanced mode is for the use of regular expression)

Global $LoopInterrupt   = 1
Global $aDisplaySetup   = _EnumDisplaySetup()
Local Const $sFilePath  = ".\Setup.ini"
Local Const $sFont      = "Times New Roman"


Local $ManageMyWindows        = GUICreate("ManageMyWindows", 980, 400, -1, -1, -1, -1)
                                GUISetBkColor($COLOR_BLACK)

GUICtrlCreateLabel("Window(s) Partial Title(s) (Use ',' as Delimiter) :", 10, 10, 310, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $WinTitles_Input        = GUICtrlCreateInput("Title Bar(s)", 315, 10, 655, 20, $ES_CENTER)
						        GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

GUICtrlCreateLabel("Window Size :", 10, 40, 100, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $WinSize_Input          = GUICtrlCreateInput("Width x Height", 105, 40, 95, 20, $ES_CENTER)
                                GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

GUICtrlCreateLabel("Client Size :", 20, 70, 100, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $ClientSize_Input       = GUICtrlCreateInput("Width x Height", 105, 70, 95, 20, $ES_CENTER)
						        GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

Local $WinDetectSize          = GUICtrlCreateButton("Get Size", 210, 55, 70, 25, $BS_PUSHLIKE)
                                GUICtrlSetFont(-1, 10, $FW_HEAVY, $GUI_FONTNORMAL, $sFont)

GUICtrlCreateLabel("H Space Between Tiled Windows :", 290, 40, 210, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $HSpaceBtwTiles_Input    = GUICtrlCreateInput("0", 505, 40, 25, 20, $ES_CENTER)
								 GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

GUICtrlCreateLabel("V Space Between Tiled Windows :", 290, 70, 210, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $VSpaceBtwTiles_Input   = GUICtrlCreateInput("0", 505, 70, 25, 20, $ES_CENTER)
                                GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

GUICtrlCreateLabel("Cascade Incrementation :", 545, 40, 160,20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $CascadeInc_Input       = GUICtrlCreateInput("50", 710, 40, 25, 20, $ES_CENTER)
                                GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

GUICtrlCreateLabel("Space Between Cascade Rows :", 545, 70, 190, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $SpaceBtwCascadeR_Input = GUICtrlCreateInput("0", 740, 70, 25, 20, $ES_CENTER)
                                GUICtrlSetFont(-1, 10, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)

Local $TileRadioBtn           = GUICtrlCreateRadio("Tile", 10, 100, 50, 20)
				                DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($TileRadioBtn), "wstr", 0, "wstr", 0)
							    GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
				                GUICtrlSetColor(-1, $COLOR_WHITE)
				                GUICtrlSetState(-1, $GUI_CHECKED)

Local $CascadeRadioBtn        = GUICtrlCreateRadio("Cascade", 60, 100, 70, 20)
							    DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($CascadeRadioBtn), "wstr", 0, "wstr", 0)
							    GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
				                GUICtrlSetColor(-1, $COLOR_WHITE)

Local $StackRadioBtn          = GUICtrlCreateRadio("Stack", 140, 100, 120, 20)
					            DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($StackRadioBtn), "wstr", 0, "wstr", 0)
							    GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
				                GUICtrlSetColor(-1, $COLOR_WHITE)

Local $HiddenTaskbar          = GUICtrlCreateCheckbox( "Win Taskbar is auto Hidden", 290, 100, 190, 20)
					            DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($HiddenTaskbar), "wstr", 0, "wstr", 0)
							    GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
				                GUICtrlSetColor(-1, $COLOR_WHITE)

Local $UseContainer           = GUICtrlCreateCheckbox( "Remove TitleBar + Borders", 545, 100, 190, 20)
					            DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($UseContainer), "wstr", 0, "wstr", 0)
					            GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
				                GUICtrlSetColor(-1, $COLOR_WHITE)


GUICtrlCreateLabel("Select Screen(s) to use :", 10, 130, 150, 20)
GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTUNDER, $sFont)
GUICtrlSetColor(-1, $COLOR_WHITE)

Local $aScreenCB[1] = [0]
$y = 160

For $i = 1 To $aDisplaySetup[0][0]
   _ArrayAdd($aScreenCB, GUICtrlCreateCheckbox("Screen " & $i & " Resolution : " & $aDisplaySetup[$i][3] & "x" & $aDisplaySetup[$i][4] & " Pixels", 10, $y, 280, 25))
   DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($aScreenCB[$i]), "wstr", 0, "wstr", 0)
   GUICtrlSetFont(-1, 11, $FW_EXTRABOLD, $GUI_FONTNORMAL, $sFont)
   GUICtrlSetColor(-1, $COLOR_WHITE)
   $aScreenCB[0] += 1
   $y += 25
Next

Local $SaveSetup   = GUICtrlCreateButton("Save Setup", 890, 300, 80, 25, $BS_PUSHLIKE)
                     GUICtrlSetFont(-1, 10, $FW_HEAVY, $GUI_FONTNORMAL, $sFont)

Local $WinRunOnce  = GUICtrlCreateButton("RunOnce", 890, 330, 80, 25, $BS_PUSHLIKE)
                     GUICtrlSetFont(-1, 10, $FW_HEAVY, $GUI_FONTNORMAL, $sFont)

Local $WinAutoMode = GUICtrlCreateButton("Auto Mode", 890, 360, 80, 25, $BS_PUSHLIKE)
                     GUICtrlSetFont(-1, 10, $FW_HEAVY, $GUI_FONTNORMAL, $sFont)

_LoadSetup()

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

GUISetState(@SW_SHOW)


While 1

	$nMsg = GUIGetMsg()

	Switch $nMsg

	     Case $GUI_EVENT_CLOSE

                GUIDelete($ManageMyWindows)
			    Exit

		 Case $WinDetectSize

			    _DetectSize()

		 Case $WinRunOnce

     			$LoopInterrupt = 1
			    _ManageWindows()

		 Case $WinAutoMode

			If $LoopInterrupt = 0 Then
			     GUICtrlSetColor($WinAutoMode, $COLOR_RED)
			     _GUICtrlButton_Enable($WinRunOnce, False)
				 _ManageWindows()
			Else
				 GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
			     _GUICtrlButton_Enable($WinRunOnce, True)
			EndIf

		 Case $SaveSetup

            	_SaveSetup()

	EndSwitch

 WEnd

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

    If BitAND($wParam, 0x0000FFFF) =  $WinAutoMode Then $LoopInterrupt = Not $LoopInterrupt
	Return $GUI_RUNDEFMSG

 EndFunc   ;==>WM_COMMAND

Func _EnumDisplaySetup()

Local $aPos, $aData = _WinAPI_EnumDisplayMonitors()

If IsArray($aData) Then
	ReDim $aData[$aData[0][0] + 1][5]
	For $i = 1 To $aData[0][0]
		$aPos = _WinAPI_GetPosFromRect($aData[$i][1])
		For $j = 0 To 3
			$aData[$i][$j + 1] = $aPos[$j]
		Next
	Next
EndIf

Return $aData

EndFunc

Func _DetectSize()

   Local $WinT = InputBox("Window's Size Detection", " Open a window and Resize it If You Need To. Then type partially the TitleBar's Text." & @CRLF _
						 &"              (Make Sure There is only one window with the same Titlebar's Text)" , "" ,"" , 450, 150)

   If @error Then
	  Return
   ElseIf StringLen($WinT) >= 3 Then

	  $aWSize = WinGetPos($WinT)
	      If @error Then
			 MsgBox(0,"Error","Window wasn't Found ! Check the TitleBar's Text" & @CRLF _
					  &"Also Check If the window is open and not Minimized.")
             Return
		  EndIf
	  $aCSize = WinGetClientSize($WinT)

	  GUICtrlSetData($WinSize_Input,    $aWSize[2]&"x"&$aWSize[3])
	  GUICtrlSetData($ClientSize_Input, $aCSize[0]&"x"&$aCSize[1])
	  Return
   Else
      MsgBox(0,"Error","Input Box Empty or Text Length < to 3 Chars.")
	  Return
   EndIf

EndFunc

Func _SaveSetup()

	  IniWrite($sFilePath, "General", "WinTitles"             , GUICtrlRead($WinTitles_Input       ))
	  IniWrite($sFilePath, "General", "WinSize"               , GUICtrlRead($WinSize_Input         ))
	  IniWrite($sFilePath, "General", "ClientSize"            , GUICtrlRead($ClientSize_Input      ))
      IniWrite($sFilePath, "General", "H_Space_Btw_Tiles"     , GUICtrlRead($HSpaceBtwTiles_Input  ))
	  IniWrite($sFilePath, "General", "V_Space_Btw_Tiles"     , GUICtrlRead($VSpaceBtwTiles_Input  ))
	  IniWrite($sFilePath, "General", "Cascade_Inc"           , GUICtrlRead($CascadeInc_Input      ))
	  IniWrite($sFilePath, "General", "Space_Btw_Cascade_Rows", GUICtrlRead($SpaceBtwCascadeR_Input))


EndFunc

Func _LoadSetup()

    If FileExists($sFilePath) Then

	  GUICtrlSetData($WinTitles_Input        , IniRead($sFilePath, "General", "WinTitles"               , "Default Value" ))
	  GUICtrlSetData($WinSize_Input          , IniRead($sFilePath, "General", "WinSize"                 , "Default Value" ))
	  GUICtrlSetData($ClientSize_Input       , IniRead($sFilePath, "General", "ClientSize"              , "Default Value" ))
      GUICtrlSetData($HSpaceBtwTiles_Input   , IniRead($sFilePath, "General", "H_Space_Btw_Tiles"       , "Default Value" ))
	  GUICtrlSetData($VSpaceBtwTiles_Input   , IniRead($sFilePath, "General", "V_Space_Btw_Tiles"       , "Default Value" ))
	  GUICtrlSetData($CascadeInc_Input       , IniRead($sFilePath, "General", "Cascade_Inc"             , "Default Value" ))
	  GUICtrlSetData($SpaceBtwCascadeR_Input , IniRead($sFilePath, "General", "Space_Btw_Cascade_Rows"  , "Default Value" ))

	EndIf

EndFunc

 Func _ManageWindows()

	Local $aMonSelect[1] = [$aDisplaySetup[0][0]]
	Local $StrWinTitles, $TaskBarH, $SysMetricsW, $SysMetricsH, $HSpaceBtwTiles, $VSpaceBtwTiles, $CascadeInc, $SpaceBtwCascadeRows
	Local $aHwnds, $aWinPos

	For $i = 1 To $aDisplaySetup[0][0]

       If GUICtrlRead($aScreenCB[$i]) = $GUI_CHECKED Then
          _ArrayAdd($aMonSelect,1)
	   Else
		  _ArrayAdd($aMonSelect,0)
	   EndIf

	Next

	Local $iSearch = _ArraySearch($aMonSelect,"1")

	If @error Then
	   MsgBox(0,"Error","You Didn't Select Any Screen !!!")
	   $LoopInterrupt = 1
	   GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
	   _GUICtrlButton_Enable($WinRunOnce, True)
	   Return
	EndIf

   Local $Win2Search = GUICtrlRead($WinTitles_Input)

   If $Win2Search = "Title Bar(s)" Or StringLen($Win2Search) < 3 Then
	  MsgBox(0,"Error","Window(s) TitleBar's Text input box is wrong or empty")
	  $LoopInterrupt = 1
	  GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
	  _GUICtrlButton_Enable($WinRunOnce, True)
	  Return
   EndIf

   Local $WinSize = GUICtrlRead($WinSize_Input)

   If $WinSize = "Width x Height" Or StringLen($WinSize) <= 5 Then
	  MsgBox(0,"Error","Please fill up the Window's size input box or click on Get Size Button.")
	  $LoopInterrupt = 1
	  GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
	  _GUICtrlButton_Enable($WinRunOnce, True)
	  Return
   EndIf

   Local $ClientSize = GUICtrlRead($ClientSize_Input)

   If $ClientSize = "Width x Height" Or StringLen($ClientSize) <= 5 Then
	  MsgBox(0,"Error","Please fill up the Client's size input box or click on Get Size Button.")
	  $LoopInterrupt = 1
	  GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
	  _GUICtrlButton_Enable($WinRunOnce,True)
	  Return
   EndIf

   If BitAND(GUICtrlRead($StackRadioBtn),$GUI_CHECKED) = $GUI_CHECKED Then
	  MsgBox(0,"Error","Stack Option isn't Yet Implemented.")
	  $LoopInterrupt = 1
	  GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
	  _GUICtrlButton_Enable($WinRunOnce,True)
	  Return
   EndIf

   If BitAND(GUICtrlRead($HiddenTaskbar),$GUI_CHECKED) = $GUI_CHECKED Then
	  $TaskBarH = 0
   Else
      $TaskBarH = WinGetClientSize("[CLASS:Shell_TrayWnd]")[1]
   EndIf

   $SysMetricsW = _WinAPI_GetSystemMetrics(32) * 2
   $SysMetricsH = _WinAPI_GetSystemMetrics(33) + _WinAPI_GetSystemMetrics(46)

   $WinSize    = StringStripWS($WinSize   , $STR_STRIPALL)
   $ClientSize = StringStripWS($ClientSize, $STR_STRIPALL)

   $WinSize    = StringSplit($WinSize   , "x", 0)
   $ClientSize = StringSplit($ClientSize, "x", 0)

   $StrWinTitles        = GUICtrlRead($WinTitles_Input       )
   $HSpaceBtwTiles      = GUICtrlRead($HSpaceBtwTiles_Input  )
   $VSpaceBtwTiles      = GUICtrlRead($VSpaceBtwTiles_Input  )
   $CascadeInc          = GUICtrlRead($CascadeInc_Input      )
   $SpaceBtwCascadeRows = GUICtrlRead($SpaceBtwCascadeR_Input)

   If $CascadeInc < 5 Then
	  MsgBox(0,"Error","Cascade Incrementation must be > to 4 pixel.")
	  $LoopInterrupt = 1
	  GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
	  _GUICtrlButton_Enable($WinRunOnce,True)
	  Return
   EndIf

   Select

       Case BitAND(GUICtrlRead($TileRadioBtn), $GUI_CHECKED) = $GUI_CHECKED

			If BitAND(GUICtrlRead($UseContainer), $GUI_CHECKED) = $GUI_CHECKED Then
			   $aWinPos = _SlotsForTiledWindows($aDisplaySetup, $aMonSelect, $ClientSize[1], $ClientSize[2], $TaskBarH, 0, 0, $VSpaceBtwTiles, $HSpaceBtwTiles)
	        Else
			   $aWinPos = _SlotsForTiledWindows($aDisplaySetup, $aMonSelect, $WinSize[1], $WinSize[2], $TaskBarH, $SysMetricsW, $SysMetricsH, $VSpaceBtwTiles, $HSpaceBtwTiles)
	        EndIf

	  Case BitAND(GUICtrlRead($CascadeRadioBtn), $GUI_CHECKED) = $GUI_CHECKED

			If BitAND(GUICtrlRead($UseContainer), $GUI_CHECKED) = $GUI_CHECKED Then
			   $aWinPos = _SlotsForCascadedWindows($aDisplaySetup, $aMonSelect, $ClientSize[1], $ClientSize[2], $TaskBarH, 0, 0, $CascadeInc, $SpaceBtwCascadeRows)
	        Else
			   $aWinPos = _SlotsForCascadedWindows($aDisplaySetup, $aMonSelect, $WinSize[1], $WinSize[2], $TaskBarH, $SysMetricsW, $SysMetricsH, $CascadeInc, $SpaceBtwCascadeRows)
	        EndIf

	  Case Else

		    MsgBox(0,"Error","Error in Layout Selection")
			Return

   EndSelect

   $aHwnds = _GetWinHwnds($StrWinTitles)

	Sleep(25)

	While 1

	   If BitAND(GUICtrlRead($UseContainer), $GUI_CHECKED) = $GUI_CHECKED Then
		    If $aHwnds <> @error Then
			    $aWinPos = _MoveWindowsToSlots($aHwnds, $aWinPos, $ClientSize[1], $ClientSize[2], 1, $WinSize[1], $WinSize[2])
			EndIf

		 Else
			If $aHwnds <> @error Then
			    $aWinPos = _MoveWindowsToSlots($aHwnds, $aWinPos, $WinSize[1], $WinSize[2], 0 , 0, 0)
			EndIf
      EndIf

      If $LoopInterrupt = 1 Then
		   $LoopInterrupt = 1
		   GUICtrlSetColor($WinAutoMode, $COLOR_BLACK)
		   _GUICtrlButton_Enable($WinRunOnce, True)
		   ExitLoop
	  EndIf

	  $aHwnds = _GetWinHwnds($StrWinTitles)

	  Sleep(25)

	WEnd

 EndFunc

