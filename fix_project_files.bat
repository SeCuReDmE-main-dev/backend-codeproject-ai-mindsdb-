@echo off
echo Starting fix for project files...

:: Set paths
set "BASE_DIR=D:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb"
set "MODULE_DIR=%BASE_DIR%\CodeProject.AI-Modules"

:: Check if the Modules folder exists, and if it's a file
if exist "%MODULE_DIR%" (
    echo Checking if %MODULE_DIR% is a directory or file...
    for %%I in ("%MODULE_DIR%") do set ATTRIB=%%~aI
    echo Attributes: %ATTRIB%
    
    if not "%ATTRIB:~0,1%"=="d" (
        echo WARNING: %MODULE_DIR% exists but is not a directory.
        echo Renaming existing file and creating directory...
        move "%MODULE_DIR%" "%MODULE_DIR%.bak"
        mkdir "%MODULE_DIR%"
        if %ERRORLEVEL% neq 0 (
            echo Failed to create module directory. Please check permissions.
            pause > nul
            exit /b 1
        )
        echo Successfully created %MODULE_DIR% directory
    ) else (
        echo %MODULE_DIR% exists and is a directory
    )
) else (
    echo %MODULE_DIR% does not exist, creating it...
    mkdir "%MODULE_DIR%"
    if %ERRORLEVEL% neq 0 (
        echo Failed to create module directory. Please check permissions.
        pause > nul
        exit /b 1
    )
    echo Successfully created %MODULE_DIR% directory
)

:: Create SentimentAnalysis directory and project file
echo.
echo Creating SentimentAnalysis directory and project...
if not exist "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis" (
    mkdir "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis"
    if %ERRORLEVEL% neq 0 (
        echo Failed to create SentimentAnalysis directory. Please check permissions.
        pause > nul
        exit /b 1
    )
    echo Successfully created %MODULE_DIR%\CodeProject.AI-SentimentAnalysis directory
)

echo Creating SentimentAnalysis project file...
(
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>
    echo   ^<PropertyGroup^>
    echo     ^<TargetFramework^>net6.0^</TargetFramework^>
    echo     ^<OutputType^>Exe^</OutputType^>
    echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
    echo     ^<Nullable^>enable^</Nullable^>
    echo   ^</PropertyGroup^>
    echo ^</Project^>
) > "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj"
if %ERRORLEVEL% neq 0 (
    echo Failed to create SentimentAnalysis.csproj file. Please check permissions.
    pause > nul
    exit /b 1
)
echo Successfully created %MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj

:: Create PortraitFilter directory and project file
echo.
echo Creating PortraitFilter directory and project...
if not exist "%MODULE_DIR%\CodeProject.AI-PortraitFilter" (
    mkdir "%MODULE_DIR%\CodeProject.AI-PortraitFilter"
    if %ERRORLEVEL% neq 0 (
        echo Failed to create PortraitFilter directory. Please check permissions.
        pause > nul
        exit /b 1
    )
    echo Successfully created %MODULE_DIR%\CodeProject.AI-PortraitFilter directory
)

echo Creating PortraitFilter project file...
(
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>
    echo   ^<PropertyGroup^>
    echo     ^<TargetFramework^>net6.0^</TargetFramework^>
    echo     ^<OutputType^>Exe^</OutputType^>
    echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
    echo     ^<Nullable^>enable^</Nullable^>
    echo   ^</PropertyGroup^>
    echo ^</Project^>
) > "%MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj"
if %ERRORLEVEL% neq 0 (
    echo Failed to create PortraitFilter.csproj file. Please check permissions.
    pause > nul
    exit /b 1
)
echo Successfully created %MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj

:: Fix the JsonAPI.csproj file
set "JSONAPI_PATH=%BASE_DIR%\CodeProject.AI-Server\src\demos\clients\Net\JsonAPI"
echo.
echo Checking JsonAPI path: %JSONAPI_PATH%
if not exist "%JSONAPI_PATH%" (
    echo Creating JsonAPI directory...
    mkdir "%JSONAPI_PATH%"
    if %ERRORLEVEL% neq 0 (
        echo Failed to create JsonAPI directory. Please check permissions.
        pause > nul
        exit /b 1
    )
    echo Successfully created %JSONAPI_PATH% directory
)

echo Creating/Fixing JsonAPI.csproj file...
(
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>
    echo   ^<PropertyGroup^>
    echo     ^<TargetFramework^>net6.0^</TargetFramework^>
    echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
    echo     ^<Nullable^>enable^</Nullable^>
    echo   ^</PropertyGroup^>
    echo ^</Project^>
) > "%JSONAPI_PATH%\JsonAPI.csproj"
if %ERRORLEVEL% neq 0 (
    echo Failed to create JsonAPI project file. Please check permissions.
    pause > nul
    exit /b 1
)
echo Successfully created %JSONAPI_PATH%\JsonAPI.csproj

echo.
echo Fix completed successfully!
echo The following files have been created:
echo - %MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj
echo - %MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj
echo - %JSONAPI_PATH%\JsonAPI.csproj

echo.
echo Press any key to exit...
pause > nul
exit /b 0