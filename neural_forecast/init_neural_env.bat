@echo off
echo ===============================================
echo Neural Forecast Environment Initialization
echo ===============================================

:: Set paths
set "ROOT_DIR=%~dp0"
set "REQUIREMENTS_FILE=%ROOT_DIR%requirements.txt"
set "CONDA_ENV=SeCuReDmE_env"

:: Check for Conda
where conda >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Conda not found in PATH
    echo Please install Conda and try again
    exit /b 1
)

:: Activate environment
call conda activate %CONDA_ENV%
if %ERRORLEVEL% neq 0 (
    echo Creating new Conda environment: %CONDA_ENV%
    call conda create -n %CONDA_ENV% python=3.9 -y
    call conda activate %CONDA_ENV%
)

:: Install requirements
echo Installing requirements...
pip install -r "%REQUIREMENTS_FILE%"

echo Neural environment setup complete
exit /b 0