:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

:: Display header
echo ===============================================
echo Build with Incredibuild Script
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
set "SOLUTION_FILE=%ROOT_DIR%\mini-app-codeproject-ai-mindsdb\CodeProject.AI-Server\CodeProject.AI.sln"

:: Check if solution file exists
if not exist "%SOLUTION_FILE%" (
    echo ERROR: Solution file not found at %SOLUTION_FILE%
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Building solution with Incredibuild...
BuildConsole "%SOLUTION_FILE%" /build /cfg="Release|x64" /log="%ROOT_DIR%\build-log.txt"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed. Check the log file at %ROOT_DIR%\build-log.txt for details.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Build completed successfully.
echo Log file: %ROOT_DIR%\build-log.txt
echo.
echo Press any key to exit...
pause > nul
exit /b 0