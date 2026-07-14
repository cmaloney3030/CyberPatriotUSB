:: ============Settings==============


set EXTRACTION_PASSWORD=94y758r4gfQQ9

set MIN_SIZE_REQUIRED=25GB

set PROMPT_TO_DELETE_OLD_VMs=1

set PROMPT_TO_DELETE_OLD_CP_ZIPS=1

set INSTALL_DIR_NAME=CyberCamp



:: ============END Settings==========











:: ==============DO NOT MODIFY ANYTHING BELOW THIS LINE==========

@echo OFF
setlocal EnableDelayedExpansion
rem echo [94m [0m
rem echo [4m[94m===========================================================[0m
rem echo [7m[94m   Checking for Virtualization Support...[0m
rem systeminfo | find /i "base virtualization support"  >nul
rem if errorlevel 1 (
rem   echo [91m   Virtualization Support seems to be disabled in the BIOS.[0m
rem   echo [91m   Will continue to install, but you will need to enable it in laptop BIOS before running VMs[0m
rem   pause
rem ) else (
rem   echo [92m   Virtualization Support already enabled in BIOS. [0m
rem )
echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for VMware Workstation or Player...[0m
if not exist "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe" if not exist "C:\Program Files\VMware\VMware Workstation\vmware.exe" (
	if not exist "C:\Program Files (x86)\VMware\VMware Workstation\vmplayer.exe" (
		if not exist "C:\Program Files (x86)\VMware\VMware Player\vmplayer.exe" (
			echo [92m   Need to install VMWare...[0m
			echo [92m   Launching in background. Please wait. [0m
			echo [92m   This might take a few minutes...[0m
			start /wait Files\VMware-workstation-full-17.6.4-24832109.exe /s /v/qn EULAS_AGREED=1 INSTALLDIR="C:\Program Files (x86)\VMware\VMware Workstation\"

			echo [94m [0m
			if not exist "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe" (
				echo [91m   Installaton of VMWare Failed.[0m
				echo [91m   Please install VMWare manually first and try again.[0m
				msg * "Installation Error.  Please check terminal output."
				pause
				exit /b
			) else (
				echo [92m   VMWare Workstation installed successfully[0m
			)
		) else (
			echo [92m   VMWare Player already installed[0m
		)
	) else (
		echo [92m   VMWare Player already installed[0m
	)	
) else (
	echo [92m   VMWare Workstation already installed[0m
)

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for Running VMs...[0m
set VMRUN_LOCATION="C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
set RUNNING_VMS=0
set VMWAREWORKSTATION=1
if not exist !VMRUN_LOCATION! (
		set VMRUN_LOCATION="C:\Program Files (x86)\VMware\VMware Player\vmrun.exe"
		set VMWAREWORKSTATION=0
)
if exist !VMRUN_LOCATION! (
	FOR /F "usebackq" %%i in (`!VMRUN_LOCATION! list ^| findstr vmx`) DO (
		set fullpath=%%~i
		set RUNNING_VMS=1
		echo Found VM Running at !fullpath!
		echo [92m   Attempting to stop...[0m
		!VMRUN_LOCATION! stop !fullpath!		
	)
)
if !RUNNING_VMS!==1 (
	set RUNNING_VMS=0
	FOR /F "usebackq" %%i in (`!VMRUN_LOCATION! list ^| findstr vmx`) DO (
		set RUNNING_VMS=1
	)
	if !RUNNING_VMS!==1 (
		echo [91m   Unable to stop VM.  Please stop it manually before continuing[0m
		exit /b
	) else (
		echo [92m   Successfully stopped all running VMs[0m
	)
) else (
	echo [92m   No running VMs[0m
)

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for running processes...[0m
set PROCESS_RUNNING=
FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmware.exe" /fo csv 2^>NUL ^| find /I "vmware.exe"`) DO SET PROCESS_RUNNING="%%~i"
if not "!PROCESS_RUNNING!"=="" (
	set PROCESS_RUNNING=
	echo VMWare Workstation running.  Attempting to kill...
	taskkill /im vmware.exe /f
	timeout 5
	FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmware.exe" /fo csv 2^>NUL ^| find /I "vmware.exe"`) DO SET PROCESS_RUNNING="%%~i"
	if not "!PROCESS_RUNNING!"=="" (
		echo [91m   Unable to stop VMWare Workstation.  Please stop it manually before continuing[0m
		exit /b
	) else (
		echo [92m   Killed VMWare Workstation[0m
	)
) else (
	echo [92m   VMWare Workstation not running[0m
)
set PROCESS_RUNNING=
FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmplayer.exe" /fo csv 2^>NUL ^| find /I "vmplayer.exe"`) DO SET PROCESS_RUNNING="%%~i"
if not "!PROCESS_RUNNING!"=="" (
	set PROCESS_RUNNING=
	echo VMWare Player running.  Attempting to kill...
	taskkill /im vmplayer.exe /f
	timeout 5
	FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmplayer.exe" /fo csv 2^>NUL ^| find /I "vmplayer.exe"`) DO SET PROCESS_RUNNING="%%~i"
	if not "!PROCESS_RUNNING!"=="" (
		echo [91m   Unable to stop VMWare Player.  Please stop it manually before continuing[0m
		exit /b
	) else (
		echo [92m   Killed VMWare Player[0m
	)
) else (
	echo [92m   VMWare Player not running[0m
)
set PROCESS_RUNNING=

FOR /F "usebackq tokens=3" %%i in (`REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop`) DO SET DESKTOPDIR="%%~i"
CALL set "DESKTOPDIR=!DESKTOPDIR!"
set DESKTOPDIR=!DESKTOPDIR:"=!

set ONEDRIVE_ENABLED=0
set ONEDRIVE_DESKTOP_LOCATION=
set USE_NEW_LOCATION=0

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking if OneDrive Desktop is Enabled...[0m
if /I not "!DESKTOPDIR!"=="%USERPROFILE%\Desktop" (
	set ONEDRIVE_ENABLED=1
	set ONEDRIVE_DESKTOP_LOCATION=!DESKTOPDIR!
	echo [91m   Desktop is not the normal location.  Likely OneDrive Enabled [0m
	echo [91m   Will install VM's on the user's profile desktop and make a link on the OneDrive Desktop [0m
	CALL set "DESKTOPDIR=%USERPROFILE%\Desktop"
)

:INSTALL_LABEL

if !USE_NEW_LOCATION!==1 (
	set "OLD_LOCATION=!DESKTOPDIR!"
	set newLocation=!newLocation:"=!
	if "!newLocation:~-1!"=="\" (
		set newLocation="!newLocation:~0,-1!"
	)
	set "DESKTOPDIR=!newLocation!"
)
echo [94m [0m
echo [4m[95mDesktop located at !DESKTOPDIR![0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking computer for old VMs...[0m
if "!PROMPT_TO_DELETE_OLD_VMs!"=="1" (
	echo [94m [0m
	FOR /F "usebackq delims=" %%i in (`dir /s /b /a:-d "!DESKTOPDIR!\!INSTALL_DIR_NAME!"\*.vmx`) DO (
		set fullpath=%%~i
		set folderpath="%%~dpi"
		if "!fullpath:~-3!"=="vmx" (
			echo Found VM at "!fullpath!"			
			set "removeDIR=Y"	
			set /p "removeDIR= [93m   Would you like to remove this VM? [Y/n][0m?"
			echo [94m [0m
			if "!removeDIR!"=="y" (
                      		set "removeDIR=Y"
			)
			if "!removeDIR!"=="yes" (
                      		set "removeDIR=Y"
			)
			if "!removeDIR!"=="YES" (
                      		set "removeDIR=Y"
			) 
			if "!removeDIR!"=="Yes" (
                      		set "removeDIR=Y"
			) 
			if not "!removeDIR!"=="Y" (
				echo [95m   Keeping VM at "!fullpath!"[0m
			) else (
				echo [95m   Deleting VM at "!fullpath!"[0m
				del /s /q !folderpath!
				rmdir /s /q !folderpath!
			)
			echo [94m [0m
		)
	)
	dir /b /s /a "!DESKTOPDIR!\!INSTALL_DIR_NAME!" | findstr .>nul || (
		del /q /s "!DESKTOPDIR!\!INSTALL_DIR_NAME!"
		rmdir /q "!DESKTOPDIR!\!INSTALL_DIR_NAME!"
	)
	if "!ONEDRIVE_ENABLED!"=="1" (
		FOR /F "usebackq delims=" %%i in (`dir /s /b /a:-d "!ONEDRIVE_DESKTOP_LOCATION!\!INSTALL_DIR_NAME!"\*.vmx`) DO (
			set fullpath=%%~i
			set folderpath="%%~dpi"
			if "!fullpath:~-3!"=="vmx" (
				echo Found VM at "!fullpath!"			
				set "removeDIR=Y"	
				set /p "removeDIR= [93m   Would you like to remove this VM? [Y/n][0m?"
				echo [94m [0m
				if "!removeDIR!"=="y" (
        	              		set "removeDIR=Y"
				)
				if "!removeDIR!"=="yes" (
                	      		set "removeDIR=Y"
				)
				if "!removeDIR!"=="YES" (
                      			set "removeDIR=Y"
				) 
				if "!removeDIR!"=="Yes" (
                	      		set "removeDIR=Y"
				) 
				if not "!removeDIR!"=="Y" (
					echo [95m   Keeping VM at "!fullpath!"[0m
				) else (
					echo [95m   Deleting VM at "!fullpath!"[0m
					del /s /q !folderpath!
					rmdir /s /q !folderpath!
				)
				echo [94m [0m
			)
		)	
		dir /b /s /a "!DESKTOPDIR!\!INSTALL_DIR_NAME!" | findstr .>nul || (
			del /q /s "!DESKTOPDIR!\!INSTALL_DIR_NAME!"
			rmdir /q "!DESKTOPDIR!\!INSTALL_DIR_NAME!"
		)
	)
)
echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking computer for VM zip files...[0m
if "!PROMPT_TO_DELETE_OLD_CP_ZIPS!"=="1" (
	FOR /F "usebackq delims=" %%i in (`dir /s /b /a:-d "!DESKTOPDIR!\!INSTALL_DIR_NAME!"\20*cybercamp*.zip`) DO (
		set fullpath=%%~i
		if "!fullpath:~-3!"=="zip" (
			echo Found possible zip file at "!fullpath!"
			set "remove=Y"			
			set /p "remove= [93m   Would you like to remove this zip file? [Y/n][0m?"
			if "!remove!"=="y" (
                      		set "remove=Y"
			)
			if "!remove!"=="yes" (
                      		set "remove=Y"
			)
			if "!remove!"=="YES" (
                      		set "remove=Y"
			) 
			if "!remove!"=="Yes" (
                      		set "remove=Y"
			) 
			if not "!remove!"=="Y" (
				echo [95m   Keeping zip file at "!fullpath!"[0m
			) else (
				echo [95m   Deleting zip file at "!fullpath!"[0m
				del /q "!fullpath!"
			)
		)
	)
)

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for existance of working directory...[0m

if not exist !DESKTOPDIR! (
	mkdir !DESKTOPDIR!
)
if not exist !DESKTOPDIR!\!INSTALL_DIR_NAME! (
	mkdir !DESKTOPDIR!\!INSTALL_DIR_NAME!
	echo [92m   !DESKTOPDIR!\!INSTALL_DIR_NAME! created[0m
) else (
	echo [92m   !DESKTOPDIR!\!INSTALL_DIR_NAME! already exists[0m
)
if "!ONEDRIVE_ENABLED!"=="1" (
	mklink /D "!ONEDRIVE_DESKTOP_LOCATION!\CyberCamp" !DESKTOPDIR!
)

if "!USE_NEW_LOCATION!"=="1" (
	mklink /D "!OLD_LOCATION!" !DESKTOPDIR!
) else (
	set /A MIN_SIZE_REQUIRED=%MIN_SIZE_REQUIRED:~0,-2%
	echo [94m [0m
	echo [4m[94m===========================================================[0m
	echo [7m[94m   "Verifying computer has at least !MIN_SIZE_REQUIRED! GB of free space..." [0m
	FOR /F "tokens=3 USEBACKQ" %%F IN (`dir /-c /w C:`) DO set "testsize=%%F"
	rem no easy way to determine if the free space is greater than required
	set sizeInGB=!testsize:~0,-9!
	set USE_NEW_LOCATION=0
	if not "!sizeInGB!"=="" if !sizeInGB! lss !MIN_SIZE_REQUIRED! (
		echo [91m   This computer does not have enough free space to install both VMs on the C: Drive...[0m

		set "newLocation=Y"	
		set /p "newLocation= [93m   Would you like to manually specify an installation path (maybe on another drive)? [Y/n][0m"
		echo [94m [0m
		if "!newLocation!"=="y" (
			set "newLocation=Y"
		)
		if "!newLocation!"=="yes" (
			set "newLocation=Y"
		)
		if "!newLocation!"=="YES" (
			set "newLocation=Y"
		) 
		if "!newLocation!"=="Yes" (
			set "newLocation=Y"
		) 
		if "!newLocation!"=="Y" (
			set /p "newLocation= [93m   Enter the path to the location you wish to install to, including drive letter. IE:   D:\    (Press Control-C to cancel)  [0m"
			
			if not exist !newLocation! (
				mkdir !newLocation!
			)
			echo [7m[94m   Verifying computer has at least !MIN_SIZE_REQUIRED! GB of free space at this new location...[0m
			FOR /F "tokens=3 USEBACKQ" %%F IN (`dir /-c /w !newLocation!`) DO set "testsize=%%F"
			set sizeInGB=!testsize:~0,-9!
			if not "!sizeInGB!"=="" if !sizeInGB! lss !MIN_SIZE_REQUIRED! (
				echo [91m   This computer does not have enough free space to install both VMs.  Manual installation will be required...[0m
				pause
				exit /b
			)
			set "USE_NEW_LOCATION=1"
			echo [92m   Computer has !sizeInGB! GB of free space at new location[0m
			goto :INSTALL_LABEL
		) else (
			echo [94m [0m	
			exit /b
		)
	) else (
		echo [92m   Computer has !sizeInGB! GB of free space[0m
	)
)
set USB_DRIVE=%cd%

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Beginning Installation...[0m
echo [95m   Extraction Password: !EXTRACTION_PASSWORD![0m
FOR /F "usebackq delims=" %%i in (`dir /s /b Files\VMS_TO_INSTALL\*.zip`) DO (
		set fullpath=%%~i
		if "!fullpath:~-3!"=="zip" (			
			call !USB_DRIVE!\Files\__InstallCyberPatriotVM.bat "!DESKTOPDIR!\!INSTALL_DIR_NAME!" "!fullpath!" "!EXTRACTION_PASSWORD!"
		)
)

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for running processes...[0m
set PROCESS_RUNNING=
FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmware.exe" /fo csv 2^>NUL ^| find /I "vmware.exe"`) DO SET PROCESS_RUNNING="%%~i"
if not "!PROCESS_RUNNING!"=="" (
	set PROCESS_RUNNING=
	echo VMWare Workstation running.  Attempting to kill...
	taskkill /im vmware.exe /f
	timeout 5
	FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmware.exe" /fo csv 2^>NUL ^| find /I "vmware.exe"`) DO SET PROCESS_RUNNING="%%~i"
	if not "!PROCESS_RUNNING!"=="" (
		echo [91m   Unable to stop VMWare Workstation.  Please stop it manually before continuing[0m
		exit /b
	) else (
		echo [92m   Killed VMWare Workstation[0m
	)
) else (
	echo [92m   VMWare Workstation not running[0m
)
set PROCESS_RUNNING=
FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmplayer.exe" /fo csv 2^>NUL ^| find /I "vmplayer.exe"`) DO SET PROCESS_RUNNING="%%~i"
if not "!PROCESS_RUNNING!"=="" (
	set PROCESS_RUNNING=
	echo VMWare Player running.  Attempting to kill...
	taskkill /im vmplayer.exe /f
	timeout 5
	FOR /F "usebackq" %%i in (`tasklist /fi "ImageName eq vmplayer.exe" /fo csv 2^>NUL ^| find /I "vmplayer.exe"`) DO SET PROCESS_RUNNING="%%~i"
	if not "!PROCESS_RUNNING!"=="" (
		echo [91m   Unable to stop VMWare Player.  Please stop it manually before continuing[0m
		exit /b
	) else (
		echo [92m   Killed VMWare Player[0m
	)
) else (
	echo [92m   VMWare Player not running[0m
)
set PROCESS_RUNNING=

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Registering VMs with VMWare...[0m
if exist "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini" (
	del /q "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
)
if exist "%USERPROFILE%\AppData\Roaming\VMware\inventory.vmls" (
	del /q "%USERPROFILE%\AppData\Roaming\VMware\inventory.vmls"
)
echo .encoding = "windows-1252" > "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
echo pref.lastUpdateCheckSec = "1750005502" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
echo pref.keyboardAndMouse.vmHotKey.enabled = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
echo pref.keyboardAndMouse.vmHotKey.count = "0" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
if !VMWAREWORKSTATION!==1 (
	echo pref.ws.session.window.count = "1" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tab.count = "3" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tab0.dest = "" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tab0.file = "" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tab0.type = "home" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tab0.cnxType = "vmdb" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tab0.focused = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.sidebar = "TRUE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.sidebar.width = "200" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.statusBar = "TRUE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.tabs = "TRUE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.thumbnailBar = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.thumbnailBar.size = "100" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.thumbnailBar.view = "opened-vms" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.placement.left = "104" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.placement.top = "104" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.placement.right = "1544" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.placement.bottom = "857" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	echo pref.ws.session.window0.maximized = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
)
set /a "index=0"
set /a "ws_index=1"
for /F "usebackq delims=" %%a in (`dir "!DESKTOPDIR!\!INSTALL_DIR_NAME!" /s/b ^| findstr .vmx$`) do (
	if !VMWAREWORKSTATION!==1 (
		echo pref.ws.session.window0.tab!ws_index!.dest = "" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		echo pref.ws.session.window0.tab!ws_index!.file = "%%a" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		echo pref.ws.session.window0.tab!ws_index!.type = "vm" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		echo pref.ws.session.window0.tab!ws_index!.cnxType = "vmdb" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		if !ws_index!==1 (
			echo pref.ws.session.window0.tab!ws_index!.focused = "TRUE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		) else (
			echo pref.ws.session.window0.tab!ws_index!.focused = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		)
	) else (
		echo pref.mruVM!index!.filename = "%%a" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"	
		set CAMP_TYPE=CyberCamp
		echo %%a|find "adv_cybercamp" >nul
		if not errorlevel 1 (
			set CAMP_TYPE=Advanced CyberCamp
		)
		echo %%a|find "demo_mint" >nul
		if not errorlevel 1 (
			echo pref.mruVM!index!.displayName = "!CAMP_TYPE! Linux Mint 21 Demo" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		)

		echo %%a|find "demo_win" >nul
		if not errorlevel 1 (
			echo pref.mruVM!index!.displayName = "!CAMP_TYPE! Windows 10 Demo" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		)

		echo %%a|find "comp_mint" >nul
		if not errorlevel 1 (
			echo pref.mruVM!index!.displayName = "!CAMP_TYPE! Linux Mint 21 Competition" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		)

		echo %%a|find "comp_win" >nul
		if not errorlevel 1 (
			echo pref.mruVM!index!.displayName = "!CAMP_TYPE! Windows 10 Competition" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
		)
		echo pref.mruVM!index!.index = "!index!" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
	)
	set /a "index=!index!+1"
	set /a "ws_index=!ws_index!+1"
)
echo hint.loader.mitigations.wsAndFusion = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"
echo hints.hideAll = "FALSE" >> "%USERPROFILE%\AppData\Roaming\VMware\Preferences.ini"

echo [92m   Successfully registered !index! VM(s)[0m

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Launching VMware Workstation or Player...[0m
if exist "C:\Program Files\VMware\VMware Workstation\vmware.exe" (
	start /b "" "C:\Program Files\VMware\VMware Workstation\vmware.exe"
	echo [92m   Successfully launched VMWare Workstation[0m
) else (
	if exist "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe" (
		start /b "" "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
		echo [92m   Successfully launched VMWare Workstation[0m
	) else (
		if exist "C:\Program Files (x86)\VMware\VMware Workstation\vmplayer.exe" (
			start /b "" "C:\Program Files (x86)\VMware\VMware Workstation\vmplayer.exe"
			echo [92m   Successfully launched VMWare Player[0m
		) else (
			if exist "C:\Program Files (x86)\VMware\VMware Player\vmplayer.exe" (
				start /b "" "C:\Program Files (x86)\VMware\VMware Player\vmplayer.exe"
				echo [92m   Successfully launched VMWare Player[0m
			) else (
				echo [91m   Unable to launch VMWare.  Check to make sure it is installed correctly.[0m
				msg * "Installation Completed with errors.  Please check terminal output"
				pause
				exit /b
			)
		)
	)
)
				
msg * "Installation Completed.  You may now safely remove the thumb drive"
pause