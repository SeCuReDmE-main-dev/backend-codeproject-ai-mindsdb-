@echo off
echo ===============================================
echo CodeProject AI + MindsDB Integration Launcher
echo ===============================================
echo.

:: Setup environment
setlocal EnableDelayedExpansion

:: Make sure this window stays open even if errors occur
set "KEEP_WINDOW_OPEN=1"

:: Define required ports
set "REQUIRED_PORTS=6000 6001 6002 47334 27017"

:: Function to check if a port is in use and kill the process
:check_and_free_port
echo Checking if port %1 is in use...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%1 .*LISTENING"') do (
    echo Port %1 is in use by PID %%a, attempting to terminate...
    taskkill /F /PID %%a >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo Successfully freed port %1
    ) else (
        echo WARNING: Failed to free port %1, trying to continue anyway...
    )
)
exit /b 0

:: Free all required ports automatically
echo Preparing environment...
echo Checking and freeing required ports...

for %%p in (%REQUIRED_PORTS%) do (
    call :check_and_free_port %%p
)

:: Small delay to ensure ports are fully released
timeout /t 2 /nobreak >nul

:: MongoDB Connection Configuration
echo.
echo ===============================================
echo MongoDB Connection Settings
echo ===============================================
set "MONGODB_URI=mongodb+srv://sennnti:YOUR_PASSWORD_HERE@minds.d33ve.mongodb.net/"
set "MONGODB_DATABASE=minds"

echo Using MongoDB connection: %MONGODB_URI%
echo Database: %MONGODB_DATABASE%

:: Set paths
set "ROOT_DIR=%~dp0.."
set "BASE_DIR=%~dp0"
set "SERVER_DIR=%ROOT_DIR%\CodeProject.AI-Server"
set "SERVER_SRC=%SERVER_DIR%\src\server"
set "MINDSDB_DIR=%BASE_DIR%\MindsDB"
set "APP_SERVER_DIR=%BASE_DIR%\server"
set "NEURAL_DIR=%BASE_DIR%\neural_forecast"

echo.
echo ===============================================
echo Initializing Neural Environment
echo ===============================================
echo.

:: Initialize neural environment
cd /d "%NEURAL_DIR%"
call init_neural_env.bat
if %ERRORLEVEL% neq 0 (
    echo WARNING: Failed to initialize neural environment.
    echo The integration may not work properly.
    echo Trying to continue anyway...
)

echo.
echo ===============================================
echo Setting up MindsDB
echo ===============================================

:: Create MindsDB configuration directory if it doesn't exist
if not exist "%MINDSDB_DIR%" (
    echo Creating MindsDB directory...
    mkdir "%MINDSDB_DIR%"
)

:: Create MindsDB configuration file
echo Creating MindsDB configuration...
set "MINDSDB_CONFIG_FILE=%MINDSDB_DIR%\config.json"

echo {> "%MINDSDB_CONFIG_FILE%"
echo     "api": {>> "%MINDSDB_CONFIG_FILE%"
echo         "http": {>> "%MINDSDB_CONFIG_FILE%"
echo             "host": "127.0.0.1",>> "%MINDSDB_CONFIG_FILE%"
echo             "port": "47334">> "%MINDSDB_CONFIG_FILE%"
echo         },>> "%MINDSDB_CONFIG_FILE%"
echo         "mongodb": {>> "%MINDSDB_CONFIG_FILE%"
echo             "host": "127.0.0.1",>> "%MINDSDB_CONFIG_FILE%"
echo             "port": "27017">> "%MINDSDB_CONFIG_FILE%"
echo         }>> "%MINDSDB_CONFIG_FILE%"
echo     },>> "%MINDSDB_CONFIG_FILE%"
echo     "storage_dir": "./storage",>> "%MINDSDB_CONFIG_FILE%"
echo     "integrations": {>> "%MINDSDB_CONFIG_FILE%"
echo         "mongodb_atlas": {>> "%MINDSDB_CONFIG_FILE%"
echo             "enabled": true,>> "%MINDSDB_CONFIG_FILE%"
echo             "host": "minds.d33ve.mongodb.net",>> "%MINDSDB_CONFIG_FILE%"
echo             "port": 27017,>> "%MINDSDB_CONFIG_FILE%"
echo             "database": "minds",>> "%MINDSDB_CONFIG_FILE%"
echo             "type": "mongodb",>> "%MINDSDB_CONFIG_FILE%"
echo             "federation": {>> "%MINDSDB_CONFIG_FILE%"
echo                 "enabled": true,>> "%MINDSDB_CONFIG_FILE%"
echo                 "sql_api": true,>> "%MINDSDB_CONFIG_FILE%"
echo                 "federated_database": "minds">> "%MINDSDB_CONFIG_FILE%"
echo             }>> "%MINDSDB_CONFIG_FILE%"
echo         }>> "%MINDSDB_CONFIG_FILE%"
echo     }>> "%MINDSDB_CONFIG_FILE%"
echo }>> "%MINDSDB_CONFIG_FILE%"

echo Configuration file created at: %MINDSDB_CONFIG_FILE%

echo.
echo ===============================================
echo Starting MindsDB Server
echo ===============================================
echo.

:: Create a separate batch file for MindsDB to run in a persistent window
set "MINDSDB_BAT=%TEMP%\run_mindsdb_%RANDOM%.bat"
echo @echo off > "%MINDSDB_BAT%"
echo title MindsDB Server >> "%MINDSDB_BAT%"
echo cd /d "%MINDSDB_DIR%" >> "%MINDSDB_BAT%"
echo echo Starting MindsDB Server... >> "%MINDSDB_BAT%"
echo call conda activate SeCuReDmE_env >> "%MINDSDB_BAT%"
echo python -m mindsdb --config="%MINDSDB_CONFIG_FILE%" >> "%MINDSDB_BAT%"
echo echo. >> "%MINDSDB_BAT%"
echo echo =============================================== >> "%MINDSDB_BAT%"
echo echo MindsDB Server has stopped. >> "%MINDSDB_BAT%"
echo echo Press any key to close this window... >> "%MINDSDB_BAT%"
echo pause ^> nul >> "%MINDSDB_BAT%"

:: Launch MindsDB in a separate window that will stay open
start cmd /k "%MINDSDB_BAT%"

:: Wait for MindsDB to start
echo Waiting for MindsDB server to initialize...
timeout /t 8 /nobreak >nul

echo.
echo ===============================================
echo Starting Flask API Server
echo ===============================================
echo.

:: Create a separate batch file for the Flask API server
set "FLASK_BAT=%TEMP%\run_flask_%RANDOM%.bat"
echo @echo off > "%FLASK_BAT%"
echo title Flask API Server >> "%FLASK_BAT%"
echo cd /d "%APP_SERVER_DIR%" >> "%FLASK_BAT%"
echo echo Starting Flask API server... >> "%FLASK_BAT%"
echo call conda activate SeCuReDmE_env >> "%FLASK_BAT%"
echo python -m flask run --port=5000 >> "%FLASK_BAT%"
echo echo. >> "%FLASK_BAT%"
echo echo =============================================== >> "%FLASK_BAT%"
echo echo Flask API server has stopped. >> "%FLASK_BAT%"
echo echo Press any key to close this window... >> "%FLASK_BAT%"
echo pause ^> nul >> "%FLASK_BAT%"

:: Launch Flask API in a separate window that will stay open
start cmd /k "%FLASK_BAT%"

echo.
echo ===============================================
echo Integration Complete
echo ===============================================
echo.
echo Services started in separate windows:
echo.
echo - MindsDB Server: http://localhost:47334
echo - Flask API: http://localhost:5000
echo.
echo Check the respective windows for any error messages.
echo You can close this window once you verify all services are running.
echo.
pause
exit /b 0