@echo off
color 0A
title AI Adventure for Kids!
mode con: cols=80 lines=25

echo.
echo  *************************************************
echo  *                                               *
echo  *          WELCOME TO AI ADVENTURE!             *
echo  *                                               *
echo  *   A fun way to learn about AI technology      *
echo  *                                               *
echo  *************************************************
echo.
echo.

:: Set paths
set "BASE_DIR=%~dp0.."
set "CORE_SCRIPT=%BASE_DIR%\secureme_core.py"

echo What would you like to do today? Choose a number:
echo.
echo  1. Meet the Animal Friend - Learn about animals!
echo  2. Math Helper - Get help with math problems
echo  3. Story Time - Create a fun story with AI
echo  4. Exit Adventure
echo.

choice /C 1234 /N /M "Type a number (1-4): "

if %ERRORLEVEL% EQU 1 goto animals
if %ERRORLEVEL% EQU 2 goto math
if %ERRORLEVEL% EQU 3 goto story
if %ERRORLEVEL% EQU 4 goto exit_program

:animals
cls
echo.
echo  *************************************************
echo  *                                               *
echo  *           ANIMAL FRIENDS TIME!                *
echo  *                                               *
echo  *************************************************
echo.
echo Loading your animal adventure...
echo (This will use our special AI to recognize animals!)
echo.
python "%CORE_SCRIPT%" start module --module AnimalFriends
goto exit_program

:math
cls
echo.
echo  *************************************************
echo  *                                               *
echo  *            MATH HELPER TIME!                  *
echo  *                                               *
echo  *************************************************
echo.
echo Loading your math adventure...
echo (This will help you learn math in a fun way!)
echo.
python "%CORE_SCRIPT%" start module --module MathHelper
goto exit_program

:story
cls
echo.
echo  *************************************************
echo  *                                               *
echo  *             STORY TIME!                       *
echo  *                                               *
echo  *************************************************
echo.
echo Loading your story adventure...
echo (Let's create an amazing story together!)
echo.
python "%CORE_SCRIPT%" start module --module StoryTime
goto exit_program

:exit_program
echo.
echo Thank you for playing with AI Adventure!
echo Come back soon for more learning fun!
echo.
echo Press any key to exit...
pause > nul
exit /b 0