#!/usr/bin/env pwsh
# oc-switch.ps1 — Toggle OpenCode config between free-tier and normal (main) tier
#
# Usage: .\oc-switch.ps1
#
# Detects your opencode config directory, checks which branch is checked out,
# toggles to the other tier, and shows the new state.
#
# Supports: Windows (native PowerShell)

# ── Locate the config directory ──────────────────────────────────────────────

function Find-ConfigDir {
    # 1. OPENCODE_CONFIG env var (may point to a file, take its directory)
    $envPath = [Environment]::GetEnvironmentVariable('OPENCODE_CONFIG', 'User')
    if (-not $envPath) {
        $envPath = [Environment]::GetEnvironmentVariable('OPENCODE_CONFIG', 'Process')
    }
    if ($envPath) {
        $dir = Split-Path $envPath -Parent
        if (Test-Path "$dir\.git") {
            return $dir
        }
    }

    # 2. %APPDATA%\opencode\
    $appDataDir = "$env:APPDATA\opencode"
    if (Test-Path "$appDataDir\.git") {
        return $appDataDir
    }

    # 3. %USERPROFILE%\.opencode\
    $userDir = "$env:USERPROFILE\.opencode"
    if (Test-Path "$userDir\.git") {
        return $userDir
    }

    return $null
}

# ── Main ─────────────────────────────────────────────────────────────────────

$configDir = Find-ConfigDir

if (-not $configDir) {
    Write-Host "❌  Could not find an opencode config directory with a git repo." -ForegroundColor Red
    Write-Host ""
    Write-Host "    Looked in:"
    $ocConfig = [Environment]::GetEnvironmentVariable('OPENCODE_CONFIG', 'User')
    if (-not $ocConfig) { $ocConfig = 'not set' }
    Write-Host "      • OPENCODE_CONFIG -> $(Split-Path $ocConfig -Parent)"
    Write-Host "      • $env:APPDATA\opencode\"
    Write-Host "      • $env:USERPROFILE\.opencode\"
    Write-Host ""
    Write-Host "    Make sure you cloned the repo first (see install.md)."
    exit 1
}

Push-Location $configDir

# Check current branch
$current = git rev-parse --abbrev-ref HEAD

switch ($current) {
    'main' {
        $new = 'free-tier'
        $label = 'Free'
    }
    'free-tier' {
        $new = 'main'
        $label = 'Normal'
    }
    default {
        Write-Host "❌  Unexpected branch '$current'." -ForegroundColor Red
        Write-Host "    Expected 'main' or 'free-tier'."
        Pop-Location
        exit 1
    }
}

Write-Host "🔄  Switching from $current → $new ..."
git checkout $new

$now = git rev-parse --abbrev-ref HEAD
Write-Host ""
Write-Host "✅  Now on $now — ${label} tier" -ForegroundColor Green
Write-Host ""
Write-Host "    Run 'opencode debug config' to verify, then restart OpenCode."

Pop-Location
