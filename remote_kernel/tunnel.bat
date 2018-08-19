@echo off
rem see comment section in accompanying file init.m for instructions
rem created February 2008 by Sascha Kratky, kratky@unisoftwareplus.com

setlocal enabledelayedexpansion

cd /D "%~dp0"

set LOGFILE=%~n0.log

echo. >> %LOGFILE%
echo %COMPUTERNAME% %DATE% %TIME% >> %LOGFILE%
echo "%~0" "%*" >> %LOGFILE%

rem path to PuTTY plink executable, see http://www.putty.org/
if defined ProgramFiles^(x86^) (
	set PLINK_EXE_PATH=%ProgramFiles(x86)%\putty\plink.exe
) else (
	set PLINK_EXE_PATH=%ProgramFiles%\putty\plink.exe
)

rem path to alternate PuTTY plinkw executable from Quest, see http://rc.quest.com/topics/putty/
if defined ProgramFiles^(x86^) (
	set PLINKW_EXE_PATH=%ProgramFiles(x86)%\Quest Software\PuTTY\plinkw.exe
) else (
	set PLINKW_EXE_PATH=%ProgramFiles%\Quest Software\PuTTY\plinkw.exe
)

rem prefer Quest PuTTY plink.exe, as it does not open a console window
rem and allows for redirection of stdout and stderr to log file
set PUTTY_OPTS=-batch -v -ssh -C -x
if exist "%PLINKW_EXE_PATH%" (
	set PUTTY_PATH=%PLINKW_EXE_PATH%
	rem Quest PuTTY supports additional useful options
	set PUTTY_OPTS=%PUTTY_OPTS% -no_in -ng -auto_store_key_in_cache
) else if exist "%PLINK_EXE_PATH%" (
	set PUTTY_PATH=%PLINK_EXE_PATH%
) else (
	echo Error: PuTTY is not installed! >> %LOGFILE%
	exit /B 1
)

set REMOTE_KERNEL_HOST=%~1
set REMOTE_KERNEL_PATH=%~2
set LINK_NAME=%~3

if "%LINK_NAME%"=="" (
	echo Usage: %~nx0 [user[:password]@]host[:port] "path_to_mathematica_kernel" "linkname" >> %LOGFILE%
	exit /B 1
)

rem parse port link name port numbers, e.g., 53994@127.0.0.1,39359@127.0.0.1
for /F "Delims=,@ Tokens=1,2,3" %%S in ("%LINK_NAME%") do (
	set MAIN_LINK_DATA_PORT=%%S
	set MAIN_LINK_HOST=%%T
	set MAIN_LINK_MESSAGE_PORT=%%U
)

if not defined MAIN_LINK_DATA_PORT (
	echo Error: "%LINK_NAME%" is not a properly formatted MathLink TCPIP protocol link name! >> %LOGFILE%
	exit /B 1
)

if not defined MAIN_LINK_MESSAGE_PORT (
	echo Error: "%LINK_NAME%" is not a properly formatted MathLink TCPIP protocol link name! >> %LOGFILE%
	exit /B 1
)

if not "%MAIN_LINK_HOST%"=="127.0.0.1" (
	echo Error: "%LINK_NAME%" does not use the loopback IP address 127.0.0.1! >> %LOGFILE%
	exit /B 1
)

rem parse user credentials from host name
for /F "Delims=@ Tokens=1,2" %%S in ("%REMOTE_KERNEL_HOST%") do (
	set REMOTE_KERNEL_USER=%%S
	set REMOTE_KERNEL_HOST=%%T
)
if not defined REMOTE_KERNEL_HOST (
	set REMOTE_KERNEL_HOST=%REMOTE_KERNEL_USER%
	set REMOTE_KERNEL_USER=
)

rem parse password from user credentials
if defined REMOTE_KERNEL_USER (
	for /F "Delims=: Tokens=1,2" %%S in ("%REMOTE_KERNEL_USER%") do (
		set REMOTE_KERNEL_USER=%%S
		set REMOTE_KERNEL_PASSWORD=%%T
	)
)

rem parse SSH port number from host name
for /F "Delims=: Tokens=1,2" %%S in ("%REMOTE_KERNEL_HOST%") do (
	set REMOTE_KERNEL_HOST=%%S
	set REMOTE_KERNEL_PORT=%%T
)

if "%MAIN_LINK_DATA_PORT%" GEQ "%MAIN_LINK_MESSAGE_PORT%" (
	set BASE_PORT=%MAIN_LINK_DATA_PORT%
) else (
	set BASE_PORT=%MAIN_LINK_MESSAGE_PORT%
)

rem add optional command line options
if defined REMOTE_KERNEL_USER set PUTTY_OPTS=%PUTTY_OPTS% -l "%REMOTE_KERNEL_USER%"
if defined REMOTE_KERNEL_PASSWORD set PUTTY_OPTS=%PUTTY_OPTS% -pw "%REMOTE_KERNEL_PASSWORD%"
if defined REMOTE_KERNEL_PORT set PUTTY_OPTS=%PUTTY_OPTS% -P %REMOTE_KERNEL_PORT%

rem compute port numbers to be used for preemptive and service links
set /a PREEMPTIVE_LINK_DATA_PORT=%BASE_PORT% + 1
set /a PREEMPTIVE_LINK_MESSAGE_PORT=%BASE_PORT% + 2
set /a SERVICE_LINK_DATA_PORT=%BASE_PORT% + 3
set /a SERVICE_LINK_MESSAGE_PORT=%BASE_PORT% + 4

rem log everything
echo REMOTE_KERNEL_HOST=%REMOTE_KERNEL_HOST% >> %LOGFILE%
echo REMOTE_KERNEL_PATH=%REMOTE_KERNEL_PATH% >> %LOGFILE%
if defined REMOTE_KERNEL_USER echo REMOTE_KERNEL_USER=%REMOTE_KERNEL_USER% >> %LOGFILE%
if defined REMOTE_KERNEL_PASSWORD echo REMOTE_KERNEL_PASSWORD=%REMOTE_KERNEL_PASSWORD% >> %LOGFILE%
if defined REMOTE_KERNEL_PORT echo REMOTE_KERNEL_PORT=%REMOTE_KERNEL_PORT% >> %LOGFILE%
echo MAIN_LINK_DATA_PORT=%MAIN_LINK_DATA_PORT% >> %LOGFILE%
echo MAIN_LINK_MESSAGE_PORT=%MAIN_LINK_MESSAGE_PORT% >> %LOGFILE%
echo PREEMPTIVE_LINK_DATA_PORT=%PREEMPTIVE_LINK_DATA_PORT% >> %LOGFILE%
echo PREEMPTIVE_LINK_MESSAGE_PORT=%PREEMPTIVE_LINK_MESSAGE_PORT% >> %LOGFILE%
echo SERVICE_LINK_DATA_PORT=%SERVICE_LINK_DATA_PORT% >> %LOGFILE%
echo SERVICE_LINK_MESSAGE_PORT=%SERVICE_LINK_MESSAGE_PORT% >> %LOGFILE%
echo PUTTY_PATH=%PUTTY_PATH% >> %LOGFILE%
echo PUTTY_OPTS=%PUTTY_OPTS% >> %LOGFILE%

"%PUTTY_PATH%" ^
  >> %LOGFILE% 2>&1 ^
  %PUTTY_OPTS% ^
  -R 127.0.0.1:%MAIN_LINK_DATA_PORT%:127.0.0.1:%MAIN_LINK_DATA_PORT% ^
  -R 127.0.0.1:%MAIN_LINK_MESSAGE_PORT%:127.0.0.1:%MAIN_LINK_MESSAGE_PORT% ^
  -L %PREEMPTIVE_LINK_DATA_PORT%:127.0.0.1:%PREEMPTIVE_LINK_DATA_PORT% ^
  -L %PREEMPTIVE_LINK_MESSAGE_PORT%:127.0.0.1:%PREEMPTIVE_LINK_MESSAGE_PORT% ^
  -L %SERVICE_LINK_DATA_PORT%:127.0.0.1:%SERVICE_LINK_DATA_PORT% ^
  -L %SERVICE_LINK_MESSAGE_PORT%:127.0.0.1:%SERVICE_LINK_MESSAGE_PORT% ^
  "%REMOTE_KERNEL_HOST%" ^
  "%REMOTE_KERNEL_PATH%" -mathlink -LinkMode Connect -LinkProtocol TCPIP -LinkName "%LINK_NAME%"
