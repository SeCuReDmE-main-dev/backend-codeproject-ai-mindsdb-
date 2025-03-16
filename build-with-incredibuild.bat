:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

:: Display header
echo ===============================================
echo SeCuReDmE Build with IncrediBuild Script
echo ===============================================
echo.

:: Keep window open flag
set "KEEP_WINDOW_OPEN=1"

:: Set coordinator ID
set "IB_COORDINATOR_ID=D64EC12F-DE4B-421E-8F43-8D54122889FD"

:: Check for IncrediBuild
echo Checking for IncrediBuild...
where BuildConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: IncrediBuild not found in PATH
    echo Please install IncrediBuild and try again
    goto keep_window_open
)
echo IncrediBuild found.

:: Find solution file
set "SOLUTION_FILE=c:\Users\jeans\OneDrive\Desktop\SeCuReDmE final\SeCuReDmE-1\CodeProject.AI-Server\CodeProject.AI.sln"
if not exist "%SOLUTION_FILE%" (
    echo ERROR: Solution file not found: %SOLUTION_FILE%
    goto keep_window_open
)
echo Solution file found: %SOLUTION_FILE%

echo.
echo ===============================================
echo Configuring IncrediBuild Agent Settings
echo ===============================================

:: Disable standalone mode using registry
echo Disabling standalone mode...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Xoreax\IncrediBuild\Builder" /v "Standalone" /t REG_DWORD /d 0 /f

:: Set coordinator in registry
echo Setting coordinator ID...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Xoreax\IncrediBuild\Builder" /v "Coordinator" /t REG_SZ /d "%IB_COORDINATOR_ID%" /f

:: Configure system resource allocation
echo Configuring system resource allocation...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Xoreax\IncrediBuild\Builder" /v "MaxCPUS" /t REG_DWORD /d 80 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Xoreax\IncrediBuild\Builder" /v "MaxMemory" /t REG_DWORD /d 4096 /f

:: Restart IncrediBuild Agent to apply changes
echo Restarting IncrediBuild Agent...
net stop "IncrediBuild Agent" >nul 2>&1
net start "IncrediBuild Agent" >nul 2>&1

:: Wait for agent to restart
timeout /t 5 /nobreak > nul

:: Display agent information
echo.
echo ===============================================
echo IncrediBuild Agent Information
echo ===============================================
BuildConsole /SHOWAGENT

echo.
echo ===============================================
echo Building Solution
echo ===============================================

:: Build the solution
echo Building solution...
BuildConsole "%SOLUTION_FILE%" /cfg="Release" /UseIDEMonitor /ShowTime /ShowAgent /OpenMonitor /Retry=3

if %ERRORLEVEL% equ 0 (
    echo.
    echo ===============================================
    echo Build completed successfully!
    echo ===============================================
) else (
    echo.
    echo ===============================================
    echo Build failed with error code: %ERRORLEVEL%
    echo ===============================================
)

:keep_window_open
echo.
echo Press any key to close this window...
pause >nul
exit /b %ERRORLEVEL%