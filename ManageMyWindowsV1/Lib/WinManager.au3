#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         OldSchoolPapa

 Script Function:

    - Get Windows Handles from substring of Titlebar(s) Text
	- Create Canva/Layout of a specific width/height to Tile/Cascade windows over selected screen(s).
    - Move the windows to a specific location with the Possibility to attach them to a container in order to remove borders and titlebar

    No Rest For The Wicked.

#ce ----------------------------------------------------------------------------
#include <Array.au3>
#include <WinAPIGdi.au3>
#include <StringConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPISys.au3>

Opt("WinTitleMatchMode",-2) ;1 = start, 2 = subStr, 3 = exact, 4 = advanced, -1 to -4 = Nocasesensitive


Func _GetWinHwnds($StrWinTitles)

Local $aWinHwnds[][]=[[0, ""]]

Local $WinTitles = StringSplit($StrWinTitles, ",", 0)

For $i = 1 to $WinTitles[0]
    If StringLen($WinTitles[$i]) >= 2 Then
	  $aWlist = WinList($WinTitles[$i])
             If $i = 1 Then
				$aWinHwnds[0][0] += $aWList[0][0]
                _ArrayConcatenate($aWinHwnds, $aWList , 1)
			 ElseIf $i > 1 Then
			    $aWinHwnds[0][0] += $aWList[0][0]
                _ArrayConcatenate($aWinHwnds, $aWList , 1)
			 EndIf
    EndIf
 Next

Sleep(20)

If $aWinHwnds[0][0] > 0 Then
   Return $aWinHwnds
Else
   Return @error
EndIf

EndFunc


Func _WindowToContainer($Hwnd, $x, $y, $Width, $Height)

   $sSearch = StringInStr(WinGetTitle($Hwnd), "_Container")

    If $sSearch = 0 Then

	   ;$iPid = Run(@AutoItExe & " ./Lib/ParentContainer.au3 " & String($Hwnd) & " " & $Width & " " & $Height & " " & $x & " " & $y)
	    $iPid = Run(@AutoItExe &  ' /AutoIt3ExecuteScript ' & './Lib/ParentContainer.au3 ' & String($Hwnd) & ' ' & $Width & ' ' & $Height & ' ' & $x & ' ' & $y)

	   Return _GetHwndFromPID($iPid)

	Else

	   Return 0

    EndIf

EndFunc

Func _GetHwndFromPID($PID)
    $hWnd = 0
    $stPID = DllStructCreate("int")
    Do
        $winlist2 = WinList()
        For $i = 1 To $winlist2[0][0]
            If $winlist2[$i][0] <> "" Then
                DllCall("user32.dll", "int", "GetWindowThreadProcessId", "hwnd", $winlist2[$i][1], "ptr", DllStructGetPtr($stPID))
                If DllStructGetData($stPID, 1) = $PID Then
                    $hWnd = $winlist2[$i][1]
                    ExitLoop
                EndIf
            EndIf
        Next
        Sleep(100)
    Until $hWnd <> 0
    Return $hWnd
EndFunc


Func _SlotsForTiledWindows($aDisplaySetup, $aMonSelect, $Width, $Height, $TaskBarH, $SysM_W, $SysM_H, $Space2Add_W, $Space2Add_H)

   Local $aWinPos[][] = [[0, "", ""]]

        For $i = 1 To $aDisplaySetup[0][0]

	          Local $x = $aDisplaySetup[$i][1]
              Local $y = 0

	              If $aMonSelect[$i] = 1 Then
	                 While $y + ($Height - $SysM_H)  <= ( $aDisplaySetup[$i][2] + $aDisplaySetup[$i][4] ) - $TaskBarH
		                   While $x + ($Width - $SysM_W)  <= $aDisplaySetup[$i][1] + $aDisplaySetup[$i][3]
			            		   $aWinPos[0][0]+=1
					               Local $PosXY[][] = [[$x , $y , "Empty"]]
					               _ArrayAdd($aWinPos,$PosXY)
						           $x = $x  + ($Space2Add_W) + ($Width - $SysM_W)
				           WEnd
			            $x = $aDisplaySetup[$i][1]
                        $y = $y + ($Space2Add_H) + ($Height - $SysM_H)
					 WEnd
				  EndIf
	    Next

   Return $aWinPos

EndFunc

Func _SlotsForCascadedWindows($aDisplaySetup, $aMonSelect, $Width, $Height, $TaskBarH, $SysM_W, $SysM_H, $Inc, $SpaceBtwCascades)

   Local $aWinPos[][] = [[0, "", ""]]

        For $i = 1 To $aDisplaySetup[0][0]

             Local $x = $aDisplaySetup[$i][1]
             Local $y = 0

            If $aMonSelect[$i] = 1 Then

                $WpC = 0

			    While $x + ($Width - $SysM_W) <= $aDisplaySetup[$i][1] + $aDisplaySetup[$i][3]

	                  Local $y = 0
	                  $WpC = 0

	                  While $y + ($Height - $SysM_H)  <= ( $aDisplaySetup[$i][2] + $aDisplaySetup[$i][4] ) - $TaskBarH And $x + ($Width - $SysM_W)  <= $aDisplaySetup[$i][1] + $aDisplaySetup[$i][3]

		                     If $y = 0 And $x >=  $aDisplaySetup[$i][1]+ $Width Then

								 $x = (( $x ) - ( $Inc  + $SysM_W ) ) + ($SpaceBtwCascades)

					         EndIf

				          $aWinPos[0][0]+=1
		                  Local $PosXY[][] = [[$x , $y , "Empty"]]
		                  _ArrayAdd($aWinPos,$PosXY)

		                  $x = $x + $Inc
		                  $y = $y + $Inc
                          $WpC += 1

	                  WEnd

                    If $y + ($Height - $SysM_H)  > ( $aDisplaySetup[$i][2] + $aDisplaySetup[$i][4] ) - $TaskBarH Then
            		    $x =  $x  +  ($Width - ($Inc * $WpC) ) + $Inc + ($SpaceBtwCascades)
        	        EndIf
                WEnd

            EndIf
        Next

 Return $aWinPos

EndFunc

Func _MoveWindowsToSlots($aHwnds, $aWinPos, $Width, $Height, $Clip2Parent)

   For $i = 1 To $aHwnds[0][0]

	    Local $sSearch = _ArraySearch($aWinPos, $ahWnds[$i][1], 0, 0, 0, 1, 1, 2)

	  If $sSearch = -1 Then

			Local $sEmptySlot = _ArraySearch($aWinPos, "Empty", 0, 0, 0, 1, 1, 2)

			      If $sEmptySlot <> -1 Then

					 If $Clip2Parent = 1 Then

						$Clip = _WindowToContainer($aHwnds[$i][1], $aWinPos[$sEmptySlot][0], $aWinPos[$sEmptySlot][1], $Width, $Height)

						If $Clip <>0 Then

						 $aWinPos[$sEmptySlot][2] = $Clip

						EndIf

					 Else

				        WinMove($aHwnds[$i][1], "", $aWinPos[$sEmptySlot][0], $aWinPos[$sEmptySlot][1], $Width, $Height)

				        $aWinPos[$sEmptySlot][2] = $aHwnds[$i][1]

					 EndIf

				   Sleep(25)

				  EndIf

	  Else

		 If Not WinExists($aHwnds[$i][1]) Then

						$aWinPos[$sSearch][2] = "Empty"
		 EndIf


	  EndIf


   Next

	Return $aWinPos

EndFunc
