:: filepath: d:\CodeProject SeCuReDmE_server\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat
@echo off

:: Display header
echo ===============================================
echo SeCuReDmE Build with IncrediBuild Script
echo ===============================================
echo.

:: Keep window open flag
set "KEEP_WINDOW_OPEN=1"

:: Check if IncrediBuild is installed
echo Checking for IncrediBuild...
where BuildConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: IncrediBuild is not installed or not in PATH.
    echo Please install IncrediBuild and try again.
    goto keep_window_open
)
echo IncrediBuild found.

:: Set paths
set "ROOT_DIR=c:\Users\jeans\OneDrive\Desktop\SeCuReDmE final\SeCuReDmE-1"
set "BASE_DIR=%~dp0"
set "SOLUTION_DIR=%ROOT_DIR%\CodeProject.AI-Server"
set "SOLUTION_FILE=%SOLUTION_DIR%\CodeProject.AI.sln"
set "XML_CONFIG=%BASE_DIR%incredibuild.xml"
set "BUILD_LOG=%ROOT_DIR%\build-log.txt"
set "MODULES_DIR=%ROOT_DIR%\CodeProject.AI-Modules"
set "MULTIMODELLM_DIR=%ROOT_DIR%\CodeProject.AI-MultiModeLLM"
set "MINDSDB_DIR=%BASE_DIR%\MindsDB"

:: Check if solution file exists
if not exist "%SOLUTION_FILE%" (
    echo WARNING: Main solution file not found at %SOLUTION_FILE%
    echo Checking alternative solution location...
    set "SOLUTION_FILE=%BASE_DIR%CodeProject.AI-Server\CodeProject.AI.sln"
    
    if not exist "%SOLUTION_FILE%" (
        echo Solution file not found. Running fix_project_files.bat to create it...
        
        if exist "%BASE_DIR%fix_project_files.bat" (
            call "%BASE_DIR%fix_project_files.bat"
            if not exist "%SOLUTION_FILE%" (
                echo ERROR: Could not create solution file. Please check your installation.
                goto keep_window_open
            )
        ) else (
            echo ERROR: fix_project_files.bat not found. Cannot create solution file.
            goto keep_window_open
        )
    )
)

echo Solution file found: %SOLUTION_FILE%

:: Check for XML configuration file
if not exist "%XML_CONFIG%" (
    echo WARNING: IncrediBuild XML configuration not found at %XML_CONFIG%
    echo Creating default XML configuration...
    
    echo ^<?xml version="1.0" encoding="UTF-8"?^>> "%XML_CONFIG%"
    echo ^<BuildConsole^>>> "%XML_CONFIG%"
    echo   ^<Profile^>>> "%XML_CONFIG%"
    echo     ^<ProfileName^>SeCuReDmE CodeProject.AI Build^</ProfileName^>>> "%XML_CONFIG%"
    echo     ^<MaxCores^>0^</MaxCores^>>> "%XML_CONFIG%"
    echo     ^<MaxCoresLocal^>4^</MaxCoresLocal^>>> "%XML_CONFIG%"
    echo     ^<AvoidLocalExecution^>false^</AvoidLocalExecution^>>> "%XML_CONFIG%"
    echo     ^<CopyFilesToCoordinator^>false^</CopyFilesToCoordinator^>>> "%XML_CONFIG%"
    echo     ^<CopyFilesFromCoordinator^>false^</CopyFilesFromCoordinator^>>> "%XML_CONFIG%"
    echo     ^<AvoidNetworkAccess^>false^</AvoidNetworkAccess^>>> "%XML_CONFIG%"
    echo     ^<Environment^>>> "%XML_CONFIG%"
    echo       ^<Variable Name="PATH" Value="%%PATH%%" /^>>> "%XML_CONFIG%"
    echo     ^</Environment^>>> "%XML_CONFIG%"
    echo   ^</Profile^>>> "%XML_CONFIG%"
    echo ^</BuildConsole^>>> "%XML_CONFIG%"
)

:: Configure IncrediBuild agent settings
echo.
echo ===============================================
echo Configuring IncrediBuild Agent Settings
echo ===============================================

:: Check if in standalone mode
echo Checking IncrediBuild mode...
IBConsole /command=GetSettings > "%TEMP%\ib_settings.txt" 2>nul
findstr /C:"StandAlone" "%TEMP%\ib_settings.txt" >nul
if %ERRORLEVEL% equ 0 (
    echo IncrediBuild is in standalone mode.
    echo You may want to connect to the coordination server for better performance.
    echo.
    echo To connect to a coordinator, use the IncrediBuild Dashboard.
) else (
    echo IncrediBuild is in coordinated mode.
)

:: Attempt to configure IncrediBuild settings via ibconsole
echo Configuring system resource allocation...

:: CPU allocation - with retry
set "retryCount=0"
:retry_cpu
IBConsole /command=SetSystemUtilization /type=CPU /value=80 2>nul
if %ERRORLEVEL% neq 0 (
    set /a "retryCount+=1"
    if %retryCount% lss 3 (
        echo Retrying CPU configuration...
        timeout /t 2 >nul
        goto retry_cpu
    ) else (
        echo WARNING: Failed to set CPU allocation, using default settings
    )
)

:: Memory allocation - with retry
set "retryCount=0"
:retry_memory
IBConsole /command=SetSystemUtilization /type=memory /value=4096 2>nul
if %ERRORLEVEL% neq 0 (
    set /a "retryCount+=1"
    if %retryCount% lss 3 (
        echo Retrying memory configuration...
        timeout /t 2 >nul
        goto retry_memory
    ) else (
        echo WARNING: Failed to set memory allocation, using default settings
    )
)

:: Disk allocation - with retry
set "retryCount=0"
:retry_disk
IBConsole /command=SetSystemUtilization /type=disk /value=80 2>nul
if %ERRORLEVEL% neq 0 (
    set /a "retryCount+=1"
    if %retryCount% lss 3 (
        echo Retrying disk configuration...
        timeout /t 2 >nul
        goto retry_disk
    ) else (
        echo WARNING: Failed to set disk allocation, using default settings
    )
)

:: Display available agents
echo.
echo ===============================================
echo IncrediBuild Agent Information
echo ===============================================
IBConsole /command=GetHelpers 2>nul || echo No helper information available.

:: Query available solution configurations
echo.
echo Getting available solution configurations...
BuildConsole "%SOLUTION_FILE%" /showtargets > "%TEMP%\solution_configs.txt" 2>nul || echo Unable to get solution configurations.

:: Parse the available configurations
type "%TEMP%\solution_configs.txt" | findstr "Available solution configurations:" > nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=1* delims=:" %%a in ('type "%TEMP%\solution_configs.txt" ^| findstr "Available solution configurations:"') do (
        set "CONFIG_LIST=%%b"
    )
    echo Available configurations:%CONFIG_LIST%
)

:: Display build options
echo.
echo ===============================================
echo Build Options
echo ===============================================
echo 1. Release build (Any CPU)
echo 2. Debug build (Any CPU)
echo 3. Release build (x86)
echo 4. Debug build (x86)
echo 5. Release build (ARM64)
echo 6. Debug build (ARM64)
echo 7. Clean solution
echo 8. Build specific module
echo 9. Build Python MindsDB integration
echo.

choice /C 123456789 /N /M "Select a build option [1-9]: "

if %ERRORLEVEL% EQU 1 set "BUILD_CONFIG=Release|Any CPU"
if %ERRORLEVEL% EQU 2 set "BUILD_CONFIG=Debug|Any CPU"
if %ERRORLEVEL% EQU 3 set "BUILD_CONFIG=Release|x86"
if %ERRORLEVEL% EQU 4 set "BUILD_CONFIG=Debug|x86"
if %ERRORLEVEL% EQU 5 set "BUILD_CONFIG=Release|ARM64"
if %ERRORLEVEL% EQU 6 set "BUILD_CONFIG=Debug|ARM64"
if %ERRORLEVEL% EQU 7 goto clean_solution
if %ERRORLEVEL% EQU 8 goto build_module
if %ERRORLEVEL% EQU 9 goto build_mindsdb

echo.
echo Starting build with configuration: %BUILD_CONFIG%
echo.

:: Build solution with IncrediBuild
echo Building solution with IncrediBuild...
BuildConsole "%SOLUTION_FILE%" /build /cfg="%BUILD_CONFIG%" /useenv /out="%BUILD_LOG%" /MaxCPUs=16 /Retry=3

if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed. Check the log file at %BUILD_LOG% for details.
    goto keep_window_open
) else (
    echo Build completed successfully.
    echo Log file: %BUILD_LOG%
    echo.
)

:: Check if release builds need to be copied to deployment location
if "%BUILD_CONFIG:~0,7%"=="Release" (
    echo Do you want to copy the release build to deployment location? (Y/N)
    choice /C YN /N
    if %ERRORLEVEL% EQU 1 (
        echo Creating deployment directory if it doesn't exist...
        if not exist "%ROOT_DIR%\deployment\" mkdir "%ROOT_DIR%\deployment\"
        
        echo Copying release build to deployment location...
        xcopy /E /Y /I "%SOLUTION_DIR%\bin\%BUILD_CONFIG%\*.*" "%ROOT_DIR%\deployment\"
        echo Copy completed.
    )
)

goto end

:clean_solution
echo Cleaning solution...
echo Select configuration to clean:
echo 1. Release|Any CPU
echo 2. Debug|Any CPU
echo 3. Release|x86
echo 4. Debug|x86
echo 5. Release|ARM64
echo 6. Debug|ARM64
echo.

choice /C 123456 /N /M "Select configuration [1-6]: "

if %ERRORLEVEL% EQU 1 set "CLEAN_CONFIG=Release|Any CPU"
if %ERRORLEVEL% EQU 2 set "CLEAN_CONFIG=Debug|Any CPU"
if %ERRORLEVEL% EQU 3 set "CLEAN_CONFIG=Release|x86"
if %ERRORLEVEL% EQU 4 set "CLEAN_CONFIG=Debug|x86"
if %ERRORLEVEL% EQU 5 set "CLEAN_CONFIG=Release|ARM64"
if %ERRORLEVEL% EQU 6 set "CLEAN_CONFIG=Debug|ARM64"

BuildConsole "%SOLUTION_FILE%" /clean /cfg="%CLEAN_CONFIG%" /useenv /out="%BUILD_LOG%"
echo Solution cleaned. Log file: %BUILD_LOG%
goto end

:build_module
echo.
echo ===============================================
echo Select a module to build:
echo ===============================================
echo 1. SentimentAnalysis
echo 2. PortraitFilter
echo 3. MultiModeLLM
echo 4. All modules
echo.

choice /C 1234 /N /M "Select a module [1-4]: "

if %ERRORLEVEL% EQU 1 set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-SentimentAnalysis"
if %ERRORLEVEL% EQU 2 set "MODULE_DIR=%MODULES_DIR%\CodeProject.AI-PortraitFilter"
if %ERRORLEVEL% EQU 3 set "MODULE_DIR=%MULTIMODELLM_DIR%"
if %ERRORLEVEL% EQU 4 goto build_all_modules

:: Check if module directory exists
if not exist "%MODULE_DIR%" (
    echo ERROR: Module directory not found at %MODULE_DIR%
    goto keep_window_open
)

:: Find project file in module directory
for /r "%MODULE_DIR%" %%f in (*.csproj) do (
    set "PROJECT_FILE=%%f"
    goto found_project
)
echo ERROR: No project file found in %MODULE_DIR%
goto keep_window_open

:found_project
echo Building module with project file: %PROJECT_FILE%

:: Choose build configuration for module
echo.
echo Select build configuration:
echo 1. Release|Any CPU
echo 2. Debug|Any CPU
echo 3. Release|x86
echo 4. Debug|x86
echo 5. Release|ARM64
echo 6. Debug|ARM64
echo.

choice /C 123456 /N /M "Select configuration [1-6]: "

if %ERRORLEVEL% EQU 1 set "MODULE_CONFIG=Release|Any CPU"
if %ERRORLEVEL% EQU 2 set "MODULE_CONFIG=Debug|Any CPU"
if %ERRORLEVEL% EQU 3 set "MODULE_CONFIG=Release|x86"
if %ERRORLEVEL% EQU 4 set "MODULE_CONFIG=Debug|x86"
if %ERRORLEVEL% EQU 5 set "MODULE_CONFIG=Release|ARM64"
if %ERRORLEVEL% EQU 6 set "MODULE_CONFIG=Debug|ARM64"

echo Building module with configuration: %MODULE_CONFIG%
BuildConsole "%PROJECT_FILE%" /build /cfg="%MODULE_CONFIG%" /useenv /out="%BUILD_LOG%" /Retry=2

if %ERRORLEVEL% neq 0 (
    echo ERROR: Module build failed. Check the log file at %BUILD_LOG% for details.
) else (
    echo Module build completed successfully.
)

goto end

:build_all_modules
echo Building all modules...

:: Find all project files in modules directory
set "FOUND_PROJECTS=0"
for /r "%MODULES_DIR%" %%f in (*.csproj) do (
    set /a FOUND_PROJECTS+=1
    echo Building %%f...
    BuildConsole "%%f" /build /cfg="Release|Any CPU" /useenv /out="%BUILD_LOG%.%%~nf" /Retry=2
    
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Build of %%f failed. Check the log for details.
    ) else (
        echo Build of %%f completed successfully.
    )
)

:: Also check for MultiModeLLM in separate directory
if exist "%MULTIMODELLM_DIR%" (
    for /r "%MULTIMODELLM_DIR%" %%f in (*.csproj) do (
        set /a FOUND_PROJECTS+=1
        echo Building %%f...
        BuildConsole "%%f" /build /cfg="Release|Any CPU" /useenv /out="%BUILD_LOG%.%%~nf" /Retry=2
        
        if %ERRORLEVEL% neq 0 (
            echo ERROR: Build of %%f failed. Check the log for details.
        ) else (
            echo Build of %%f completed successfully.
        )
    )
)

if %FOUND_PROJECTS% EQU 0 (
    echo No project files found in modules directory.
) else (
    echo All modules build complete.
)

goto end

:build_mindsdb
echo.
echo ===============================================
echo Building MindsDB Python Integration
echo ===============================================

:: Check if Conda is installed
echo Checking for Conda...
where conda >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Conda is not installed or not in PATH.
    echo Please install Conda before building MindsDB.
    goto keep_window_open
)

:: Check if MindsDB directory exists
if not exist "%MINDSDB_DIR%" (
    echo ERROR: MindsDB directory not found at %MINDSDB_DIR%
    echo Creating directory structure...
    mkdir "%MINDSDB_DIR%"
)

:: Create setup.py file if it doesn't exist
if not exist "%MINDSDB_DIR%\setup.py" (
    echo Creating setup.py file...
    echo from setuptools import setup, find_packages> "%MINDSDB_DIR%\setup.py"
    echo.>> "%MINDSDB_DIR%\setup.py"
    echo setup(>> "%MINDSDB_DIR%\setup.py"
    echo     name="securedme-mindsdb-integration",>> "%MINDSDB_DIR%\setup.py"
    echo     version="0.1.0",>> "%MINDSDB_DIR%\setup.py"
    echo     description="SeCuReDmE MindsDB Integration",>> "%MINDSDB_DIR%\setup.py"
    echo     packages=find_packages(),>> "%MINDSDB_DIR%\setup.py"
    echo     install_requires=[>> "%MINDSDB_DIR%\setup.py"
    echo         "mindsdb>=23.6.4.0",>> "%MINDSDB_DIR%\setup.py"
    echo         "pymongo>=4.3.3",>> "%MINDSDB_DIR%\setup.py"
    echo         "psycopg2-binary>=2.9.5",>> "%MINDSDB_DIR%\setup.py"
    echo         "opentelemetry-api>=1.15.0",>> "%MINDSDB_DIR%\setup.py"
    echo         "opentelemetry-sdk>=1.15.0",>> "%MINDSDB_DIR%\setup.py"
    echo     ],>> "%MINDSDB_DIR%\setup.py"
    echo )>> "%MINDSDB_DIR%\setup.py"
)

:: Create federation_config.json if it doesn't exist
if not exist "%MINDSDB_DIR%\federation_config.json" (
    echo Creating federation_config.json file...
    echo {> "%MINDSDB_DIR%\federation_config.json"
    echo   "securedme_datasource": {>> "%MINDSDB_DIR%\federation_config.json"
    echo     "type": "mongodb",>> "%MINDSDB_DIR%\federation_config.json"
    echo     "connection": {>> "%MINDSDB_DIR%\federation_config.json"
    echo       "host": "mongodb+srv://securedme_admin:securedme_password@securedme-cluster.mongodb.net",>> "%MINDSDB_DIR%\federation_config.json"
    echo       "database": "mindsdb">> "%MINDSDB_DIR%\federation_config.json"
    echo     },>> "%MINDSDB_DIR%\federation_config.json"
    echo     "enabled": true,>> "%MINDSDB_DIR%\federation_config.json"
    echo     "tables": [>> "%MINDSDB_DIR%\federation_config.json"
    echo       "users",>> "%MINDSDB_DIR%\federation_config.json"
    echo       "predictions",>> "%MINDSDB_DIR%\federation_config.json"
    echo       "sensor_data",>> "%MINDSDB_DIR%\federation_config.json"
    echo       "security_events">> "%MINDSDB_DIR%\federation_config.json"
    echo     ]>> "%MINDSDB_DIR%\federation_config.json"
    echo   }>> "%MINDSDB_DIR%\federation_config.json"
    echo }>> "%MINDSDB_DIR%\federation_config.json"
)

:: Create otel-collector-config.yaml if it doesn't exist
if not exist "%MINDSDB_DIR%\otel-collector-config.yaml" (
    echo Creating otel-collector-config.yaml file...
    echo receivers:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo   otlp:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo     protocols:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       grpc:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       http:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo.>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo processors:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo   batch:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo.>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo exporters:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo   logging:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo     verbosity: detailed>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo   prometheus:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo     endpoint: "0.0.0.0:8889">> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo.>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo service:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo   pipelines:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo     traces:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       receivers: [otlp]>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       processors: [batch]>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       exporters: [logging]>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo     metrics:>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       receivers: [otlp]>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       processors: [batch]>> "%MINDSDB_DIR%\otel-collector-config.yaml"
    echo       exporters: [logging, prometheus]>> "%MINDSDB_DIR%\otel-collector-config.yaml"
)

echo IncrediBuild is not optimized for Python/Conda builds,
echo but we can accelerate package installation.

:: Check for SeCuReDmE_env conda environment
call conda.bat env list | findstr "SeCuReDmE_env" > nul
if %ERRORLEVEL% neq 0 (
    echo SeCuReDmE_env conda environment not found.
    echo Do you want to create it? (Y/N)
    choice /C YN /N
    if %ERRORLEVEL% EQU 1 (
        echo Creating SeCuReDmE_env conda environment...
        call conda.bat create -n SeCuReDmE_env python=3.9 -y
    ) else (
        echo Skipping conda environment creation.
        goto keep_window_open
    )
)

:: Activate conda environment and install MindsDB
echo Activating SeCuReDmE_env conda environment and installing MindsDB...
call conda.bat activate SeCuReDmE_env
cd /d "%MINDSDB_DIR%"

:: Install from setup.py in development mode
echo Installing MindsDB integration package...
pip install -e .

if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to install MindsDB integration package.
) else (
    echo MindsDB integration package installed successfully.
)

echo.
echo MindsDB Python integration build complete.
goto end

:end
:: Display build completion message
echo.
echo ===============================================
echo Build process complete
echo ===============================================
:keep_window_open
echo.
echo Press any key to close this window...
pause >nul
exit /b %ERRORLEVEL%