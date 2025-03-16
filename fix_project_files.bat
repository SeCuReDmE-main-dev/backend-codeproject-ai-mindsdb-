@echo off
echo ===============================================
echo Fix Project Files for IncrediBuild Compatibility
echo ===============================================
echo.

:: Set paths
set "ROOT_DIR=c:\Users\jeans\OneDrive\Desktop\SeCuReDmE final\SeCuReDmE-1"
set "MINIAPP_DIR=%ROOT_DIR%\mini-app-codeproject-ai-mindsdb"
set "MODULES_DIR=%ROOT_DIR%\CodeProject.AI-Modules"
set "CODEPROJECT_DIR=%ROOT_DIR%\CodeProject.AI-Server"
set "SOLUTION_DIR=%CODEPROJECT_DIR%"

:: Check if the project directories exist
if not exist "%MODULES_DIR%" (
    echo ERROR: Modules directory not found at %MODULES_DIR%
    goto error_exit
)

if not exist "%CODEPROJECT_DIR%" (
    echo ERROR: CodeProject.AI Server directory not found at %CODEPROJECT_DIR%
    goto error_exit
)

echo Fixing project files for IncrediBuild compatibility...
echo.

:: Function to check and fix missing project files
echo Checking for missing project files...

:: SentimentAnalysis project
set "SENTIMENT_PROJ=%MODULES_DIR%\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj"
if not exist "%SENTIMENT_PROJ%" (
    echo Creating missing SentimentAnalysis.csproj...
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>> "%SENTIMENT_PROJ%"
    echo   ^<PropertyGroup^>>> "%SENTIMENT_PROJ%"
    echo     ^<TargetFramework^>net7.0^</TargetFramework^>>> "%SENTIMENT_PROJ%"
    echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>>> "%SENTIMENT_PROJ%"
    echo     ^<Nullable^>enable^</Nullable^>>> "%SENTIMENT_PROJ%"
    echo   ^</PropertyGroup^>>> "%SENTIMENT_PROJ%"
    echo   ^<ItemGroup^>>> "%SENTIMENT_PROJ%"
    echo     ^<PackageReference Include="Microsoft.ML" Version="2.0.0" /^>>> "%SENTIMENT_PROJ%"
    echo   ^</ItemGroup^>>> "%SENTIMENT_PROJ%"
    echo ^</Project^>>> "%SENTIMENT_PROJ%"
    echo Created minimal SentimentAnalysis.csproj
) else (
    echo SentimentAnalysis.csproj exists, checking for compatibility...
    powershell -Command "(Get-Content '%SENTIMENT_PROJ%') -replace '<TargetFramework>[^<]+</TargetFramework>', '<TargetFramework>net7.0</TargetFramework>' | Set-Content '%SENTIMENT_PROJ%'"
    echo Fixed TargetFramework in SentimentAnalysis.csproj
)

:: PortraitFilter project
set "PORTRAIT_PROJ=%MODULES_DIR%\CodeProject.AI-PortraitFilter\PortraitFilter.csproj"
if not exist "%PORTRAIT_PROJ%" (
    echo Creating missing PortraitFilter.csproj...
    echo ^<Project Sdk="Microsoft.NET.Sdk"^>> "%PORTRAIT_PROJ%"
    echo   ^<PropertyGroup^>>> "%PORTRAIT_PROJ%"
    echo     ^<TargetFramework^>net7.0^</TargetFramework^>>> "%PORTRAIT_PROJ%"
    echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>>> "%PORTRAIT_PROJ%"
    echo     ^<Nullable^>enable^>>> "%PORTRAIT_PROJ%"
    echo   ^</PropertyGroup^>>> "%PORTRAIT_PROJ%"
    echo   ^<ItemGroup^>>> "%PORTRAIT_PROJ%"
    echo     ^<PackageReference Include="OpenCvSharp4" Version="4.7.0.20230115" /^>>> "%PORTRAIT_PROJ%"
    echo   ^</ItemGroup^>>> "%PORTRAIT_PROJ%"
    echo ^</Project^>>> "%PORTRAIT_PROJ%"
    echo Created minimal PortraitFilter.csproj
) else (
    echo PortraitFilter.csproj exists, checking for compatibility...
    powershell -Command "(Get-Content '%PORTRAIT_PROJ%') -replace '<TargetFramework>[^<]+</TargetFramework>', '<TargetFramework>net7.0</TargetFramework>' | Set-Content '%PORTRAIT_PROJ%'"
    echo Fixed TargetFramework in PortraitFilter.csproj
)

:: Check JsonAPI project
set "JSONAPI_PROJ=%CODEPROJECT_DIR%\src\server\JsonAPI.csproj"
if not exist "%JSONAPI_PROJ%" (
    echo Creating missing JsonAPI.csproj...
    echo ^<Project Sdk="Microsoft.NET.Sdk.Web"^>> "%JSONAPI_PROJ%"
    echo   ^<PropertyGroup^>>> "%JSONAPI_PROJ%"
    echo     ^<TargetFramework^>net7.0^</TargetFramework^>>> "%JSONAPI_PROJ%"
    echo   ^</PropertyGroup^>>> "%JSONAPI_PROJ%"
    echo ^</Project^>>> "%JSONAPI_PROJ%"
    echo Created minimal JsonAPI.csproj
) else (
    echo JsonAPI.csproj exists, checking for compatibility...
    powershell -Command "(Get-Content '%JSONAPI_PROJ%') -replace '<TargetFramework>[^<]+</TargetFramework>', '<TargetFramework>net7.0</TargetFramework>' | Set-Content '%JSONAPI_PROJ%'"
    echo Fixed TargetFramework in JsonAPI.csproj
)

:: Create a basic solution file if it doesn't exist
set "SOLUTION_FILE=%SOLUTION_DIR%\CodeProject.AI.sln"
if not exist "%SOLUTION_FILE%" (
    echo Creating basic solution file...
    echo Microsoft Visual Studio Solution File, Format Version 12.00> "%SOLUTION_FILE%"
    echo # Visual Studio Version 17>> "%SOLUTION_FILE%"
    echo VisualStudioVersion = 17.5.33424.131>> "%SOLUTION_FILE%"
    echo MinimumVisualStudioVersion = 10.0.40219.1>> "%SOLUTION_FILE%"
    echo Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "JsonAPI", "src\server\JsonAPI.csproj", "{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}">> "%SOLUTION_FILE%"
    echo EndProject>> "%SOLUTION_FILE%"
    echo Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "SentimentAnalysis", "..\CodeProject.AI-Modules\CodeProject.AI-SentimentAnalysis\SentimentAnalysis.csproj", "{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}">> "%SOLUTION_FILE%"
    echo EndProject>> "%SOLUTION_FILE%"
    echo Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "PortraitFilter", "..\CodeProject.AI-Modules\CodeProject.AI-PortraitFilter\PortraitFilter.csproj", "{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}">> "%SOLUTION_FILE%"
    echo EndProject>> "%SOLUTION_FILE%"
    echo Global>> "%SOLUTION_FILE%"
    echo 	GlobalSection(SolutionConfigurationPlatforms) = preSolution>> "%SOLUTION_FILE%"
    echo 		Debug|Any CPU = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		Debug|x64 = Debug|x64>> "%SOLUTION_FILE%"
    echo 		Release|Any CPU = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		Release|x64 = Release|x64>> "%SOLUTION_FILE%"
    echo 	EndGlobalSection>> "%SOLUTION_FILE%"
    echo 	GlobalSection(ProjectConfigurationPlatforms) = postSolution>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Debug|Any CPU.ActiveCfg = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Debug|Any CPU.Build.0 = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Debug|x64.ActiveCfg = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Debug|x64.Build.0 = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Release|Any CPU.ActiveCfg = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Release|Any CPU.Build.0 = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Release|x64.ActiveCfg = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{510B59E0-C8D4-4C2A-B1AF-6B8B5184DD1D}.Release|x64.Build.0 = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Debug|Any CPU.ActiveCfg = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Debug|Any CPU.Build.0 = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Debug|x64.ActiveCfg = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Debug|x64.Build.0 = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Release|Any CPU.ActiveCfg = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Release|Any CPU.Build.0 = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Release|x64.ActiveCfg = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{A8EB4D6C-3E26-4D61-A2AE-54A20CE7D71E}.Release|x64.Build.0 = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Debug|Any CPU.ActiveCfg = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Debug|Any CPU.Build.0 = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Debug|x64.ActiveCfg = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Debug|x64.Build.0 = Debug|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Release|Any CPU.ActiveCfg = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Release|Any CPU.Build.0 = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Release|x64.ActiveCfg = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 		{FCB2B430-8A75-4603-9A2C-34D183EBDDD6}.Release|x64.Build.0 = Release|Any CPU>> "%SOLUTION_FILE%"
    echo 	EndGlobalSection>> "%SOLUTION_FILE%"
    echo 	GlobalSection(SolutionProperties) = preSolution>> "%SOLUTION_FILE%"
    echo 		HideSolutionNode = FALSE>> "%SOLUTION_FILE%"
    echo 	EndGlobalSection>> "%SOLUTION_FILE%"
    echo 	GlobalSection(ExtensibilityGlobals) = postSolution>> "%SOLUTION_FILE%"
    echo 		SolutionGuid = {A236D507-D7C6-4309-83CC-B2A8263037C8}>> "%SOLUTION_FILE%"
    echo 	EndGlobalSection>> "%SOLUTION_FILE%"
    echo EndGlobal>> "%SOLUTION_FILE%"
    echo Created basic solution file
) else (
    echo Solution file exists
)

:: Create package.json for npm compatibility if it doesn't exist
set "PACKAGE_JSON=%MINIAPP_DIR%\package.json"
if not exist "%PACKAGE_JSON%" (
    echo Creating package.json for npm commands...
    echo {> "%PACKAGE_JSON%"
    echo   "name": "codeproject-ai-mindsdb-integration",>> "%PACKAGE_JSON%"
    echo   "version": "1.0.0",>> "%PACKAGE_JSON%"
    echo   "description": "CodeProject AI with MindsDB Integration",>> "%PACKAGE_JSON%"
    echo   "main": "index.js",>> "%PACKAGE_JSON%"
    echo   "scripts": {>> "%PACKAGE_JSON%"
    echo     "start": "start_integration.bat",>> "%PACKAGE_JSON%"
    echo     "build": "build-with-incredibuild.bat",>> "%PACKAGE_JSON%"
    echo     "build:incredibuild": "build-with-incredibuild.bat",>> "%PACKAGE_JSON%"
    echo     "setup": "../run_complete_setup.bat",>> "%PACKAGE_JSON%"
    echo     "dashboard": "cd mindsdb-dashboard && npm start",>> "%PACKAGE_JSON%"
    echo     "fix": "fix_project_files.bat">> "%PACKAGE_JSON%"
    echo   },>> "%PACKAGE_JSON%"
    echo   "author": "",>> "%PACKAGE_JSON%"
    echo   "license": "MIT">> "%PACKAGE_JSON%"
    echo }>> "%PACKAGE_JSON%"
    echo Created package.json
) else (
    echo package.json exists
)

echo.
echo Project files have been fixed for IncrediBuild compatibility.
echo You can now build the solution using build-with-incredibuild.bat or by running:
echo   npm run build:incredibuild
echo.
echo Press any key to exit...
goto end

:error_exit
echo.
echo ERROR: Could not complete the fix. Please check the directories and try again.
echo Press any key to exit...

:end
pause > nul
exit /b 0