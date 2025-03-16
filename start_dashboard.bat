@echo off
echo ===============================================
echo EduForecast Dashboard Launcher
echo ===============================================
echo.

set "DASHBOARD_DIR=%~dp0\mindsdb-dashboard"

if not exist "%DASHBOARD_DIR%" (
    echo ERROR: Dashboard directory not found at %DASHBOARD_DIR%
    echo Please run the installation script first.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Starting EduForecast Dashboard...
cd /d "%DASHBOARD_DIR%"

:: Check if node_modules directory exists
if not exist "%DASHBOARD_DIR%\node_modules" (
    echo Installing dependencies...
    npm install
)

:: Start the development server
npm start

echo.
echo Dashboard started. If the browser doesn't open automatically,
echo navigate to: http://localhost:3000
echo.
echo Press Ctrl+C to stop the server when finished.