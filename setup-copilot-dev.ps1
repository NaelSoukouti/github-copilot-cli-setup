#Requires -Version 5.1
<#
.SYNOPSIS
    GitHub Copilot Developer Environment Setup Script

.DESCRIPTION
    Installs and configures GitHub Copilot tooling for .NET developers on Windows.
    Includes: Visual Studio Code, GitHub CLI (with built-in Copilot CLI), VS Code extensions,
    and a standalone 'copilot' PowerShell alias so you can run 'copilot suggest ...' directly.
    Does NOT require Node.js.

.NOTES
    Run with:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
        .\setup-copilot-dev.ps1
#>

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------------------------

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "    [OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "    [WARN] $Message" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "########################################################" -ForegroundColor DarkCyan
Write-Host "#                                                      #" -ForegroundColor DarkCyan
Write-Host "#        GitHub Copilot Dev Environment Setup          #" -ForegroundColor DarkCyan
Write-Host "#                                                      #" -ForegroundColor DarkCyan
Write-Host "########################################################" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "  Target: Windows / PowerShell / .NET / VS Code" -ForegroundColor Gray
Write-Host "  Note:   Node.js is NOT required." -ForegroundColor Gray
Write-Host ""

# ---------------------------------------------------------------------------
# Step 1: Verify winget is available
# ---------------------------------------------------------------------------

Write-Step "Checking for winget (Windows Package Manager)..."

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  [ERROR] winget is not available on this machine." -ForegroundColor Red
    Write-Host ""
    Write-Host "  To install winget, update 'App Installer' from the Microsoft Store:" -ForegroundColor Yellow
    Write-Host "  https://aka.ms/getwinget" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}


Write-Ok "winget is available: $(winget --version)"

# ---------------------------------------------------------------------------
# Step 2: Install Visual Studio Code
# ---------------------------------------------------------------------------

Write-Step "Checking for Visual Studio Code..."

$vscodePath = Get-Command code -ErrorAction SilentlyContinue

if ($vscodePath) {
    Write-Ok "VS Code is already installed: $(code --version | Select-Object -First 1)"
} else {
    Write-Warn "VS Code not found. Installing via winget..."
    winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements

    # Refresh PATH so 'code' is immediately available
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")

    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Ok "VS Code installed successfully."
    } else {
        Write-Warn "VS Code installed but 'code' command not yet on PATH. You may need to restart your terminal."
    }
}

# ---------------------------------------------------------------------------
# Step 3: Install GitHub CLI
# ---------------------------------------------------------------------------

Write-Step "Checking for GitHub CLI (gh)..."

$ghPath = Get-Command gh -ErrorAction SilentlyContinue

if ($ghPath) {
    Write-Ok "GitHub CLI is already installed: $(gh --version | Select-Object -First 1)"
} else {
    Write-Warn "GitHub CLI not found. Installing via winget..."
    winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements

    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Ok "GitHub CLI installed successfully: $(gh --version | Select-Object -First 1)"
    } else {
        Write-Host "  [ERROR] GitHub CLI installation failed or PATH refresh required." -ForegroundColor Red
        Write-Host "          Please restart your terminal and re-run this script." -ForegroundColor Yellow
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Step 4: GitHub Authentication
# ---------------------------------------------------------------------------

Write-Step "Checking GitHub authentication status..."

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Ok "Already authenticated with GitHub."
    Write-Host "    $($authStatus | Select-Object -First 1)" -ForegroundColor Gray
} else {
    Write-Warn "Not authenticated. Launching GitHub login..."
    Write-Host ""
    Write-Host "  Follow the prompts to authenticate via browser or token." -ForegroundColor Gray
    Write-Host ""
    gh auth login

    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] GitHub authentication failed. Exiting." -ForegroundColor Red
        exit 1
    }
    Write-Ok "GitHub authentication successful."
}

# ---------------------------------------------------------------------------
# Step 5: Verify GitHub Copilot CLI (built-in since gh v2.64.0)
# ---------------------------------------------------------------------------

Write-Step "Checking for GitHub Copilot CLI..."

# gh copilot is a built-in command as of gh v2.64.0 — no extension needed.
$copilotHelp = gh copilot --help 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Ok "GitHub Copilot CLI is available (built into gh)."
} else {
    Write-Host "  [ERROR] 'gh copilot' is not available. Please upgrade GitHub CLI to v2.64.0 or later." -ForegroundColor Red
    Write-Host "          Run: winget upgrade --id GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------------------------
# Step 6: Register standalone 'copilot' alias in PowerShell profile
# ---------------------------------------------------------------------------

Write-Step "Registering standalone 'copilot' command..."

$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
$aliasMarker    = "# gh-copilot-alias"

if ($profileContent -match [regex]::Escape($aliasMarker)) {
    Write-Ok "'copilot' alias already registered in PowerShell profile."
} else {
    $aliasBlock = @"

$aliasMarker
function copilot { gh copilot @args }
"@
    Add-Content -Path $PROFILE -Value $aliasBlock
    Write-Ok "'copilot' alias added to: $PROFILE"
    Write-Warn "Restart your terminal (or run '. `$PROFILE') to activate the alias."
}

# Make alias available immediately in this session
if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
    function global:copilot { gh copilot @args }
}

# ---------------------------------------------------------------------------
# Step 7: Install VS Code Extensions
# ---------------------------------------------------------------------------

Write-Step "Checking VS Code extensions for GitHub Copilot..."

$requiredExtensions = @(
    @{ Id = "GitHub.copilot";      Name = "GitHub Copilot" },
    @{ Id = "GitHub.copilot-chat"; Name = "GitHub Copilot Chat" }
)

$installedExtensions = code --list-extensions 2>&1

foreach ($ext in $requiredExtensions) {
    if ($installedExtensions -contains $ext.Id) {
        Write-Ok "$($ext.Name) ($($ext.Id)) is already installed."
    } else {
        Write-Warn "$($ext.Name) not found. Installing..."
        code --install-extension $ext.Id

        $installedExtensions = code --list-extensions 2>&1
        if ($installedExtensions -contains $ext.Id) {
            Write-Ok "$($ext.Name) installed successfully."
        } else {
            Write-Warn "Could not verify $($ext.Name). It may still be installing."
        }
    }
}

# ---------------------------------------------------------------------------
# Step 8: Final Verification
# ---------------------------------------------------------------------------

Write-Step "Running final verification..."

Write-Host ""
Write-Host "  -- VS Code Version --" -ForegroundColor Gray
code --version

Write-Host ""
Write-Host "  -- GitHub Copilot CLI Help --" -ForegroundColor Gray
gh copilot --help

Write-Host ""
Write-Host "  -- Installed VS Code Extensions (Copilot) --" -ForegroundColor Gray
code --list-extensions | Where-Object { $_ -match "copilot" }

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "########################################################" -ForegroundColor DarkGreen
Write-Host "#                                                      #" -ForegroundColor DarkGreen
Write-Host "#         Setup Complete - You're Ready to Code!       #" -ForegroundColor DarkGreen
Write-Host "#                                                      #" -ForegroundColor DarkGreen
Write-Host "########################################################" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "  Quick start commands:" -ForegroundColor White
Write-Host "    copilot suggest `"create a .NET Web API controller`"" -ForegroundColor DarkYellow
Write-Host "    copilot explain `"git rebase -i HEAD~3`"" -ForegroundColor DarkYellow
Write-Host "    gh copilot suggest ... (also works)" -ForegroundColor DarkYellow
Write-Host "    code .        (open current folder in VS Code)" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  Happy coding!" -ForegroundColor Green
Write-Host ""
