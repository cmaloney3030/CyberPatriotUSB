set USB_DRIVE=%cd%
@setlocal enableextensions enabledelayedexpansion
@echo off

set CyberCampDir=%~1%
set ZippedVM=%~2%

rem copy /Y !ZippedVM! .
if exist "C:\Program Files\7-Zip\7z.exe" (
	"C:\Program Files\7-Zip\7z.exe" x -o"!CyberCampDir!" "!ZippedVM!"
) else (
	"!USB_DRIVE!"\Files\7-ZipPortable\App\7-Zip64\7z.exe x -o"!CyberCampDir!" "!ZippedVM!"
)