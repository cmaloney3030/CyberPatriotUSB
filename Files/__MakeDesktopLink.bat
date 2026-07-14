@echo off
set "TargetSrc=C:\Users\Chris2\Desktop\CyberCamp"
set "ShortcutDst=C:\Users\Chris2\Desktop\CyberCamp2.lnk"
set "VBSFile=%temp%\CreateShortcutTemp.vbs"

:: 1. Write the VBScript instructions to a temporary file using ECHO
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBSFile%"
echo sLinkFile = "%ShortcutDst%" >> "%VBSFile%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%VBSFile%"
echo oLink.TargetPath = "%TargetSrc%" >> "%VBSFile%"
echo oLink.Save >> "%VBSFile%"

:: 2. Execute the temporary VBScript using the native Windows Script Host
cscript //nologo "%VBSFile%"

:: 3. Clean up the temporary file
del "%VBSFile%"

echo Shortcut (.lnk file) created successfully!
pause