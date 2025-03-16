:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

:: Display header
echo ===============================================
echo SeCuReDmE Build with IncrediBuild Script
echo ===============================================
echo.

:: Set paths
set "ROOT_DIR=%~dp0"
set "SOLUTION_DIR=%ROOT_DIR%..\CodeProject.AI-Server"
set "SOLUTION_FILE=%SOLUTION_DIR%\CodeProject.AI.sln"
set "INCREDIBUILD_CONFIG=%ROOT_DIR%incredibuild.xml"

:: Check if IncrediBuild is installed
echo Checking for IncrediBuild...
where IBConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: IncrediBuild is not installed or not in PATH.
    echo Please install IncrediBuild from https://www.incredibuild.com/downloads
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
echo IncrediBuild found.

:: Check if solution file exists
echo Solution file found: %SOLUTION_FILE%

echo.
echo ===============================================
echo Configuring IncrediBuild Agent Settings
echo ===============================================

:: Get IncrediBuild mode
echo Checking IncrediBuild mode...
IBConsole /command=GetSettings /name=CoordinatorMachine >temp_settings.txt
findstr /C:"localhost" temp_settings.txt >nul
if %ERRORLEVEL% equ 0 (
    echo IncrediBuild is in standalone mode.
) else (
    echo IncrediBuild is in coordinated mode.
)
del temp_settings.txt

:: Configure system resource allocation
echo Configuring system resource allocation...

:: Set coordinator settings - correct syntax
IBConsole /command=SetSettings /name=MaxCPUs /value=16

:: These were causing errors - fixing with correct command format
:: CPU utilization should use SetSettings with AvoidExcessiveUtilization
IBConsole /command=SetSettings /name=AvoidExcessiveUtilization /value=true
IBConsole /command=SetSettings /name=CpuUtilizationLevel /value=80

:: Memory utilization
IBConsole /command=SetSettings /name=AvoidLowMemory /value=true 
IBConsole /command=SetSettings /name=MinimumFreeMemoryMB /value=4096

:: There's no direct "disk utilization" setting in IncrediBuild
:: Instead, we'll configure the temp path
IBConsole /command=SetSettings /name=TempPath /value="%TEMP%\IncrediBuild_Temp"

echo.
echo ===============================================
echo IncrediBuild Agent Information
echo ===============================================
IBConsole /command=GetHelpers

echo.
echo Getting available solution configurations...
msbuild %SOLUTION_FILE% /pp:temp_solution_info.txt /nologo /v:q /t:_CheckForInvalidConfigurationAndPlatform
findstr /C:"Configuration=" temp_solution_info.txt > configurations.txt
if %ERRORLEVEL% neq 0 (
    echo Unable to get solution configurations.
    set "CONFIG=Release"
    set "PLATFORM=Any CPU"
) else (
    for /f "tokens=2 delims==" %%a in (configurations.txt) do (
        echo Available: %%a
    )
    set "CONFIG=Release"
    set "PLATFORM=Any CPU"
)
del temp_solution_info.txt 2>nul
del configurations.txt 2>nul

echo.
echo ===============================================
echo Building with IncrediBuild
echo ===============================================
echo Configuration: %CONFIG%
echo Platform: %PLATFORM%

:: Build using IncrediBuild
BuildConsole "%SOLUTION_FILE%" /cfg="%CONFIG%|%PLATFORM%" /useenv /out=build_log.txt /ShowTime /ShowAgent /MaxCPUs=16

if %ERRORLEVEL% equ 0 (
    echo.
    echo ===============================================
    echo Build completed successfully!
    echo ===============================================
) else (
    echo.
    echo ===============================================
    echo Build failed with error code %ERRORLEVEL%
    echo See build_log.txt for details.
    echo ===============================================
)

echo.
echo Press any key to exit...
pause > nul
exit /b %ERRORLEVEL%