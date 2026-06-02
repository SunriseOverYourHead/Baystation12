@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo  Baystation12SOYH Build Script
echo ========================================================

set DME=baystation12.dme
set REPO_ROOT=%~dp0..\..\

:: --- Locate DreamMaker ---
set DM_EXE=
set _DM1=%PROGRAMFILES(X86)%\BYOND\bin\dm.exe
set _DM2=%PROGRAMFILES%\BYOND\bin\dm.exe

if exist "%_DM1%" set "DM_EXE=%_DM1%"
if exist "%_DM2%" set "DM_EXE=%_DM2%"

if "%DM_EXE%"=="" goto :no_dm

:: --- Locate bun ---
set BUN_EXE=
set _BUN1=%USERPROFILE%\.bun\bin\bun.exe
set _BUN2=%LOCALAPPDATA%\bun\bun.exe

if exist "%_BUN1%" set "BUN_EXE=%_BUN1%"
if exist "%_BUN2%" set "BUN_EXE=%_BUN2%"

if not "%BUN_EXE%"=="" goto :have_bun
where bun >nul 2>&1
if not errorlevel 1 set "BUN_EXE=bun"

:have_bun
if "%BUN_EXE%"=="" goto :no_bun

echo Using DreamMaker : %DM_EXE%
echo Using bun        : %BUN_EXE%
echo.

:: ============================================================
:: Step 1 - Install TGUI dependencies
:: ============================================================
echo [1/3] Installing TGUI dependencies...
echo --------------------------------------------------------
pushd "%REPO_ROOT%tgui"
"%BUN_EXE%" install --frozen-lockfile
if errorlevel 1 goto :bun_install_fail
popd
echo [1/3] Done.
echo.

:: ============================================================
:: Step 2 - Build TGUI
:: ============================================================
echo [2/3] Building TGUI...
echo --------------------------------------------------------
pushd "%REPO_ROOT%tgui"
"%BUN_EXE%" run tgui:build
if errorlevel 1 goto :tgui_fail
popd
echo [2/3] Done.
echo.

:: ============================================================
:: Step 3 - Compile DME
:: ============================================================
echo [3/3] Compiling %DME%...
echo --------------------------------------------------------
pushd "%REPO_ROOT%"
"%DM_EXE%" "%DME%"
if errorlevel 1 goto :dm_fail
popd
echo [3/3] Done.

echo.
echo ========================================================
echo  BUILD SUCCESSFUL
echo ========================================================
exit /b 0

:no_dm
echo [ERROR] DreamMaker not found.
echo         Checked: %_DM1%
echo         Checked: %_DM2%
goto :fail

:no_bun
echo [ERROR] bun not found. Install from https://bun.sh
goto :fail

:bun_install_fail
popd
echo [ERROR] bun install failed.
goto :fail

:tgui_fail
popd
echo [ERROR] TGUI build failed.
goto :fail

:dm_fail
popd
echo [ERROR] DreamMaker compilation failed.
goto :fail

:fail
echo.
echo ========================================================
echo  BUILD FAILED
echo ========================================================
exit /b 1
