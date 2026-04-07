# dev-setup — GitHub Copilot Developer Environment

> Automated setup script for GitHub Copilot tooling on Windows.  
> Designed for **.NET developers** using Visual Studio Code, Visual Studio terminal, and Windows Terminal.

---

## What This Repository Does

This repository contains a single PowerShell script — `setup-copilot-dev.ps1` — that detects what is already installed on your machine and installs only what is missing. It sets up a complete GitHub Copilot development environment without requiring Node.js.

---

## What Gets Installed

| Tool | Purpose | Installed Via |
|---|---|---|
| **Visual Studio Code** | Primary editor with Copilot integration | winget |
| **GitHub CLI (`gh`)** | GitHub operations from the terminal | winget |
| **`gh copilot` subcommand** | Quick command suggestions & explanations | Built-in since gh v2.64.0 |
| **GitHub Copilot CLI** | Full interactive AI agent in the terminal (`copilot`) | winget (`GitHub.Copilot`) |
| **`suggest` alias** | Shorthand for `gh copilot suggest` in PowerShell | Registered in `$PROFILE` |
| **GitHub Copilot** (VS Code) | Inline AI code completions | code --install-extension |
| **GitHub Copilot Chat** (VS Code) | Conversational AI in the editor sidebar | code --install-extension |

> **Node.js is NOT required.** This setup works entirely through winget and the GitHub CLI.  
> **No gh extension install needed.** `gh copilot` has been built into GitHub CLI since v2.64.0.

---

## Prerequisites

Before running the script, you need:

| Requirement | Notes |
|---|---|
| **Windows 10 / 11** | winget is built into both |
| **winget** (App Installer) | Pre-installed on Windows 11; update via Microsoft Store if missing: https://aka.ms/getwinget |
| **PowerShell 5.1 or later** | Included with Windows; use Windows Terminal or VS Developer PowerShell |
| **Internet access** | Required to download tools and authenticate |
| **GitHub account** | Free account at https://github.com |
| **GitHub Copilot subscription** | Free trial or paid plan at https://github.com/features/copilot |

---

## How to Run

### Option 1 — Allow Execution for This Session Only (Recommended)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup-copilot-dev.ps1
```

### Option 2 — Run Directly with Bypass Flag

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-copilot-dev.ps1
```

### Option 3 — Temporarily Change Policy for Current User

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\setup-copilot-dev.ps1
```

---

## GitHub Authentication

The script calls `gh auth status` to check if you are already logged in. If not, it launches `gh auth login` automatically.

**What to expect during login:**

1. You will be asked to choose: **GitHub.com** or **GitHub Enterprise Server** → select **GitHub.com**
2. Choose authentication method: **Login with a web browser** (recommended) or **Paste an authentication token**
3. If using browser: copy the one-time code shown, press Enter, and complete the flow in your browser
4. The CLI will confirm: `Logged in to github.com as <your-username>`

To check authentication at any time:

```powershell
gh auth status
```

---

## Verification Commands

After the script completes, verify your setup:

```powershell
# Check VS Code version
code --version

# Check GitHub CLI version
gh --version

# Check GitHub authentication
gh auth status

# Check gh copilot subcommand (built-in — no extension required)
gh copilot --help

# Launch the full interactive Copilot agent (chat experience)
copilot

# Quick one-liner suggestion (via alias)
suggest "create a .NET Web API controller"

# Or using gh directly
gh copilot suggest "create a .NET Web API controller"

# Explain a command
gh copilot explain "git rebase -i HEAD~3"

# List installed VS Code extensions (filter for Copilot)
code --list-extensions | Select-String copilot
```

---

## Node.js Clarification

**This setup does not require Node.js.**

`gh copilot` is a built-in command in GitHub CLI v2.64.0 and later — no extension install, no npm, no npx, and no Node.js dependency. The script verifies your `gh` version supports it and exits with a clear upgrade message if not.

---

## Troubleshooting

### `winget` is not recognized

Update **App Installer** from the Microsoft Store:  
https://aka.ms/getwinget

### Script won't run — execution policy error

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### `code` command not found after install

Restart your terminal. VS Code adds itself to PATH during installation, but the current session needs to be refreshed.

### `gh auth login` opens a browser but hangs

Try the token-based flow instead:

```powershell
gh auth login --with-token
```

Generate a token at: https://github.com/settings/tokens  
Required scopes: `repo`, `read:org`, `gist`

### VS Code extensions didn't install

Ensure VS Code is fully installed and `code` is on your PATH, then run manually:

```powershell
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
```

### Copilot CLI returns "You are not authorized"

You need an active **GitHub Copilot subscription**. Check at:  
https://github.com/settings/copilot

---

## Project Structure

```
dev-setup/
├── setup-copilot-dev.ps1     # Main automated setup script
├── README.md                 # This file — full documentation
└── NEW-DEVELOPER-SETUP.md    # Step-by-step beginner onboarding guide
```

## What the Script Does (Step by Step)

| Step | Action |
|---|---|
| 1 | Verify **winget** is available |
| 2 | Install **Visual Studio Code** if not present |
| 3 | Install **GitHub CLI** if not present |
| 4 | Authenticate with GitHub (`gh auth login`) if not already logged in |
| 5 | Verify **`gh copilot`** subcommand is available (built-in since gh v2.64.0) |
| 6 | Install **GitHub Copilot CLI** — the full interactive terminal agent (`copilot`) |
| 7 | Register a **`suggest` alias** in your PowerShell `$PROFILE` for quick one-liners |
| 8 | Install **GitHub Copilot** and **GitHub Copilot Chat** VS Code extensions |
| 9 | Run a final verification and print a success summary |

---

## Summary

1. Clone this repository
2. Open PowerShell (Windows Terminal or VS Developer PowerShell)
3. Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
4. Run `.\setup-copilot-dev.ps1`
5. Follow the GitHub login prompts if prompted
6. Run `copilot` to open the full interactive Copilot agent, or `suggest "..."` for quick one-liners, and use GitHub Copilot inside VS Code

---

*Maintained by the product team. Node.js not required. No gh extension install required.*
