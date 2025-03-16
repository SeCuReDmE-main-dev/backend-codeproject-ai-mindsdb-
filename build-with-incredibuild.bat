:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

:: Display header
echo ===============================================
echo SeCuReDmE Build with Incredibuild Script
echo ===============================================
echo.

:: Check if Incredibuild is installed
echo Checking for Incredibuild...
where BuildConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Incredibuild is not installed or not in PATH.
    echo Please install Incredibuild and try again.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
echo Incredibuild found.

:: Set paths
set "ROOT_DIR=c:\Users\jeans\OneDrive\Desktop\SeCuReDmE final\SeCuReDmE-1"
set "BASE_DIR=%~dp0"
set "SOLUTION_DIR=%ROOT_DIR%\CodeProject.AI-Server"
set "SOLUTION_FILE=%SOLUTION_DIR%\CodeProject.AI.sln"
set "XML_CONFIG=%BASE_DIR%incredibuild.xml"
set "BUILD_LOG=%ROOT_DIR%\build-log.txt"
set "MODULES_DIR=%ROOT_DIR%\CodeProject.AI-Modules"

:: Check if solution file exists
if not exist "%SOLUTION_FILE%" (
    echo WARNING: Main solution file not found at %SOLUTION_FILE%
    echo Checking alternative solution location...
    set "SOLUTION_FILE=%BASE_DIR%CodeProject.AI-Server\CodeProject.AI.sln"
    
    if not exist "%SOLUTION_FILE%" (
        echo ERROR: Solution file not found at alternate location either.
        echo Checking if fix_project_files.bat exists...
        
        if exist "%BASE_DIR%fix_project_files.bat" (
            echo Running fix_project_files.bat to create project files...
            call "%BASE_DIR%fix_project_files.bat"
            
            if not exist "%SOLUTION_FILE%" (
                echo ERROR: Could not create solution file. Please check your installation.
                echo Press any key to exit...
                pause > nul
                exit /b 1
            )
        ) else (
            echo ERROR: fix_project_files.bat not found. Cannot create solution file.
            echo Press any key to exit...
            pause > nul
            exit /b 1
        )
    )
)

echo Solution file found: %SOLUTION_FILE%

:: Check for XML configuration file
if not exist "%XML_CONFIG%" (
    echo WARNING: Incredibuild XML configuration not found at %XML_CONFIG%
    echo Creating default XML configuration...
    
    echo ^<?xml version="1.0" encoding="UTF-8"?^>> "%XML_CONFIG%"
    echo ^<BuildConsole^>>> "%XML_CONFIG%"
    echo   ^<Profile^>>> "%XML_CONFIG%"
    echo     ^<ProfileName^>CodeProject AI-MindsDB Build^</ProfileName^>>> "%XML_CONFIG%"
    echo     ^<MaxCores^>0^</MaxCores^>>> "%XML_CONFIG%"
    echo     ^<MaxCoresLocal^>4^</MaxCoresLocal^>>> "%XML_CONFIG%"
    echo     ^<AvoidLocalExecution^>false^</AvoidLocalExecution^>>> "%XML_CONFIG%"
    echo     ^<CopyFilesToCoordinator^>false^</CopyFilesToCoordinator^>>> "%XML_CONFIG%"
    echo     ^<CopyFilesFromCoordinator^>false^</CopyFilesFromCoordinator^>>> "%XML_CONFIG%"
    echo     ^<AvoidNetworkAccess^>false^</AvoidNetworkAccess^>>> "%XML_CONFIG%"
    echo     ^<Environment^>>> "%XML_CONFIG%"
    echo       ^<Variable Name="PATH" Value="%%PATH%%" /^>>> "%XML_CONFIG%"
    echo     ^</Environment^>>> "%XML_CONFIG%"
    echo   ^</Profile^>>> "%XML_CONFIG%"
    echo ^</BuildConsole^>>> "%XML_CONFIG%"
)

:: Configure Incredibuild agent settings
echo.
echo ===============================================
echo Configuring Incredibuild Agent Settings
echo ===============================================

echo Checking current agent configuration...
ibconsole /getconfig > "%TEMP%\ib_config_temp.txt"

:: Configure Incredibuild agents
echo Configuring Incredibuild agents...
ibconsole /command=setcoordavail /state=enable

:: Set agent memory allocation (4GB)
ibconsole /command=setagentparam /param=MaximumAvailableMemory /value=4096

:: Set CPU utilization (default 80%)
ibconsole /command=setagentparam /param=CPUUtilization /value=80

:: Set idle timeout (5 minutes)
ibconsole /command=setagentparam /param=IdleTimeout /value=300

:: Allow only local network agents
ibconsole /command=setagentparam /param=AllowWANAgents /value=0

:: Display build agent statistics
echo.
echo ===============================================
echo Incredibuild Agent Statistics
echo ===============================================
ibconsole /command=getavailableagents

echo.
echo ===============================================
echo Build Options
echo ===============================================
echo 1. Release build (x64)
echo 2. Debug build (x64)
echo 3. Release build (Any CPU)
echo 4. Debug build (Any CPU)
echo 5. Clean solution
echo 6. Build specific module
echo.

choice /C 123456 /N /M "Select a build option [1-6]: "

if %ERRORLEVEL% EQU 1 set "BUILD_CONFIG=Release|x64"
if %ERRORLEVEL% EQU 2 set "BUILD_CONFIG=Debug|x64"
if %ERRORLEVEL% EQU 3 set "BUILD_CONFIG=Release|Any CPU"
if %ERRORLEVEL% EQU 4 set "BUILD_CONFIG=Debug|Any CPU"
if %ERRORLEVEL% EQU 5 goto clean_solution
if %ERRORLEVEL% EQU 6 goto build_module

echo.
echo Starting build with configuration: %BUILD_CONFIG%
echo.

:: Build solution with Incredibuild using XML profile
echo Building solution with Incredibuild...
BuildConsole "%SOLUTION_FILE%" /build /cfg="%BUILD_CONFIG%" /useenv /profile="%XML_CONFIG%" /log="%BUILD_LOG%" /MaxCPUs=16

if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed. Check the log file at %BUILD_LOG% for details.
    echo Press any key to continue...
    pause > nul
) else (
    echo Build completed successfully.
    echo Log file: %BUILD_LOG%
    echo.
)

:: Check if release builds need to be copied to deployment location
if "%BUILD_CONFIG:~0,7%"=="Release" (
    echo Do you want to copy the release build to deployment location? (Y/N)
    choice /C YN /N
    if %ERRORLEVEL% EQU 1 (
        echo Copying release build to deployment location...
        xcopy /E /Y /I "%SOLUTION_DIR%\bin\Release\*.*" "%ROOT_DIR%\deployment\"
        echo Copy completed.
    )
)

goto end

:clean_solution
echo Cleaning solution...
BuildConsole "%SOLUTION_FILE%" /clean /cfg="Release|x64" /useenv /log="%BUILD_LOG%"
echo Solution cleaned. Log file: %BUILD_LOG%
goto end

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

if %ERRORLEVEL% EQU 1 set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-SentimentAnalysis"
if %ERRORLEVEL% EQU 2 set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-PortraitFilter"
if %ERRORLEVEL% EQU 3 set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-MultiModeLLM"
if %ERRORLEVEL% EQU 4 goto build_all_modules

:: Check if module directory exists
if not exist "%MODULE_DIR%" (
    echo ERROR: Module directory not found at %MODULE_DIR%
    goto end
)

:: Find project file in module directory
for /r "%MODULE_DIR%" %%f in (*.csproj) do (
    set "PROJECT_FILE=%%f"
    goto found_project
)
echo ERROR: No project file found in %MODULE_DIR%
goto end

:found_project
echo Building module with project file: %PROJECT_FILE%

:: Choose build configuration for module
echo.
echo Select build configuration:
echo 1. Release (x64)
echo 2. Debug (x64)
echo.

choice /C 12 /N /M "Select configuration [1-2]: "

if %ERRORLEVEL% EQU 1 set "MODULE_CONFIG=Release|x64"
if %ERRORLEVEL% EQU 2 set "MODULE_CONFIG=Debug|x64"

echo Building module with configuration: %MODULE_CONFIG%
BuildConsole "%PROJECT_FILE%" /build /cfg="%MODULE_CONFIG%" /useenv /profile="%XML_CONFIG%" /log="%BUILD_LOG%"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Module build failed. Check the log file at %BUILD_LOG% for details.
) else (
    echo Module build completed successfully.
)

goto end

:build_all_modules
echo Building all modules...

:: Find all project files in modules directory
set "FOUND_PROJECTS=0"
for /r "%MODULES_DIR%" %%f in (*.csproj) do (
    set /a FOUND_PROJECTS+=1
    echo Building %%f...
    BuildConsole "%%f" /build /cfg="Release|x64" /useenv /profile="%XML_CONFIG%" /log="%BUILD_LOG%.%%~nf"
    
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Build of %%f failed. Check the log for details.
    ) else (
        echo Build of %%f completed successfully.
    )
)

if %FOUND_PROJECTS% EQU 0 (
    echo No project files found in modules directory.
) else (
    echo All modules build complete.
)

:end
:: Reset the Incredibuild agent settings to default if needed
echo.
echo Do you want to reset Incredibuild agent settings to default? (Y/N)
choice /C YN /N
if %ERRORLEVEL% EQU 1 (
    echo Resetting Incredibuild agent settings to default...
    ibconsole /command=resetconfig
    echo Settings reset to default.
)

echo.
echo ===============================================
echo Build process complete
echo ===============================================
echo Press any key to exit...
pause > nul
exit /b 0