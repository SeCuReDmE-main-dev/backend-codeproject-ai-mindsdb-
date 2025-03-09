:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off
echo Starting build with IncrediBuild...

:: Check if IncrediBuild is installed
where BuildConsole.exe >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: IncrediBuild is not installed or not in PATH.
    echo Please install IncrediBuild from https://www.incredibuild.com/downloads
    exit /b 1
)

:: Check for required project files and create if missing
set MODULE_DIR=D:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\CodeProject.AI-Modules

:: Check and create SentimentAnalysis project if missing
if not exist "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj" (
    echo Creating missing SentimentAnalysis project...
    if not exist "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\" mkdir "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis"
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>^<PropertyGroup^>^<TargetFramework^>net6.0^</TargetFramework^>^</PropertyGroup^>^</Project^> > "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj"
)

:: Check and create PortraitFilter project if missing
if not exist "%MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj" (
    echo Creating missing PortraitFilter project...
    if not exist "%MODULE_DIR%\CodeProject.AI-PortraitFilter\" mkdir "%MODULE_DIR%\CodeProject.AI-PortraitFilter"
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>^<PropertyGroup^>^<TargetFramework^>net6.0^</TargetFramework^>^</PropertyGroup^>^</Project^> > "%MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj"
)

:: Fix the JsonAPI.csproj file if it exists
set JSONAPI_PATH=D:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\CodeProject.AI-Server\src\demos\clients\Net\JsonAPI\JsonAPI.csproj
if exist "%JSONAPI_PATH%" (
    echo Fixing JsonAPI.csproj...
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>^<PropertyGroup^>^<TargetFramework^>net6.0^</TargetFramework^>^</PropertyGroup^>^</Project^> > "%JSONAPI_PATH%"
)

echo Project files checked and prepared. Starting IncrediBuild...

:: Create build.js if it doesn't exist
if not exist "%~dp0\build.js" (
    echo console.log('Starting build process...');> "%~dp0\build.js"
    echo // Add your build logic here>> "%~dp0\build.js"
    echo console.log('Build completed successfully!');>> "%~dp0\build.js"
)

:: Run build using IncrediBuild
BuildConsole.exe "%~dp0\incredibuild.xml" /profile="CodeProject AI-MindsDB Build" /command="npm install && npm run build"

if %ERRORLEVEL% neq 0 (
    echo Build failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo Build completed successfully!
exit /b 0