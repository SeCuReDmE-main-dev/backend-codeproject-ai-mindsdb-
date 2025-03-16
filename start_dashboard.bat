@echo off
echo ===============================================
echo EduForecast Dashboard Neural Coordinator
echo ===============================================
echo.

:: Set paths
set "ROOT_DIR=%~dp0"
set "DASHBOARD_DIR=%ROOT_DIR%\mindsdb-dashboard"
set "NEURAL_FORECAST_DIR=%ROOT_DIR%\neural_forecast"
set "BUILD_DIR=%ROOT_DIR%\build"
set "INCREDIBUILD_CONFIG=%ROOT_DIR%\incredibuild.xml"

:: Check if IncrediBuild is installed
echo Checking for IncrediBuild...
where BuildConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo WARNING: IncrediBuild is not installed or not in PATH.
    echo Neural forecast builds will run without acceleration.
    echo Install IncrediBuild from https://www.incredibuild.com/downloads
    echo for build acceleration.
    set "USE_INCREDIBUILD=false"
) else (
    echo IncrediBuild found. Build acceleration enabled.
    set "USE_INCREDIBUILD=true"
)

:: Check for dashboard directory
if not exist "%DASHBOARD_DIR%" (
    echo ERROR: Dashboard directory not found at %DASHBOARD_DIR%
    echo Please run the installation script first.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

:: Create neural forecast directory if it doesn't exist
if not exist "%NEURAL_FORECAST_DIR%" (
    echo Creating neural forecast directory...
    mkdir "%NEURAL_FORECAST_DIR%"
)

:: Create build directory if it doesn't exist
if not exist "%BUILD_DIR%" (
    echo Creating build directory...
    mkdir "%BUILD_DIR%"
)

:: Initialize neural forecast coordinator
echo ===============================================
echo Initializing Neural Forecast Coordinator
echo ===============================================

:: Configure IncrediBuild agent settings if available
if "%USE_INCREDIBUILD%"=="true" (
    echo Configuring IncrediBuild agents...
    IBConsole /command=SetCoordSettings /MaxCPUs=16
    IBConsole /command=SetSystemUtilization /type=CPU /value=80
    IBConsole /command=SetSystemUtilization /type=memory /value=4096
)

:: Setup Python environment
echo Setting up Python environment...
call conda activate SeCuReDmE_env
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to activate Conda environment.
    echo Please ensure the SeCuReDmE_env is created.
    goto error
)

:: Start MindsDB server for neural operations
echo Starting MindsDB server...
start "MindsDB Server" cmd /c "python %ROOT_DIR%\server\mindsdb_server.py"

:: Start dashboard with neural forecast integration
echo Starting EduForecast Dashboard...
cd /d "%DASHBOARD_DIR%"

:: Check if node_modules directory exists
if not exist "%DASHBOARD_DIR%\node_modules" (
    echo Installing dependencies...
    npm install
)

:: Start the development server with neural forecast enabled
set "REACT_APP_NEURAL_FORECAST=true"
npm start

echo.
echo Neural Forecast Dashboard started.
echo - Dashboard URL: http://localhost:3000
echo - Neural Coordinator Status: http://localhost:3000/neural-status
echo - MindsDB Neural Interface: http://localhost:47334
echo.
echo Press Ctrl+C to stop all services when finished.

goto end

:error
echo.
echo Error occurred during startup.
echo Please check the error messages above.
pause
exit /b 1

:end
exit /b 0