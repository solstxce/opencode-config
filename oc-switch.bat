@echo off
REM oc-switch.bat — Switch OpenCode config between tiers
REM                  (main ↔ free-tier ↔ totally-free-tier)
REM
REM Usage: oc-switch [branch]
REM
REM   oc-switch               cycle to the next tier
REM   oc-switch main          switch to Normal tier
REM   oc-switch free          switch to Free tier
REM   oc-switch totally-free  switch to Totally Free tier
REM   oc-switch status        show current tier without switching
REM
REM Supports: Windows (cmd.exe)

setlocal enabledelayedexpansion

REM ── Generate ESC character for ANSI color codes ────────────────────────────
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

REM ── Locate the config directory ─────────────────────────────────────────────

set "CONFIG_DIR="

if defined OPENCODE_CONFIG (
    for %%I in ("%OPENCODE_CONFIG%") do set "CONFIG_DIR=%%~dpI"
    if defined CONFIG_DIR if exist "%CONFIG_DIR%\.git" goto :found
)

if exist "%APPDATA%\opencode\.git" (
    set "CONFIG_DIR=%APPDATA%\opencode"
    goto :found
)

if exist "%USERPROFILE%\.opencode\.git" (
    set "CONFIG_DIR=%USERPROFILE%\.opencode"
    goto :found
)

echo %ESC%[31m❌  Could not find an opencode config directory with a git repo.%ESC%[0m
echo.
echo     Looked in:
if defined OPENCODE_CONFIG (
    for %%I in ("%OPENCODE_CONFIG%") do echo       ^• OPENCODE_CONFIG -^> %%~dpI
) else (
    echo       ^• OPENCODE_CONFIG -^> (not set)
)
echo       ^• %%APPDATA%%\opencode\
echo       ^• %%USERPROFILE%%\.opencode\
echo.
echo     Make sure you cloned the repo first (see install.md).
exit /b 1

:found
cd /d "%CONFIG_DIR%"

REM ── Check current branch ──────────────────────────────────────────────────

for /f %%B in ('git rev-parse --abbrev-ref HEAD') do set "CURRENT=%%B"

REM ── Handle explicit argument ───────────────────────────────────────────────

if not "%1"=="" (
    if /I "%1"=="status" (
        call :show_status "%CURRENT%"
        exit /b 0
    )
    set "TARGET="
    call :resolve "%1"
    if "!TARGET!"=="" (
        echo %ESC%[31m❌  Unknown tier '%1'.%ESC%[0m
        echo     Valid: main, free, totally-free, status
        exit /b 1
    )
    if "!TARGET!"=="%CURRENT%" (
        for /f %%L in ('call :get_label "%CURRENT%"') do set "LABEL=%%L"
        echo 📋  Already on %CURRENT% (!LABEL! tier^).
        exit /b 0
    )
    echo %ESC%[1m🔄  Switching from %CURRENT% → !TARGET! ...%ESC%[0m
    git checkout !TARGET!
    for /f %%L in ('call :get_label "!TARGET!"') do set "LABEL=%%L"
    echo.
    echo %ESC%[32m✅  Now on !TARGET! — !LABEL! tier%ESC%[0m
    echo.
    echo     Run 'opencode debug config' to verify, then restart OpenCode.
    exit /b 0
)

REM ── No argument — cycle to the next tier ───────────────────────────────────

set "CYCLE_0=main"
set "CYCLE_1=free-tier"
set "CYCLE_2=totally-free-tier"

set "IDX=-1"
if "%CURRENT%"=="main"               set "IDX=0"
if "%CURRENT%"=="free-tier"          set "IDX=1"
if "%CURRENT%"=="totally-free-tier"  set "IDX=2"

if "%IDX%"=="-1" (
    echo %ESC%[31m❌  Unexpected branch '%CURRENT%'.%ESC%[0m
    echo     Expected main, free-tier, or totally-free-tier.
    exit /b 1
)

set /a NEXT_IDX=%IDX% + 1
if %NEXT_IDX% gtr 2 set "NEXT_IDX=0"

call :get_cycle %NEXT_IDX% NEW
call :get_label !NEW! LABEL

echo %ESC%[1m🔄  Switching from %CURRENT% → !NEW! ...%ESC%[0m
git checkout !NEW!

echo.
echo %ESC%[32m✅  Now on !NEW! — !LABEL! tier%ESC%[0m
echo.
echo     Run 'opencode debug config' to verify, then restart OpenCode.
exit /b 0

REM ── Helper subroutines ────────────────────────────────────────────────────

:resolve
if /I "%1"=="main"             set "TARGET=main"             & exit /b
if /I "%1"=="normal"           set "TARGET=main"             & exit /b
if /I "%1"=="free"             set "TARGET=free-tier"        & exit /b
if /I "%1"=="free-tier"        set "TARGET=free-tier"        & exit /b
if /I "%1"=="totally-free"     set "TARGET=totally-free-tier" & exit /b
if /I "%1"=="totally-free-tier" set "TARGET=totally-free-tier" & exit /b
if /I "%1"=="tfree"            set "TARGET=totally-free-tier" & exit /b
exit /b

:get_label
if "%1"=="main"               echo Normal     & exit /b
if "%1"=="free-tier"          echo Free       & exit /b
if "%1"=="totally-free-tier"  echo Totally Free & exit /b
echo Unknown & exit /b

:get_cycle
if "%1"=="0" echo main               & exit /b
if "%1"=="1" echo free-tier          & exit /b
if "%1"=="2" echo totally-free-tier  & exit /b
exit /b

:show_status
for /f %%L in ('call :get_label "%1"') do set "SLABEL=%%L"
echo %ESC%[1m📋  Current tier: %SLABEL%  (%1 branch)%ESC%[0m
exit /b
