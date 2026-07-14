:: ==============DO NOT MODIFY ANYTHING BELOW THIS LINE==========

@echo OFF
setlocal EnableDelayedExpansion
set SHOULD_PAUSE=%1

echo [94m [0m
echo [4m[94m===========================================================[0m
echo [7m[94m   Checking for Cisco Packet Tracer...[0m
if exist "C:\Program Files\Cisco Packet Tracer 7.2.2\bin\PacketTracer7.exe" (
	echo [92m   Older version of Packet Tracer detected..  Going to remove old one first..[0m
	echo [92m   Launching uninstaller in background. Please wait. [0m
	echo [92m   This might take a few minutes...[0m
	"C:\Program Files\Cisco Packet Tracer 7.2.2\unins000.exe"
	echo [94m [0m
	if not exist "C:\Program Files\Cisco Packet Tracer 7.2.2\bin\PacketTracer7.exe" (
		echo [92m   Old Cisco Packet Tracer uninstalled successfully[0m
	)
)
echo [94m [0m
if not exist "C:\Program Files\Cisco Packet Tracer 8.2.2\bin\PacketTracer.exe" (
	echo [92m   Need to install Cisco Packet Tracer...[0m
	echo [92m   Launching in background. Please wait. [0m
	echo [92m   This might take a few minutes...[0m
	CiscoPacketTracer822_64bit_setup.exe /SP- /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS /SILENT /ICONS

	echo [94m [0m
	if not exist "C:\Program Files\Cisco Packet Tracer 8.2.2\bin\PacketTracer.exe" (
		echo [91m   Installaton of Cisco Packet Tracer Failed.[0m
		echo [91m   Please install Cisco Packet Tracer manually.[0m
		pause
		exit /b
	) else (
		echo [92m   Cisco Packet Tracer installed successfully[0m
		if not "!SHOULD_PAUSE!" == "0" (
			pause
		)
	)
) else (
	echo [92m   Cisco Packet Tracer already installed[0m
	if not "!SHOULD_PAUSE!" == "0" (
		pause
	)
)
