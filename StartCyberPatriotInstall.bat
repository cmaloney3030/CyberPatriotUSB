@echo off
setlocal enabledelayedexpansion

:: =====================================================================
:: CONFIGURATION 
:: =====================================================================
set "REPO_RAW_BASE=https://github.com/cmaloney3030/CyberPatriotUSB/raw/main"
set "LOCAL_DIR=%~dp0"
:: =====================================================================
:: Check if the script was just updated and needs cleanup
if "%~1"=="--post-update" (
	echo [94m [0m
	echo [4m[94m===========================================================[0m
	echo [7m[94m   Update successful! Running new version...[0m
	
)

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for updates...[0m

:: 1. Internet & Connectivity Check
curl -L -s --connect-timeout 5 https://raw.githubusercontent.com >nul
if %errorlevel% neq 0 (
	echo [91m   Error: Cannot reach GitHub. Skipping synchronization...[0m
    goto :main_logic
)

echo [92m   Verified Internet Connectivity[0m

:: 2. Download the remote checksum manifest
set "TEMP_MANIFEST=%TEMP%\remote_checksums_%RANDOM%.txt"
curl -L -s -f --connect-timeout 5 "%REPO_RAW_BASE%/checksums.txt" -o "%TEMP_MANIFEST%"

if %errorlevel% neq 0 (
	echo [91m   Error: Could not retrieve checksums.txt from repository.  Skipping synchronization...[0m
    goto :main_logic
)

echo [92m   Successfully downloaded file checksum information[0m

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Syncing: Downloading missing or modified files...[0m

set /p last_updated=<"%LOCAL_DIR%"\Files\.updated
set /p last_updated_counter=<"%LOCAL_DIR%"\Files\.updated_counter

:: 3. PHASE 1: Download & Update (Remote -> Local)
for /f "usebackq tokens=1,*" %%A in ("%TEMP_MANIFEST%") do (
    set "REMOTE_HASH=%%A"
    set "FILENAME=%%B"
	set "FILENAME=!FILENAME:~0,-1!"
    if "!REMOTE_HASH!"=="LAST_UPDATE" (
		echo !newest_timestamp!
		echo !FILENAME! 
		if !FILENAME! == "!last_updated!" (
			set /a "last_updated_counter+=1"
			if !last_updated_counter! GEQ 10 (
				echo 0 > "%LOCAL_DIR%"\Files\.updated_counter
			) else (
				echo !last_updated_counter! > "%LOCAL_DIR%"\Files\.updated_counter
				echo [92m   No need to update !last_updated_counter! [0m
				goto :main_logic
			)
		)
		echo 0 > "%LOCAL_DIR%"\Files\.updated_counter
		echo !FILENAME! > "%LOCAL_DIR%"\Files\.updated
	) else (
		set "LOCAL_FILE=%LOCAL_DIR%!FILENAME!"
		set "LOCAL_HASH=0"
		
		:: Check if local file exists
		if exist "!LOCAL_FILE!" (
			set "HASH_LINE="
			for /f "skip=1 delims=" %%H in ('certutil -hashfile "!LOCAL_FILE!" SHA256 2^>nul') do (
				if not defined HASH_LINE (
					set "RAW_HASH=%%H"
					set "LOCAL_HASH=!RAW_HASH: =!"
					set "HASH_LINE=1"
				)
			)
		)

		:: Compare hashes
		if /i "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
			if "!LOCAL_HASH!"=="0" (
				echo [92m   Downloading new file: !FILENAME![0m
			) else (
				echo [92m   Updating modified file: !FILENAME![0m
			)
			
			:: Ensure subdirectories exist locally if the file path contains folders
			for %%I in ("!LOCAL_FILE!") do if not exist "%%~dpI" mkdir "%%~dpI"
			set "URL=%REPO_RAW_BASE%/!FILENAME:\=/!"
			set "URL=!URL: =%%20!"
			curl -s -L -f "!URL!" -o "!LOCAL_FILE!.tmp"
			if !errorlevel! equ 0 (
				move /y "!LOCAL_FILE!.tmp" "!LOCAL_FILE!" >nul
				if "!LOCAL_FILE!"=="%~f0" (
					start "" "%~f0" --post-update
					del "%TEMP_MANIFEST%" 2>nul
					exit /b
				)
			) else (
				echo [91m   Error downloading !FILENAME!.  Skipping...[0m
				del "!LOCAL_FILE!.tmp" 2>nul
				pause
			)
		)
	)
)

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for untracked files...[0m
:: 4. PHASE 2: Delete Untracked Files (Local -> Remote)
for /r "%LOCAL_DIR%" %%F in (*) do (
    set "FULL_PATH=%%F"
    set "RELATIVE_PATH=!FULL_PATH:%LOCAL_DIR%=!"

    if /i "!FULL_PATH!" neq "%~f0" (
        
        :: Reset tracking variable
        set "IS_TRACKED=0"
        
        :: Read manifest line-by-line to check for an exact, safe string match
        for /f "usebackq tokens=1,*" %%A in ("%TEMP_MANIFEST%") do (		
			set "FILENAME=%%B"
			set "FILENAME=!FILENAME:~0,-1!"
            if /i "!FILENAME!"=="!RELATIVE_PATH!" (
                set "IS_TRACKED=1"
            )
        )
        
        :: If it wasn't found in the manifest, purge it
        if "!IS_TRACKED!"=="0" (
			if "!RELATIVE_PATH:VMS_TO_INSTALL=!"=="!RELATIVE_PATH!" (
				if "!RELATIVE_PATH:System Volume Information=!"=="!RELATIVE_PATH!" (
					echo [-] Deleting untracked file: !RELATIVE_PATH!
					del /f /q "%%F" 2>nul
				)
			)
        )
    )
)
echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for untracked empty folders...[0m

:: 5. PHASE 3: Clean up empty directories
:: Loops backward through directories so child folders are deleted before parents
for /f "delims=" %%D in ('dir "%LOCAL_DIR%" /ad /b /s ^| sort /r') do (
    dir /a /b "%%D" | findstr . >nul
    if !errorlevel! neq 0 (
		echo [92m   Removing empty directory: %%D[0m
        rd "%%D" 2>nul
    )
)

:: Final cleanup of the temp manifest
del "%TEMP_MANIFEST%" 2>nul
echo [92m   Mirror synchronization complete.[0m
echo.

:: =====================================================================
:: MAIN SCRIPT LOGIC
:: =====================================================================
:main_logic
echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Performing CyberPatriot Install...[0m

call Files\CyberPatriotINSTALL.bat

pause
exit