:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

:: Display header
echo ===============================================
echo SeCuReDmE Build with IncrediBuild Script
echo ===============================================
echo.

:: Keep window open flag
set "KEEP_WINDOW_OPEN=1"

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

:: Disable standalone mode
echo Disabling standalone mode...
BuildConsole /STANDALONE=Disable

:: Set coordinator mode and settings
echo Setting up coordinator settings...
BuildConsole /AGENT /coordinator="D64EC12F-DE4B-421E-8F43-8D54122889FD"

:: Configure system resource allocation
echo Configuring system resource allocation...
BuildConsole /AGENT /MaxCPUS=80
BuildConsole /AGENT /UseMultiCores=1
BuildConsole /AGENT /AvoidLocal=0
BuildConsole /AGENT /NoWait=1

:: Display agent information
echo.
echo ===============================================
echo IncrediBuild Agent Information
echo ===============================================
BuildConsole /SHOWAGENT

echo.
echo ===============================================
echo Building Solution with IncrediBuild
echo ===============================================

:: Choose build configuration
echo Select build configuration:
echo 1. Release
echo 2. Debug
echo.
choice /C 12 /N /M "Select configuration [1-2]: "

if %ERRORLEVEL% equ 1 (
    set "BUILD_CONFIG=Release"
) else (
    set "BUILD_CONFIG=Debug"
)

:: Build the solution using proper command format
echo.
echo Building solution in %BUILD_CONFIG% configuration...
BuildConsole "%SOLUTION_FILE%" ^
    /cfg="%BUILD_CONFIG%" ^
    /UseMultiCores=1 ^
    /AvoidLocal=0 ^
    /NoWait=1 ^
    /ShowTime ^
    /ShowAgent ^
    /Retry=3

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