:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

echo ===============================================
echo SeCuReDmE Build with IncrediBuild Script
echo ===============================================

:: Check for admin privileges
echo Checking for administrator privileges...
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo This script requires administrator privileges.
    echo Please run as administrator and try again.
    echo.
    echo Right-click the script and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

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
set "ROOT_DIR=c:\Users\jeans\OneDrive\Desktop\SeCuReDmE final\SeCuReDmE-1"
set "SOLUTION_FILE=%ROOT_DIR%\CodeProject.AI-Server\CodeProject.AI.sln"
set "MODULES_DIR=%ROOT_DIR%\CodeProject.AI-Modules"

if not exist "%SOLUTION_FILE%" (
    echo WARNING: Solution file not found at %SOLUTION_FILE%
    echo Running fix_project_files.bat to create it...
    
    if exist "%ROOT_DIR%\mini-app-codeproject-ai-mindsdb\fix_project_files.bat" (
        call "%ROOT_DIR%\mini-app-codeproject-ai-mindsdb\fix_project_files.bat"
        if not exist "%SOLUTION_FILE%" (
            echo ERROR: Could not create solution file. Please check your installation.
            goto keep_window_open
        )
    ) else (
        echo ERROR: fix_project_files.bat not found. Cannot create solution file.
        goto keep_window_open
    )
)

echo Solution file found: %SOLUTION_FILE%

echo.
echo ===============================================
echo Configuring IncrediBuild Agent Settings
echo ===============================================

:: Disable standalone mode - Fixed command format
echo Disabling standalone mode...
"%PROGRAMFILES(X86)%\IncrediBuild\IncrediBuild.exe" /Standalone=Disable

:: Set coordinator in registry directly using reg.exe (requires admin)
echo Setting coordinator ID...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Xoreax\IncrediBuild\Builder" /v "Coordinator" /t REG_SZ /d "%IB_COORDINATOR_ID%" /f

:: Restart IncrediBuild service to apply changes
echo Restarting IncrediBuild service to apply changes...
net stop "IncrediBuild Agent" >nul 2>&1
net start "IncrediBuild Agent" >nul 2>&1
timeout /t 5 /nobreak >nul

:: Configure system resource allocation - Fixed command format
echo Configuring system resource allocation...
"%PROGRAMFILES(X86)%\IncrediBuild\IncrediBuild.exe" /Settings /MaxCores=16
"%PROGRAMFILES(X86)%\IncrediBuild\IncrediBuild.exe" /Settings /AvoidLocal=0

:: Display agent information - Fixed command format
echo.
echo ===============================================
echo IncrediBuild Agent Information
echo ===============================================
"%PROGRAMFILES(X86)%\IncrediBuild\IncrediBuild.exe" /GetAgents

:: Create needed directories if they don't exist
if not exist "%MODULES_DIR%" mkdir "%MODULES_DIR%"

echo.
echo ===============================================
echo Build Options
echo ===============================================
echo 1. Release build (Any CPU)
echo 2. Debug build (Any CPU)
echo 3. Release build (x86)
echo 4. Debug build (x86)
echo 5. Release build (ARM64)
echo 6. Debug build (ARM64)
echo 7. Clean solution
echo 8. Build specific module
echo 9. Build Python MindsDB integration
echo.

choice /C 123456789 /N /M "Select a build option [1-9]: "

set BUILD_CONFIG=Release
if %ERRORLEVEL% EQU 1 set "BUILD_CONFIG=Release|Any CPU"
if %ERRORLEVEL% EQU 2 set "BUILD_CONFIG=Debug|Any CPU"
if %ERRORLEVEL% EQU 3 set "BUILD_CONFIG=Release|x86"
if %ERRORLEVEL% EQU 4 set "BUILD_CONFIG=Debug|x86"
if %ERRORLEVEL% EQU 5 set "BUILD_CONFIG=Release|ARM64"
if %ERRORLEVEL% EQU 6 set "BUILD_CONFIG=Debug|ARM64"
if %ERRORLEVEL% EQU 7 (
    BuildConsole "%SOLUTION_FILE%" /clean /cfg="%BUILD_CONFIG%"
    goto keep_window_open
)
if %ERRORLEVEL% EQU 8 goto build_module
if %ERRORLEVEL% EQU 9 goto build_mindsdb

:: Build the solution - Fixed BuildConsole command format
echo Building solution with configuration: %BUILD_CONFIG%
BuildConsole "%SOLUTION_FILE%" /cfg="%BUILD_CONFIG%" /ShowTime /ShowAgent /Retry=3

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

goto keep_window_open

:build_module
echo.
echo ===============================================
echo Select a module to build:
echo ===============================================
echo 1. SentimentAnalysis
echo 2. PortraitFilter
echo 3. MultiModeLLM
echo 4. All modules
echo.

choice /C 1234 /N /M "Select a module [1-4]: "

if %ERRORLEVEL% EQU 1 (
    set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-SentimentAnalysis"
    set "MODULE_NAME=SentimentAnalysis"
) else if %ERRORLEVEL% EQU 2 (
    set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-PortraitFilter"
    set "MODULE_NAME=PortraitFilter"
) else if %ERRORLEVEL% EQU 3 (
    set "MODULE_DIR=%ROOT_DIR%\CodeProject.AI-MultiModeLLM"
    set "MODULE_NAME=MultiModeLLM"
) else if %ERRORLEVEL% EQU 4 (
    goto build_all_modules
)

:: Check if module directory exists
if not exist "%MODULE_DIR%" (
    echo Creating module directory: %MODULE_DIR%...
    mkdir "%MODULE_DIR%" 2>nul
)

:: Create basic project files if they don't exist
set "PROJECT_FILE=%MODULE_DIR%\%MODULE_NAME%.csproj"
if not exist "%PROJECT_FILE%" (
    echo Creating basic project file for %MODULE_NAME%...
    echo ^<?xml version="1.0" encoding="utf-8"?^>> "%PROJECT_FILE%"
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>>> "%PROJECT_FILE%"
    echo   ^<PropertyGroup^>>> "%PROJECT_FILE%"
    echo     ^<TargetFramework^>net7.0^</TargetFramework^>>> "%PROJECT_FILE%"
    echo   ^</PropertyGroup^>>> "%PROJECT_FILE%"
    echo ^</Project^>>> "%PROJECT_FILE%"
)

echo Building module: %MODULE_NAME%
BuildConsole "%PROJECT_FILE%" /cfg="Release|Any CPU" /ShowTime /ShowAgent

goto keep_window_open

:build_all_modules
echo Building all modules...

setlocal enabledelayedexpansion

for %%m in (SentimentAnalysis PortraitFilter) do (
    set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-%%m"
    set "PROJECT_FILE=!MODULE_DIR!\%%m.csproj"
    
    if not exist "!MODULE_DIR!" (
        echo Creating module directory: !MODULE_DIR!...
        mkdir "!MODULE_DIR!" 2>nul
    )
    
    if not exist "!PROJECT_FILE!" (
        echo Creating basic project file for %%m...
        echo ^<?xml version="1.0" encoding="utf-8"?^>> "!PROJECT_FILE!"
        echo ^<Project Sdk="Microsoft.NET.Sdk"^>>> "!PROJECT_FILE!"
        echo   ^<PropertyGroup^>>> "!PROJECT_FILE!"
        echo     ^<TargetFramework^>net7.0^</TargetFramework^>>> "!PROJECT_FILE!"
        echo   ^</PropertyGroup^>>> "!PROJECT_FILE!"
        echo ^</Project^>>> "!PROJECT_FILE!"
    )
    
    echo Building module: %%m
    BuildConsole "!PROJECT_FILE!" /cfg="Release|Any CPU" /ShowTime /ShowAgent
)

endlocal

:: Build MultiModeLLM separately as it's in a different directory
set "MODULE_DIR=%ROOT_DIR%\CodeProject.AI-MultiModeLLM"
set "PROJECT_FILE=%MODULE_DIR%\MultiModeLLM.csproj"

if not exist "%MODULE_DIR%" (
    echo Creating module directory: %MODULE_DIR%...
    mkdir "%MODULE_DIR%" 2>nul
)

if not exist "%PROJECT_FILE%" (
    echo Creating basic project file for MultiModeLLM...
    echo ^<?xml version="1.0" encoding="utf-8"?^>> "%PROJECT_FILE%"
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>>> "%PROJECT_FILE%"
    echo   ^<PropertyGroup^>>> "%PROJECT_FILE%"
    echo     ^<TargetFramework^>net7.0^</TargetFramework^>>> "%PROJECT_FILE%"
    echo   ^</PropertyGroup^>>> "%PROJECT_FILE%"
    echo ^</Project^>>> "%PROJECT_FILE%"
)

echo Building module: MultiModeLLM
BuildConsole "%PROJECT_FILE%" /cfg="Release|Any CPU" /ShowTime /ShowAgent

goto keep_window_open

:build_mindsdb
echo.
echo Building MindsDB integration...

:: Kill any processes using the required ports before running start_integration
echo Checking for processes using MindsDB ports...
for %%p in (6000 6001 6002 47334 27017) do (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p.*LISTENING"') do (
        echo Found process using port %%p with PID %%a, attempting to terminate...
        taskkill /F /PID %%a >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            echo Successfully freed port %%p
        ) else (
            echo Failed to free port %%p, the integration may fail to start properly.
        )
    )
)

:: Wait a moment for ports to be freed
timeout /t 2 /nobreak >nul

:: Now run start_integration
cd /d "%ROOT_DIR%\mini-app-codeproject-ai-mindsdb"
call start_integration.bat
goto keep_window_open

:keep_window_open
echo.
echo Press any key to close this window...
pause >nul
exit /b %ERRORLEVEL%