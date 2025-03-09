@echo off
echo ===============================================
echo Creating Educational Module for Kids
echo ===============================================
echo.

:: Set path to core script
set "BASE_DIR=%~dp0.."
set "CORE_SCRIPT=%BASE_DIR%\secureme_core.py"

echo Creating a fun animal recognition module...
python "%CORE_SCRIPT%" create python AnimalFriends --description "A fun animal recognition module for kids"

echo.
echo Creating a simple math helper module...
python "%CORE_SCRIPT%" create dotnet MathHelper --description "Interactive math helper for young learners"

echo.
echo Creating a story generator module...
python "%CORE_SCRIPT%" create python StoryTime --description "AI-powered story generator for children"

echo.
echo All educational modules created successfully!
echo.
echo You can now customize these modules to make them child-friendly.
echo.
echo Press any key to exit...
pause > nul
exit /b 0