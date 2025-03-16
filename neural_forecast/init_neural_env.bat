@echo off
echo ===============================================
echo Neural Forecast Environment Setup
echo ===============================================
echo.

:: Set paths
set "ROOT_DIR=%~dp0"
set "CONDA_ENV_NAME=SeCuReDmE_env"
set "TEMP_DIR=%ROOT_DIR%temp"
set "LOG_DIR=%ROOT_DIR%logs"
set "MODELS_DIR=%ROOT_DIR%models"

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

:: Create required directories
echo Creating required directories...
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"

:: Check and activate Conda environment
echo Checking Conda environment...
call conda activate %CONDA_ENV_NAME% 2>nul
if %ERRORLEVEL% neq 0 (
    echo Creating new Conda environment %CONDA_ENV_NAME%...
    call conda create -n %CONDA_ENV_NAME% python=3.9 -y
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Failed to create Conda environment.
        goto error
    )
    call conda activate %CONDA_ENV_NAME%
)

:: Install required packages
echo Installing required Python packages...
pip install -r "%ROOT_DIR%requirements.txt"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to install required packages.
    goto error
)

:: Configure IncrediBuild if available
if "%USE_INCREDIBUILD%"=="true" (
    echo Configuring IncrediBuild for neural operations...
    
    :: Set IncrediBuild agent settings
    IBConsole /command=SetCoordSettings /MaxCPUs=16
    IBConsole /command=SetSystemUtilization /type=CPU /value=80
    IBConsole /command=SetSystemUtilization /type=memory /value=4096
    
    :: Enable Python acceleration
    IBConsole /command=EnablePythonSupport /value=true
    
    echo IncrediBuild configured successfully.
)

:: Test neural coordinator
echo Testing neural forecast coordinator...
python "%ROOT_DIR%test_coordinator.py" -v
if %ERRORLEVEL% neq 0 (
    echo WARNING: Some tests failed. Check the logs for details.
) else (
    echo All tests passed successfully.
)

echo.
echo Neural forecast environment setup complete.
echo You can now use the neural forecast coordinator.
echo.
echo Usage:
echo - Start the dashboard: start_dashboard.bat
echo - Run predictions: python neural_coordinator.py
echo.
goto end

:error
echo.
echo Error occurred during setup.
echo Please check the error messages above.
pause
exit /b 1

:end
echo Press any key to exit...
pause >nul
exit /b 0