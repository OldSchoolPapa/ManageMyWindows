# ManageMyWindows
AutoIT Script To Tile/Cascade Windows / Poker Tables compatible with Win10
(The Script will still evolve in futur) 

How to install :
- Download the file i provide and unzip it on your desktop or any other place you want.
- Use your favorite Web Search Engine and look for "Autoit"
- Once on the official autoit web page go to the download section click on download Autoit (The one including Autoit, Autoit2Exe and Basic SciTE editor)
- Run the installation and use the default install options (Don't try to improvise unless you know what you doing)
- Once installed reboot your computer
- Then open the folder you decompressed and right click on ManageMyWindow.au3
- Run Script(x86) to run it directly or CompileScript(x86) if you want an executable file.
- That's it ! Enjoy!

Note : If your default hard drive letter isn't C:\ go to the Lib folder and right click on ParentContainer.au3 and Edit Script
Then replace all the includes path drive letters by yours.
(Exemple #include <C:\Program Files (x86)\AutoIt3\Include\Array.au3> by #include <Z:\Program Files (x86)\AutoIt3\Include\Array.au3>)
Also if your Poker Client Run with Admin Rights, You have to Compile the Script and run it As Admin.

How to use it :
- Open a window or a poker table and resize it the way you want it to be
- Click on Get Size button and type partially the name of the window (exemple: no limit or play money) then OK button
- If the window was well detected you will see The Window size and client size input boxes with the size in pixel of your window
- Then replace the Title Bar(s) input box text by the partial name of your window (same name you used for the size detection) 
- Click on Tile or Cascade radio button
- Select one screen or the different screen you wanna use by clicking on the checkboxes
- If your Win10 taskbar is in auto hide mode click on Win Taskbar is auto Hidden
- If you want to remove the titlebard of Pstars poker tables click on Use Container GUI
- If you want next time you use the script to remember the setup of the windows/client size and title bar partial name click on Save Setup
- To just try once the setup and layout click on RunOnce, To Tile every window and futur opened windows click on AutoMode

There's few more options you can use:
- H Space Btw Tiles 
- V Space Btw Tiles
Names are obvious but i'll explain. It's a way to add Horizontal or Vertical Space in Pixel between Tiled windows
-Cascade Inc is the Space in Pixel between Windows
-Space_Btw_Cascade_Rows is the Space in Pixel between Rows of Cascade

Important Note : If you use the Container GUI and click on RunOnce , before to use Auto Mode close the poker tables else they will overlap with the new ones and since you cannot move a table that has no titlebar/borders you might get in troubles by not following my advice.

Futur updates :
- Keyboard Shortcuts (Those who can't wait can look at HotKeySet in AutoIT help File)
- Slots to Stack Tables and to move them from one to an other one with keyboard shortcuts
- There's also plenty code optimisation to do (i see atleast 5 of them possible to do)

#Changes V1.10 :
- Container Gui as parent had been removed , instead when removing TitleBars & Borders the windows are redrawed using GDI+
- Script is more performing and less ressources consuming
  Happy New Year !!!
