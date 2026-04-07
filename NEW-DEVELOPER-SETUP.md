# New Developer Setup Guide

Welcome to the team! This guide walks you through setting up GitHub Copilot on your Windows machine, step by step.

> **No prior experience required.** Follow each step in order.  
> **Node.js is NOT required** for any part of this setup.

---

## Before You Start

Make sure you have:

- [ ] A **GitHub account** — create one free at https://github.com
- [ ] A **GitHub Copilot subscription** — activate at https://github.com/features/copilot  
      *(A free trial is available for new users)*
- [ ] **Internet access**
- [ ] **Windows 10 or Windows 11**

---

## Step 1 — Open PowerShell

You can use any of the following:

- **Windows Terminal** *(recommended)*: Press `Win + X` → click **Windows Terminal**
- **PowerShell**: Press `Win`, type `PowerShell`, click **Windows PowerShell**
- **VS Code Terminal**: Open VS Code → press `` Ctrl+` ``
- **Visual Studio Developer PowerShell**: Open Visual Studio → **View** → **Terminal**

> You do **not** need to run as Administrator for most steps. The script will work for standard user accounts.

---

## Step 2 — Clone the Repository

In PowerShell, run:

```powershell
git clone https://github.com/YOUR-ORG/dev-setup.git
```

> Replace `YOUR-ORG` with your organization or team name as provided by your team lead.

---

## Step 3 — Navigate to the Folder

```powershell
cd dev-setup
```

Confirm you are in the right place:

```powershell
Get-ChildItem
```

You should see:

```
setup-copilot-dev.ps1
README.md
NEW-DEVELOPER-SETUP.md
```

---

## Step 4 — Allow the Script to Run

Windows blocks scripts by default. Run this to allow it **for this session only** (safest option):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

> This only affects the current PowerShell window. It resets automatically when you close the terminal.

---

## Step 5 — Run the Setup Script

```powershell
.\setup-copilot-dev.ps1
```

The script will:

1. Check that **winget** is available
2. Check if **Visual Studio Code** is installed — install it if not
3. Check if **GitHub CLI** is installed — install it if not
4. Check if you are **logged in to GitHub** — prompt you to log in if not
5. Verify the **`gh copilot` subcommand** is available (built-in since gh v2.64.0+)
6. Install the **GitHub Copilot CLI** — the full interactive terminal agent (just type `copilot` to start)
7. Register a **`suggest` alias** in your PowerShell profile for quick one-liner suggestions
8. Check if **VS Code Copilot extensions** are installed — install them if not
9. Run a **final verification** and print a success message

---

## Step 6 — Log In to GitHub (if prompted)

If you are not already logged in, the script will launch `gh auth login` automatically.

**What you will see:**

```
? What account do you want to log into?
> GitHub.com
  GitHub Enterprise Server
```

→ Select **GitHub.com** and press Enter.

```
? What is your preferred protocol for Git operations?
> HTTPS
  SSH
```

→ Select **HTTPS** and press Enter.

```
? How would you like to authenticate GitHub CLI?
> Login with a web browser
  Paste an authentication token
```

→ Select **Login with a web browser** and press Enter.

**Copy the one-time code** shown in the terminal, then press Enter. Your browser will open — paste the code and authorize the application.

Once done, the terminal will confirm:

```
✓ Logged in to github.com as your-username
```

---

## What Gets Installed

| Tool | What It Does |
|---|---|
| **Visual Studio Code** | Code editor with built-in Copilot support |
| **GitHub CLI (`gh`)** | Interact with GitHub from the terminal |
| **`gh copilot` subcommand** | Quick command suggestions & explanations — built into gh v2.64.0+ |
| **GitHub Copilot CLI** | Full interactive AI agent in your terminal — just type `copilot` to start a chat |
| **`suggest` alias** | Shorthand: type `suggest "..."` instead of `gh copilot suggest "..."` |
| **GitHub Copilot** (VS Code extension) | Inline AI code completions while you type |
| **GitHub Copilot Chat** (VS Code extension) | Chat with Copilot in the VS Code sidebar |

---

## Step 7 — Verify Everything Works

Run these commands one by one to confirm your setup:

```powershell
# Check VS Code
code --version

# Check GitHub CLI
gh --version

# Check you're logged in
gh auth status

# Check the gh copilot subcommand (built-in — no extension needed)
gh copilot --help
```

**Launch the full interactive Copilot agent (chat experience):**

```powershell
copilot
```

This opens an interactive session — just like having a conversation with an AI developer. You can ask it to write code, explain errors, edit files, run commands, and more.

**For quick one-liner suggestions, use the `suggest` alias:**

```powershell
suggest "create a .NET Web API controller"
```

**Or use `gh copilot` directly:**

```powershell
gh copilot suggest "create a .NET Web API controller"
gh copilot explain "dotnet ef migrations add InitialCreate"
```

---

## Using Copilot in VS Code

1. Open VS Code: type `code .` in your terminal or launch it from the Start menu
2. Sign in with GitHub if prompted (top-right corner)
3. Start typing in any file — Copilot will suggest completions in gray text
4. Press `Tab` to accept a suggestion
5. Open **Copilot Chat**: click the chat icon in the left sidebar or press `Ctrl+Alt+I`

---

## Notes

| Topic | Detail |
|---|---|
| **Node.js** | Not required. This setup uses winget and built-in gh commands only. |
| **gh extension** | Not required. `gh copilot` is built into GitHub CLI v2.64.0+. |
| **Admin rights** | Not required in most cases. winget installs to user scope by default. |
| **Time to complete** | Approximately 5–15 minutes depending on internet speed. |
| **Re-running the script** | Safe to run multiple times. It skips anything already installed. |
| **`suggest` alias** | The script registers `function suggest { gh copilot suggest @args }` in your `$PROFILE`. Restart your terminal once after setup to activate it. |
| **`copilot` command** | The full interactive GitHub Copilot CLI agent — installed as a standalone binary. Type `copilot` to start a chat session. |
| **Copilot subscription** | Required for `copilot`, `suggest`, and in-editor completions. The free GitHub account is not enough on its own. |

---

## Troubleshooting

### "winget is not recognized"

Update **App Installer** from the Microsoft Store:  
https://aka.ms/getwinget

Then close and reopen your terminal and try again.

---

### "running scripts is disabled on this system"

Run this first:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

### `code` command not found

Close your terminal completely and reopen it. VS Code adds itself to PATH during installation, but the current session won't see it until it restarts.

---

### GitHub login failed or browser didn't open

Try the token method:

1. Go to https://github.com/settings/tokens
2. Click **Generate new token (classic)**
3. Select scopes: `repo`, `read:org`, `gist`
4. Copy the token
5. Run:

```powershell
gh auth login --with-token
```

Paste the token when prompted.

---

### "You are not authorized to use Copilot"

Your GitHub account does not have an active Copilot subscription.

Activate one at: https://github.com/settings/copilot

---

### VS Code extensions didn't install

Run these manually:

```powershell
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
```

---

## You're All Set!

Once everything is green, you're ready to develop with GitHub Copilot.

```
########################################################
#                                                      #
#         Setup Complete - You're Ready to Code!       #
#                                                      #
########################################################
```

Welcome to the team. If you run into any issues not covered here, reach out to your team lead or open an issue in this repository.
