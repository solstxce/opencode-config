#!/usr/bin/env pwsh
# oc-switch.ps1 — Switch OpenCode config between tiers
#                 (main ↔ free-tier ↔ totally-free-tier)
#
# Usage: .\oc-switch.ps1 [branch]
#
#   .\oc-switch.ps1         cycle to the next tier in order
#   .\oc-switch.ps1 main    switch to Normal tier
#   .\oc-switch.ps1 free    switch to Free tier
#   .\oc-switch.ps1 totally-free  switch to Totally Free tier
#   .\oc-switch.ps1 status  show current tier without switching
#
# Supports: Windows (native PowerShell)

# ── Tier map ─────────────────────────────────────────────────────────────────

$tiers = @{
    'main'               = 'Normal'
    'free-tier'          = 'Free'
    'totally-free-tier'  = 'Totally Free'
}

$cycleOrder = @('main', 'free-tier', 'totally-free-tier')

# ── Resolve alias to branch name ─────────────────────────────────────────────

function Resolve-Branch($alias) {
    switch ($alias) {
        'main'            { return 'main' }
        'normal'          { return 'main' }
        'free'            { return 'free-tier' }
        'free-tier'       { return 'free-tier' }
        'totally-free'    { return 'totally-free-tier' }
        'totally-free-tier' { return 'totally-free-tier' }
        'tfree'           { return 'totally-free-tier' }
        default           { return $null }
    }
}

# ── Locate the config directory ──────────────────────────────────────────────

function Find-ConfigDir {
    $envPath = [Environment]::GetEnvironmentVariable('OPENCODE_CONFIG', 'User')
    if (-not $envPath) {
        $envPath = [Environment]::GetEnvironmentVariable('OPENCODE_CONFIG', 'Process')
    }
    if ($envPath) {
        $dir = Split-Path $envPath -Parent
        if (Test-Path "$dir\.git") { return $dir }
    }

    $appDataDir = "$env:APPDATA\opencode"
    if (Test-Path "$appDataDir\.git") { return $appDataDir }

    $userDir = "$env:USERPROFILE\.opencode"
    if (Test-Path "$userDir\.git") { return $userDir }

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

$current = git rev-parse --abbrev-ref HEAD

# ── Handle explicit argument ─────────────────────────────────────────────────

if ($args.Count -ge 1) {
    $arg = $args[0]

    if ($arg -eq 'status') {
        $label = if ($tiers.ContainsKey($current)) { $tiers[$current] } else { $current }
        Write-Host "📋  Current tier: $label  ($current branch)"
        Pop-Location
        exit 0
    }

    $target = Resolve-Branch $arg
    if (-not $target) {
        Write-Host "❌  Unknown tier '$arg'." -ForegroundColor Red
        Write-Host "    Valid: main, free, totally-free, status"
        Pop-Location
        exit 1
    }

    if ($current -eq $target) {
        Write-Host "📋  Already on $current ($($tiers[$target]) tier)."
        Pop-Location
        exit 0
    }

    Write-Host "🔄  Switching from $current → $target ..."
    git checkout $target
    Write-Host ""
    Write-Host "✅  Now on $target — $($tiers[$target]) tier" -ForegroundColor Green
    Write-Host ""
    Write-Host "    Run 'opencode debug config' to verify, then restart OpenCode."
    Pop-Location
    exit 0
}

# ── No argument — cycle to the next tier ────────────────────────────────────

$idx = $cycleOrder.IndexOf($current)
if ($idx -eq -1) {
    Write-Host "❌  Unexpected branch '$current'." -ForegroundColor Red
    Write-Host "    Expected one of: $($cycleOrder -join ', ')"
    Pop-Location
    exit 1
}

$nextIdx = ($idx + 1) % $cycleOrder.Count
$new = $cycleOrder[$nextIdx]
$label = $tiers[$new]

Write-Host "🔄  Switching from $current → $new ..."
git checkout $new

Write-Host ""
Write-Host "✅  Now on $new — ${label} tier" -ForegroundColor Green
Write-Host ""
Write-Host "    Run 'opencode debug config' to verify, then restart OpenCode."

Pop-Location
