@echo off
echo ===============================================
echo CodeProject AI + MindsDB Integration Launcher
echo ===============================================
echo.

:: Setup environment
setlocal EnableDelayedExpansion

:: Define required ports
set "REQUIRED_PORTS=6000 6001 6002 47334 27017"
set "PORT_IN_USE=0"

:: Function to check if a port is in use
:check_port
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%1 .*LISTENING"') do (
    echo Port %1 is in use by PID %%a
    exit /b 1
)
exit /b 0

:: Check all required ports first
echo Checking required ports...
for %%p in (%REQUIRED_PORTS%) do (
    call :check_port %%p
    if !ERRORLEVEL! neq 0 set "PORT_IN_USE=1"
)

:: If any port is in use, ask to free them
if "%PORT_IN_USE%"=="1" (
    echo.
    echo One or more required ports are in use.
    set /p FREE_PORTS="Would you like to free these ports automatically? (Y/N): "
    if /i "!FREE_PORTS!"=="Y" (
        echo.
        echo Freeing ports...
        for %%p in (%REQUIRED_PORTS%) do (
            call :free_port %%p
        )
    ) else (
        echo.
        echo Please close the applications using these ports and try again.
        echo Press any key to exit...
        pause > nul
        exit /b 1
    )
) else (
    echo All required ports are available.
)

:: MongoDB Connection Configuration
echo.
echo ===============================================
echo MongoDB Connection Settings
echo ===============================================
set "MONGODB_URI=mongodb+srv://sennnti:YOUR_PASSWORD_HERE@minds.d33ve.mongodb.net/"
set "MONGODB_DATABASE=minds"

echo Using MongoDB connection: %MONGODB_URI%
echo Database: %MONGODB_DATABASE%

echo.
echo ===============================================
echo Starting CodeProject AI Server...
echo ===============================================

:: Add your CodeProject AI startup code here
echo Starting CodeProject AI Server on port 6000...
:: Example: cd path\to\codeproject-ai && start python server.py

echo.
echo ===============================================
echo Starting MindsDB Server...
echo ===============================================

:: Create MindsDB configuration file with MongoDB connection
echo Creating MindsDB configuration...

set "MINDSDB_CONFIG_DIR=%~dp0MindsDB"
set "MINDSDB_CONFIG_FILE=%MINDSDB_CONFIG_DIR%\config.json"

echo {
echo     "api": {
echo         "http": {
echo             "host": "127.0.0.1",
echo             "port": "47334"
echo         },
echo         "mongodb": {
echo             "host": "127.0.0.1",
echo             "port": "27017"
echo         }
echo     },
echo     "storage_dir": "./storage",
echo     "integrations": {
echo         "mongodb_atlas": {
echo             "enabled": true,
echo             "host": "minds.d33ve.mongodb.net",
echo             "port": 27017,
echo             "database": "%MONGODB_DATABASE%",
echo             "type": "mongodb",
echo             "federation": {
echo                 "enabled": true,
echo                 "sql_api": true,
echo                 "federated_database": "%MONGODB_DATABASE%"
echo             }
echo         }
echo     }
echo } > "%MINDSDB_CONFIG_FILE%"

echo Configuration file created at: %MINDSDB_CONFIG_FILE%

:: Start MindsDB with the configuration file
echo Starting MindsDB Server on port 47334...
cd /d "%MINDSDB_CONFIG_DIR%" && python -m mindsdb --config="%MINDSDB_CONFIG_FILE%"

echo.
echo Integration services started successfully!
echo.
echo - CodeProject AI is running on http://localhost:6000
echo - MindsDB is running on http://localhost:47334
echo - MongoDB is connected to %MONGODB_URI%
echo.
echo Press Ctrl+C in each terminal window to stop the services.
exit /b 0

:free_port
:: Usage: call :free_port port_number
set "port=%~1"
set "temp_file=%temp%\port_check_%random%.txt"
netstat -an | findstr /R /C:":%port% .*LISTENING" > "%temp_file%"
for /f "tokens=5" %%a in ('type "%temp_file%"') do set "pid=%%a"
del "%temp_file%" 2>nul
if defined pid (
    for /f "tokens=1,2" %%a in ('tasklist /fi "PID eq !pid!" ^| findstr /i "!pid!"') do (
        set "process_name=%%a"
    )
    echo Terminating !process_name! (PID: !pid!) on port %port%...
    taskkill /F /PID !pid! >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo Successfully freed port %port%
    ) else (
        echo Failed to free port %port%. You may need to close the application manually.
    )
)
exit /b 0

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

:: Check and activate Conda environment
echo Checking Conda environment...
where conda >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Conda is not installed or not in PATH.
    echo Please install Conda and try again.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

call conda.bat activate SeCuReDmE_env
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to activate SeCuReDmE_env Conda environment.
    echo Please ensure the environment is created and properly configured.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
echo SeCuReDmE_env activated successfully.

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

:: Add new hub paths
set "HIPPOCAMPUS_DIR=%MICROSERVICES_DIR%\hippocampus_hub"
set "CORPUS_CALLOSUM_DIR=%MICROSERVICES_DIR%\corpus_callosum_hub"
set "PREFRONTAL_CORTEX_DIR=%MICROSERVICES_DIR%\prefrontal_cortex_hub"
set "CELEBRUM_DIR=%MICROSERVICES_DIR%\celebrum_hub"
set "SENNTI_DIR=%MICROSERVICES_DIR%\sennti_hub"
set "EBAAZ_DIR=%MICROSERVICES_DIR%\ebaaz_hub"
set "NEUURO_DIR=%MICROSERVICES_DIR%\neuuro_hub"
set "REAASN_DIR=%MICROSERVICES_DIR%\reaasn_hub"

:: Core Services (6000-6009) - Moved from 5000 range to avoid conflicts
set "CODEPROJECT_PORT=6000"
set "APP_CODEPROJECT_PORT=6001"
set "APP_MINDSDB_PORT=6002"

:: Hub Services (6010-6019) - Moved from 5010 range to avoid conflicts
set "CELEBRUM_PORT=6010"
set "SENNTI_PORT=6011"
set "EBAAZ_PORT=6012"
set "NEUURO_PORT=6013"
set "REAASN_PORT=6014"
set "HIPPOCAMPUS_PORT=6015"
set "CORPUS_CALLOSUM_PORT=6016"
set "PREFRONTAL_CORTEX_PORT=6017"

:: Database Services (Use existing instances)
set "REDIS_PORT=6379"      :: Using existing Redis instance
set "MONGODB_PORT=27017"   :: Using existing MongoDB instance
set "MINDSDB_PORT=47334"   :: MindsDB port
set "RABBITMQ_PORT=5673"   :: Changed from 5672 to avoid conflict with existing RabbitMQ

:: Set MindsDB master configuration path
set "MINDSDB_CONFIG_PATH=%BASE_DIR%\MindsDB"
set "MINDSDB_CONFIG=%MINDSDB_CONFIG_PATH%\config.json"

:: Verify directories exist
echo Checking required directories...
if not exist "%SERVER_DIR%" (
    echo ERROR: CodeProject AI Server directory not found at: %SERVER_DIR%
    goto error_exit
)
if not exist "%MINDSDB_DIR%" (
    echo ERROR: MindsDB directory not found at: %MINDSDB_DIR%
    goto error_exit
)
if not exist "%APP_SERVER_DIR%" (
    echo ERROR: App Server directory not found at: %APP_SERVER_DIR%
    goto error_exit
)
if not exist "%SENTIMENT_MODULE%" (
    echo ERROR: Sentiment Analysis module not found at: %SENTIMENT_MODULE%
    goto error_exit
)
if not exist "%PORTRAIT_MODULE%" (
    echo ERROR: Portrait Filter module not found at: %PORTRAIT_MODULE%
    goto error_exit
)
if not exist "%MULTIMODELLM_MODULE%" (
    echo ERROR: MultiModeLLM module not found at: %MULTIMODELLM_MODULE%
    goto error_exit
)
if not exist "%HIPPOCAMPUS_DIR%" (
    echo ERROR: Hippocampus hub directory not found at: %HIPPOCAMPUS_DIR%
    goto error_exit
)
if not exist "%CORPUS_CALLOSUM_DIR%" (
    echo ERROR: Corpus Callosum hub directory not found at: %CORPUS_CALLOSUM_DIR%
    goto error_exit
)
if not exist "%PREFRONTAL_CORTEX_DIR%" (
    echo ERROR: Prefrontal Cortex hub directory not found at: %PREFRONTAL_CORTEX_DIR%
    goto error_exit
)

echo All required directories found.
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
echo 8. Start All Hub Services
echo 9. Start Everything (Full Integration)
echo 0. Exit
echo.

choice /C 1234567890 /N /M "Select an option [0-9]: "

if %ERRORLEVEL% EQU 1 goto start_codeproject
if %ERRORLEVEL% EQU 2 goto start_mindsdb
if %ERRORLEVEL% EQU 3 goto start_app_codeproject
if %ERRORLEVEL% EQU 4 goto start_app_mindsdb
if %ERRORLEVEL% EQU 5 goto start_sentiment
if %ERRORLEVEL% EQU 6 goto start_portrait
if %ERRORLEVEL% EQU 7 goto start_multimodellm
if %ERRORLEVEL% EQU 8 goto start_all_hubs
if %ERRORLEVEL% EQU 9 goto start_all
if %ERRORLEVEL% EQU 0 goto end

:verify_service
:: Usage: call :verify_service <port> <service_name>
curl -f http://localhost:%~1/health 2>nul >nul
if %ERRORLEVEL% neq 0 (
    echo Waiting for %~2 to start on port %~1...
    timeout /t 2 >nul
    goto verify_service
)
echo %~2 is ready on port %~1.
exit /b 0

:verify_and_start_service
:: Usage: call :verify_and_start_service port service_name command
set "port=%~1"
set "service_name=%~2"
set "command=%~3"

call :check_port %port%
if !errorlevel! equ 1 (
    choice /C YN /N /M "Port %port% is in use. Terminate the process? (Y/N) "
    if !errorlevel! equ 1 (
        call :kill_process_on_port %port%
        if !errorlevel! equ 1 (
            echo Failed to free port %port%. Please resolve manually.
            goto error_exit
        )
    ) else (
        echo Cannot start %service_name% - port %port% is in use
        goto error_exit
    )
)

start cmd /k "%command%"
call :verify_service %port% "%service_name%"
exit /b 0

:start_codeproject
echo.
echo Starting CodeProject AI Server...
call :verify_and_start_service %CODEPROJECT_PORT% "CodeProject AI Server" "cd /d %SERVER_SRC% && dotnet run"
goto end

:start_mindsdb
echo.
echo Starting MindsDB Server...
call :verify_and_start_service %MINDSDB_PORT% "MindsDB Server" "call conda.bat activate SeCuReDmE_env && cd /d %MINDSDB_DIR% && python -m mindsdb --config=%MINDSDB_CONFIG%"
goto end

:start_app_codeproject
echo.
echo Starting App CodeProject AI Server...
call :verify_and_start_service %APP_CODEPROJECT_PORT% "App CodeProject AI Server" "call conda.bat activate SeCuReDmE_env && cd /d %APP_SERVER_DIR% && python codeproject_ai_server.py"
goto end

:start_app_mindsdb
echo.
echo Starting App MindsDB Server...
call :verify_and_start_service %APP_MINDSDB_PORT% "App MindsDB Server" "call conda.bat activate SeCuReDmE_env && cd /d %APP_SERVER_DIR% && python mindsdb_server.py"
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

:start_all_hubs
echo.
echo Starting all hub services...
call :verify_and_start_service %CELEBRUM_PORT% "CeLeBrUm Hub" "call conda.bat activate SeCuReDmE_env && cd /d %CELEBRUM_DIR% && python codeproject_ai_server.py --port=%CELEBRUM_PORT%"
call :verify_and_start_service %SENNTI_PORT% "SenNnT-i Hub" "call conda.bat activate SeCuReDmE_env && cd /d %SENNTI_DIR% && python mindsdb_server.py --port=%SENNTI_PORT%"
call :verify_and_start_service %EBAAZ_PORT% "EbaAaZ Hub" "call conda.bat activate SeCuReDmE_env && cd /d %EBAAZ_DIR% && python yolo_model.py"
call :verify_and_start_service %NEUURO_PORT% "NeuUuR-o Hub" "call conda.bat activate SeCuReDmE_env && cd /d %NEUURO_DIR% && python h2o_3_automl.py"
call :verify_and_start_service %REAASN_PORT% "ReaAaS-n Hub" "call conda.bat activate SeCuReDmE_env && cd /d %REAASN_DIR% && python byom_function.py"
call :verify_and_start_service %HIPPOCAMPUS_PORT% "Hippocampus Hub" "call conda.bat activate SeCuReDmE_env && cd /d %HIPPOCAMPUS_DIR% && python db_manager.py"
call :verify_and_start_service %CORPUS_CALLOSUM_PORT% "Corpus Callosum Hub" "call conda.bat activate SeCuReDmE_env && cd /d %CORPUS_CALLOSUM_DIR% && python quantum_ops.py"
call :verify_and_start_service %PREFRONTAL_CORTEX_PORT% "Prefrontal Cortex Hub" "call conda.bat activate SeCuReDmE_env && cd /d %PREFRONTAL_CORTEX_DIR% && python ai_persona.py"
goto end

:start_all
echo.
echo Starting the full integration...
echo.
call :start_all_hubs
echo 1. Starting CodeProject AI Server...
cd /d %SERVER_DIR%
call :verify_and_start_service %CODEPROJECT_PORT% "CodeProject AI Server" "cd /d %SERVER_SRC% && dotnet run"

echo 2. Starting MindsDB Server...
call :verify_and_start_service %MINDSDB_PORT% "MindsDB Server" "call conda.bat activate SeCuReDmE_env && cd /d %MINDSDB_DIR% && python -m mindsdb --config=%MINDSDB_CONFIG%"

echo 3. Starting App CodeProject AI Server...
call :verify_and_start_service %APP_CODEPROJECT_PORT% "App CodeProject AI Server" "call conda.bat activate SeCuReDmE_env && cd /d %APP_SERVER_DIR% && python codeproject_ai_server.py"

echo 4. Starting App MindsDB Server...
call :verify_and_start_service %APP_MINDSDB_PORT% "App MindsDB Server" "call conda.bat activate SeCuReDmE_env && cd /d %APP_SERVER_DIR% && python mindsdb_server.py"

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
goto end

:error_exit
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:end
echo.
echo Press any key to exit the launcher...
pause >nul
exit /b 0

:: Pause to keep the terminal open
pause
exit /b 0