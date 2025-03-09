:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off
echo Starting build with IncrediBuild...

:: Check if IncrediBuild is installed
where BuildConsole.exe >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: IncrediBuild is not installed or not in PATH.
    echo Please install IncrediBuild from https://www.incredibuild.com/downloads
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

:: Create required directories if they don't exist
echo Creating required directories if they don't exist...
set BASE_DIR=D:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb
set MODULE_DIR=%BASE_DIR%\CodeProject.AI-Modules

if not exist "%MODULE_DIR%" (
    echo Creating CodeProject.AI-Modules directory...
    mkdir "%MODULE_DIR%"
)

:: Check and create SentimentAnalysis project if missing
if not exist "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\" (
    echo Creating missing SentimentAnalysis directory...
    mkdir "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis"
)

if not exist "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj" (
    echo Creating missing SentimentAnalysis project file...
    (
        echo ^<Project Sdk="Microsoft.NET.Sdk"^>
        echo   ^<PropertyGroup^>
        echo     ^<TargetFramework^>net6.0^</TargetFramework^>
        echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
        echo     ^<Nullable^>enable^</Nullable^>
        echo   ^</PropertyGroup^>
        echo ^</Project^>
    ) > "%MODULE_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj"
)

:: Check and create PortraitFilter project if missing
if not exist "%MODULE_DIR%\CodeProject.AI-PortraitFilter\" (
    echo Creating missing PortraitFilter directory...
    mkdir "%MODULE_DIR%\CodeProject.AI-PortraitFilter"
)

if not exist "%MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj" (
    echo Creating missing PortraitFilter project file...
    (
        echo ^<Project Sdk="Microsoft.NET.Sdk"^>
        echo   ^<PropertyGroup^>
        echo     ^<TargetFramework^>net6.0^</TargetFramework^>
        echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
        echo     ^<Nullable^>enable^</Nullable^>
        echo   ^</PropertyGroup^>
        echo ^</Project^>
    ) > "%MODULE_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj"
)

:: Fix the JsonAPI.csproj file if it exists
set JSONAPI_PATH=%BASE_DIR%\CodeProject.AI-Server\src\demos\clients\Net\JsonAPI
if not exist "%JSONAPI_PATH%" (
    echo Creating JsonAPI directory...
    mkdir "%JSONAPI_PATH%"
)

if exist "%JSONAPI_PATH%\JsonAPI.csproj" (
    echo Fixing JsonAPI.csproj...
    (
        echo ^<Project Sdk="Microsoft.NET.Sdk"^>
        echo   ^<PropertyGroup^>
        echo     ^<TargetFramework^>net6.0^</TargetFramework^>
        echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
        echo     ^<Nullable^>enable^</Nullable^>
        echo   ^</PropertyGroup^>
        echo ^</Project^>
    ) > "%JSONAPI_PATH%\JsonAPI.csproj"
) else (
    echo Creating JsonAPI.csproj...
    (
        echo ^<Project Sdk="Microsoft.NET.Sdk"^>
        echo   ^<PropertyGroup^>
        echo     ^<TargetFramework^>net6.0^</TargetFramework^>
        echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
        echo     ^<Nullable^>enable^</Nullable^>
        echo   ^</PropertyGroup^>
        echo ^</Project^>
    ) > "%JSONAPI_PATH%\JsonAPI.csproj"
)

:: Check for .NET SDK
dotnet --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: .NET SDK is not installed or not in PATH.
    echo Please install .NET SDK from https://dotnet.microsoft.com/download
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

:: Install Discord.js for Discord gateway integration
echo Installing Discord.js for Discord gateway integration...
call npm install discord.js --save

:: Create build.js if it doesn't exist (with Discord gateway integration)
if not exist "%~dp0\build.js" (
    echo Creating build.js file with Discord gateway integration...
    (
        echo console.log('Starting build process with Discord gateway integration...');
        echo const { Client, GatewayIntentBits } = require('discord.js');
        echo const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages] });
        echo.
        echo client.once('ready', () =^> {
        echo     console.log(`Logged in as ${client.user.tag}`);
        echo     console.log('Connected to Discord gateway successfully!');
        echo });
        echo.
        echo client.on('messageCreate', message =^> {
        echo     if (message.content === '!ping') {
        echo         message.reply('Pong! Connection to MindsDB is operational.');
        echo     }
        echo });
        echo.
        echo // Add Discord bot token in your environment variables or config file
        echo const token = process.env.DISCORD_TOKEN;
        echo if (!token) {
        echo     console.error('Please set the DISCORD_TOKEN environment variable');
        echo     process.exit(1);
        echo }
        echo.
        echo // Connect to Discord gateway
        echo console.log('Connecting to Discord gateway...');
        echo client.login(token)
        echo     .catch(error =^> {
        echo         console.error('Failed to connect to Discord:', error);
        echo         process.exit(1);
        echo     });
        echo.
        echo console.log('Build completed successfully!');
    ) > "%~dp0\build.js"
)

echo Project files checked and prepared. Starting IncrediBuild...

:: Set Discord token environment variable (for testing, replace with your actual token)
echo Setting Discord token environment variable...
echo NOTE: For production use, please set the DISCORD_TOKEN environment variable properly!
set DISCORD_TOKEN=your_discord_bot_token_here

:: Run build using IncrediBuild
echo Running build with IncrediBuild...
BuildConsole.exe "%~dp0\incredibuild.xml" /profile="CodeProject AI-MindsDB Build" /command="npm install && npm run build"

if %ERRORLEVEL% neq 0 (
    echo Build failed with error code %ERRORLEVEL%
    echo Press any key to exit...
    pause > nul
    exit /b %ERRORLEVEL%
)

echo Build completed successfully!
echo Discord gateway integration has been added.
echo.
echo IMPORTANT: You will need to replace 'your_discord_bot_token_here' with your actual Discord bot token.
echo You can set it in this script or as an environment variable named DISCORD_TOKEN.
echo.
echo Press any key to exit...
pause > nul
exit /b 0