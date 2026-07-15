set USB_DRIVE=%cd%
@setlocal enableextensions enabledelayedexpansion
@echo off

set CyberCampDir=%~1%
set ZippedVM=%~2%
set ExtractionPassword=%~3%

if exist "C:\Program Files\7-Zip\7z.exe" (
	if "!ExtractionPassword!"=="" (
		"C:\Program Files\7-Zip\7z.exe" x -o"!CyberCampDir!" "!ZippedVM!"
	) else (
		"C:\Program Files\7-Zip\7z.exe" x -o"!CyberCampDir!" "!ZippedVM!" -p!ExtractionPassword!
	)
) else (
	if "!ExtractionPassword!"=="" (
		"!USB_DRIVE!"\Files\7-ZipPortable\App\7-Zip64\7z.exe x -o"!CyberCampDir!" "!ZippedVM!"
	) else (
		"!USB_DRIVE!"\Files\7-ZipPortable\App\7-Zip64\7z.exe x -o"!CyberCampDir!" "!ZippedVM!" -p!ExtractionPassword!
	)
)