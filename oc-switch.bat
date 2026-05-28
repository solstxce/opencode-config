@echo off
REM oc-switch.bat — Toggle OpenCode config between free-tier and normal (main) tier
REM
REM Usage: oc-switch
REM
REM Detects your opencode config directory, checks which branch is checked out,
REM toggles to the other tier, and shows the new state.
REM
REM Supports: Windows (cmd.exe)

setlocal enabledelayedexpansion

REM ── Generate ESC character for ANSI color codes ────────────────────────────
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

REM ── Locate the config directory ─────────────────────────────────────────────

set "CONFIG_DIR="

REM 1. OPENCODE_CONFIG env var
if defined OPENCODE_CONFIG (
    for %%I in ("%OPENCODE_CONFIG%") do set "CONFIG_DIR=%%~dpI"
    if defined CONFIG_DIR if exist "%CONFIG_DIR%\.git" goto :found
)

REM 2. %APPDATA%\opencode\
if exist "%APPDATA%\opencode\.git" (
    set "CONFIG_DIR=%APPDATA%\opencode"
    goto :found
)

REM 3. %USERPROFILE%\.opencode\
if exist "%USERPROFILE%\.opencode\.git" (
    set "CONFIG_DIR=%USERPROFILE%\.opencode"
    goto :found
)

REM Not found — show error
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

if "%CURRENT%"=="main" (
    set "NEW=free-tier"
    set "LABEL=Free"
) else if "%CURRENT%"=="free-tier" (
    set "NEW=main"
    set "LABEL=Normal"
) else (
    echo %ESC%[31m❌  Unexpected branch '%CURRENT%'.%ESC%[0m
    echo     Expected 'main' or 'free-tier'.
    exit /b 1
)

echo %ESC%[1m🔄  Switching from %CURRENT% → %NEW% ...%ESC%[0m
git checkout %NEW%

for /f %%B in ('git rev-parse --abbrev-ref HEAD') do set "NOW=%%B"
echo.
echo %ESC%[32m✅  Now on %NOW% — %LABEL% tier%ESC%[0m
echo.
echo     Run 'opencode debug config' to verify, then restart OpenCode.
