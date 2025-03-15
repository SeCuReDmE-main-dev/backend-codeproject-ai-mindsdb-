@echo off
echo ===============================================
echo CodeProject AI + MindsDB Integration Launcher
echo ===============================================
echo.

:: Check if .NET SDK is installed
echo Checking for .NET SDK...
dotnet --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: .NET SDK is not installed or not in PATH.
    echo Please install .NET SDK from https://dotnet.microsoft.com/download
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
echo .NET SDK found.

:: Set paths
set "ROOT_DIR=c:\Users\jeans\OneDrive\Desktop\SeCuReDmE final\SeCuReDmE-1"
set "BASE_DIR=%~dp0"
set "SERVER_DIR=%ROOT_DIR%\CodeProject.AI-Server"
set "SERVER_SRC=%SERVER_DIR%\src\server"
set "MINDSDB_DIR=%BASE_DIR%\MindsDB"
set "APP_SERVER_DIR=%BASE_DIR%\server"
set "MODULES_DIR=%ROOT_DIR%\CodeProject.AI-Modules"
set "SENTIMENT_MODULE=%MODULES_DIR%\CodeProject.AI-SentimentAnalysis"
set "PORTRAIT_MODULE=%MODULES_DIR%\CodeProject.AI-PortraitFilter"
set "MULTIMODELLM_MODULE=%MODULES_DIR%\CodeProject.AI-MultiModeLLM"
set "MICROSERVICES_DIR=%ROOT_DIR%\src\microservices"
set "API_GATEWAY=%ROOT_DIR%\src\api_gateway.py"

echo.
echo ===============================================
echo Launch Options:
echo ===============================================
echo 1. Start CodeProject AI Server
echo 2. Start MindsDB Server
echo 3. Start App CodeProject AI Server
echo 4. Start App MindsDB Server
echo 5. Start SentimentAnalysis Module
echo 6. Start PortraitFilter Module
echo 7. Start MultiModeLLM Module
echo 8. Start Everything (Full Integration)
echo 9. Exit
echo.

choice /C 123456789 /N /M "Select an option [1-9]: "

if %ERRORLEVEL% EQU 1 goto start_codeproject
if %ERRORLEVEL% EQU 2 goto start_mindsdb
if %ERRORLEVEL% EQU 3 goto start_app_codeproject
if %ERRORLEVEL% EQU 4 goto start_app_mindsdb
if %ERRORLEVEL% EQU 5 goto start_sentiment
if %ERRORLEVEL% EQU 6 goto start_portrait
if %ERRORLEVEL% EQU 7 goto start_multimodellm
if %ERRORLEVEL% EQU 8 goto start_all
if %ERRORLEVEL% EQU 9 goto end

:start_codeproject
echo.
echo Starting CodeProject AI Server...
start cmd /k "cd /d %SERVER_SRC% && dotnet run"
goto end

:start_mindsdb
echo.
echo Starting MindsDB Server...
start cmd /k "cd /d %MINDSDB_DIR% && python -m mindsdb"
goto end

:start_app_codeproject
echo.
echo Starting App CodeProject AI Server...
start cmd /k "cd /d %APP_SERVER_DIR% && python codeproject_ai_server.py"
goto end

:start_app_mindsdb
echo.
echo Starting App MindsDB Server...
start cmd /k "cd /d %APP_SERVER_DIR% && python mindsdb_server.py"
goto end

:start_sentiment
echo.
echo Starting SentimentAnalysis Module...
start cmd /k "cd /d %SENTIMENT_MODULE% && dotnet run"
goto end

:start_portrait
echo.
echo Starting PortraitFilter Module...
start cmd /k "cd /d %PORTRAIT_MODULE% && dotnet run"
goto end

:start_multimodellm
echo.
echo Starting MultiModeLLM Module...
start cmd /k "cd /d %MULTIMODELLM_MODULE% && dotnet run"
goto end

:start_all
echo.
echo Starting the full integration...
echo.
echo 1. Starting CodeProject AI Server...
cd /d %SERVER_DIR%
start cmd /k "cd /d %SERVER_SRC% && dotnet run"
timeout /t 10 >nul

echo 2. Starting MindsDB Server...
start cmd /k "cd /d %MINDSDB_DIR% && python -m mindsdb"
timeout /t 10 >nul

echo 3. Starting App CodeProject AI Server...
start cmd /k "cd /d %APP_SERVER_DIR% && python codeproject_ai_server.py"
timeout /t 5 >nul

echo 4. Starting App MindsDB Server...
start cmd /k "cd /d %APP_SERVER_DIR% && python mindsdb_server.py"
timeout /t 5 >nul

echo 5. Starting SentimentAnalysis Module...
start cmd /k "cd /d %SENTIMENT_MODULE% && dotnet run"
timeout /t 3 >nul

echo 6. Starting PortraitFilter Module...
start cmd /k "cd /d %PORTRAIT_MODULE% && dotnet run"
timeout /t 3 >nul

echo 7. Starting MultiModeLLM Module...
start cmd /k "cd /d %MULTIMODELLM_MODULE% && dotnet run"

echo.
echo All components started successfully!
echo.

:end
echo.
echo Press any key to exit the launcher...
pause >nul
exit /b 0