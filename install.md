# Install — OpenCode Personal Configuration

This guide walks you through installing **this configuration** (agents, prompts, skills,
commands, permissions) onto your machine so OpenCode picks them up as your
global config.

> **Before you begin:** You need [OpenCode](https://opencode.ai) itself installed.
> See [opencode.ai/docs/#install](https://opencode.ai/docs/#install) for all
> installation methods (curl, npm, Homebrew, pacman, Chocolatey, Scoop, Docker).
>
> **Repo:** <https://github.com/solstxce/opencode-config/>
>
> **First decision:** Decide whether you want the [**Free tier** or **Normal
> tier**](#choose-your-tier) — the installation steps reference your choice.

---

## Repository structure

```
opencode.json          # Main config: agents, permissions, models, defaults
opencode.jsonc         # Minimal override template (used on Windows)
oc-switch              # CLI toggle script (Linux / macOS / WSL)
oc-switch.ps1          # CLI toggle script (Windows PowerShell)
oc-switch.bat          # CLI toggle script (Windows cmd.exe)
prompts/               # System prompts for each agent
skills/                # Custom skill definitions (code-review, planning, simplify)
commands/              # Custom slash commands
install.md             # This file
```

> Files marked with `.gitignore` (`node_modules/`, `package.json`, etc.) are
> local development artifacts and are not part of the config — safe to ignore.

---

## How OpenCode finds config

OpenCode merges config from several sources (later ones override earlier ones):

| # | Source | Path |
|---|--------|------|
| 1 | Remote (org-wide) | `.well-known/opencode` |
| 2 | **Global (user)** | `~/.config/opencode/opencode.json` |
| 3 | Custom path | `$OPENCODE_CONFIG` env var |
| 4 | Project | `<project>/opencode.json` |
| 5 | `.opencode` dirs | `<project>/.opencode/` |
| 6 | Inline | `$OPENCODE_CONFIG_CONTENT` env var |
| 7 | Managed (admin) | OS-managed config directory |
| 8 | MDM (macOS only) | `.mobileconfig` preferences |

**This repo is meant to be placed at the Global (user) level** — the
`~/.config/opencode/` directory. Every OpenCode session will then use your
agents, prompts, permissions, and skills.

### Subdirectory naming

The global `~/.config/opencode/` directory and any `.opencode/` directory use
**plural** names:

```
~/.config/opencode/
├── opencode.json        # or opencode.jsonc
├── agents/              # (or agent/)
├── commands/            # (or command/)
├── modes/               # (or mode/)
├── plugins/             # (or plugin/)
├── skills/              # (or skill/)
├── tools/               # (or tool/)
└── themes/              # (or theme/)
```

> Singular names (e.g., `agent/`) are also accepted for backwards compatibility.

---

## Choose your tier

This repo uses **git branches** to switch between tiers. Pick the one that
fits your setup, then clone / check out the corresponding branch.

| Tier | Branch | Models used | API keys needed |
|------|--------|-------------|-----------------|
| **Normal** | `main` | `opencode-go/glm-5.1` (build), `openai/gpt-5.5` (plan & expert-review), `opencode-go/deepseek-v4-pro` (reviewer), `opencode/deepseek-v4-flash-free` (general, explore, executor) | OpenAI, OpenCode Go |
| **Free** | `free-tier` | `opencode/big-pickle` (build), `openai/gpt-5.5` (plan & expert-review), `opencode/mimo-v2.5-free` (reviewer), `opencode/deepseek-v4-flash-free` (general, explore, executor, small) | OpenAI (plan & review only) |

> **Important:** OpenCode itself is [always free and open source](https://github.com/anomalyco/opencode). The tiers differ only in which third-party LLM models are used for agent tasks.

### Normal tier (`main`)

The full-power config. Requires API keys for OpenAI and OpenCode Go. Use this
if you already have keys or are willing to set them up.

- **Setup:** Clone the `main` branch — no edits needed.
- **Keys needed:** OpenAI (`OPENAI_API_KEY`), OpenCode Go (via `/connect`)

### Free tier (`free-tier`)

A lighter config that replaces the two most expensive agent models (`build`
and `reviewer`) with free alternatives from the `opencode/` provider. Plan
and expert-reviewer still use `openai/gpt-5.5` (you'll need an OpenAI key for
those), but day-to-day coding uses free models.

- **Setup:** Clone the `free-tier` branch instead of `main`.
- **Keys needed:** OpenAI (`OPENAI_API_KEY`) for plan and expert-review agents
  only.

### Which branch to clone

When you see clone commands in the platform instructions below, append the
branch name for the tier you chose:

```bash
# Normal tier
git clone https://github.com/solstxce/opencode-config.git ~/.config/opencode

# Free tier
git clone -b free-tier https://github.com/solstxce/opencode-config.git ~/.config/opencode
```

---

## Installation by platform

### Linux

1. **Install OpenCode** (if you haven't already):

   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

   Or via your package manager:
   ```bash
   # Homebrew (Linux)
   brew install anomalyco/tap/opencode

   # Arch Linux
   sudo pacman -S opencode

   # Arch Linux (latest from AUR)
   paru -S opencode-bin

   # Node.js (any distro)
   npm install -g opencode-ai
   ```

2. **Clone or copy this repo** into the global config directory:

   ```bash
   mkdir -p ~/.config/opencode
   ```

   **Option A — Clone (recommended for updates):**

   Choose your tier's branch when cloning:

   ```bash
   # Normal tier
   git clone https://github.com/solstxce/opencode-config.git ~/.config/opencode

   # Free tier
   git clone -b free-tier https://github.com/solstxce/opencode-config.git ~/.config/opencode
   ```

   **Option B — Symlink (keep repo elsewhere, maintain your own copy):**

   First clone to your preferred location with the right branch, then symlink:
   ```bash
   git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git /path/to/repo
   ln -sf /path/to/repo ~/.config/opencode
   ```

   **Option C — Copy files manually:**
   ```bash
   git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git /tmp/opencode-config
   cp -r /tmp/opencode-config/* ~/.config/opencode/
   rm -rf /tmp/opencode-config
   ```

3. **Verify** the config is picked up:

   ```bash
   opencode debug config
   ```

   You should see your agents, permissions, and model settings in the output.

4. **Optional — Custom location with `OPENCODE_CONFIG`:**

   If you prefer to keep the config elsewhere (e.g., `~/.opencode/`):
   ```bash
   # Clone the tier you want
   git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git ~/.opencode
   export OPENCODE_CONFIG="$HOME/.opencode/opencode.json"
   ```
   Add the `export` to your `~/.bashrc`, `~/.zshrc`, or equivalent.

---

### macOS

1. **Install OpenCode** (if you haven't already):

   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

   Or via Homebrew (recommended):
   ```bash
   brew install anomalyco/tap/opencode
   ```

   Or via Node.js:
   ```bash
   npm install -g opencode-ai
   ```

2. **Clone or copy this repo** into the global config directory:

   ```bash
   mkdir -p ~/.config/opencode
   ```

   **Option A — Clone (recommended for updates):**

   Choose your tier's branch when cloning:

   ```bash
   # Normal tier
   git clone https://github.com/solstxce/opencode-config.git ~/.config/opencode

   # Free tier
   git clone -b free-tier https://github.com/solstxce/opencode-config.git ~/.config/opencode
   ```

   **Option B — Symlink:**
   ```bash
   git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git /path/to/repo
   ln -sf /path/to/repo ~/.config/opencode
   ```

   **Option C — Copy manually:**
   ```bash
   git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git /tmp/opencode-config
   cp -r /tmp/opencode-config/* ~/.config/opencode/
   rm -rf /tmp/opencode-config
   ```

3. **Verify:**

   ```bash
   opencode debug config
   ```

4. **Alternative — macOS managed preferences (enterprise MDM):**

   For organization-wide enforced config, deploy a `.mobileconfig` with
   `PayloadType: ai.opencode.managed`. Place it at:
   - `/Library/Managed Preferences/<user>/ai.opencode.managed.plist`
   - `/Library/Managed Preferences/ai.opencode.managed.plist`

   See [opencode.ai/docs/config/#managed-settings](https://opencode.ai/docs/config/#managed-settings)
   for the `.mobileconfig` format.

---

### Windows

OpenCode supports Windows natively or via WSL. The options below are listed
in priority order — start with Option A first, and only move to the next if it
doesn't suit your setup.

#### Option A — Using `C:\Users\<YOU>\.opencode\` (closest to this repo's structure)

If you already have a `C:\Users\<YOU>\.opencode\opencode.json` file (or want
to create one), point OpenCode at it via the `OPENCODE_CONFIG` environment
variable. This keeps your config in your user profile, outside `AppData`.

1. **Clone the repo** (choose your tier's branch) into your `.opencode` folder:

   ```powershell
   cd "$env:USERPROFILE"

   # Normal tier
   git clone https://github.com/solstxce/opencode-config.git .opencode

   # Free tier
   git clone -b free-tier https://github.com/solstxce/opencode-config.git .opencode
   ```

   > If `.opencode` already exists with your own `opencode.json`, clone into a
   > temp directory and copy files over instead:
   > ```powershell
   > git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git C:\temp\opencode-config
   > Copy-Item -Path "C:\temp\opencode-config\*" -Destination "$env:USERPROFILE\.opencode\" -Recurse
   > ```

2. **Tell OpenCode where to find it** via the `OPENCODE_CONFIG` environment
   variable. Open a PowerShell prompt as Administrator and run:

   ```powershell
   [System.Environment]::SetEnvironmentVariable('OPENCODE_CONFIG', "$env:USERPROFILE\.opencode\opencode.json", 'User')
   ```

   Or set it manually: **System Properties → Advanced → Environment Variables →
   New** → Variable name `OPENCODE_CONFIG`, value `%USERPROFILE%\.opencode\opencode.json`.

3. **Restart your terminal** and verify:

   ```powershell
   opencode debug config
   ```

#### Option B — Native Windows (PowerShell/cmd)

Install OpenCode directly on Windows and place the config in the standard
global config directory (`%APPDATA%\opencode`).

1. **Install OpenCode** using one of these methods:

   ```powershell
   # Chocolatey
   choco install opencode

   # Scoop
   scoop install opencode

   # npm
   npm install -g opencode-ai

   # Mise
   mise use -g github:anomalyco/opencode
   ```

2. **Create the global config directory** and install this config:

   The global config directory on Windows is:
   ```
   %APPDATA%\opencode\
   ```
   which typically resolves to:
   ```
   C:\Users\<YOU>\AppData\Roaming\opencode\
   ```

   **Using PowerShell:**
   ```powershell
   # Clone directly (choose your tier's branch)
   git clone -b <main|free-tier> https://github.com/solstxce/opencode-config.git "$env:APPDATA\opencode"

   # Or copy from your .opencode folder
   Copy-Item -Path "$env:USERPROFILE\.opencode\*" -Destination "$env:APPDATA\opencode\" -Recurse
   ```

3. **Verify:**

   ```powershell
   opencode debug config
   ```

#### Option C — Windows Subsystem for Linux (WSL)

Use this if you prefer a Linux environment on Windows. WSL provides the best
terminal and tooling compatibility.

1. **Install WSL** (if not already installed):

   ```powershell
   wsl --install
   ```

   Follow the [official Microsoft guide](https://learn.microsoft.com/en-us/windows/wsl/install).

2. **Install OpenCode inside WSL:**

   Open your WSL terminal (Ubuntu, etc.) and run:
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

3. **Install this config in the WSL environment:**

   ```bash
   mkdir -p ~/.config/opencode

   # Normal tier
   git clone https://github.com/solstxce/opencode-config.git ~/.config/opencode

   # Free tier
   git clone -b free-tier https://github.com/solstxce/opencode-config.git ~/.config/opencode
   ```

   Or copy from your Windows `.opencode` folder:
   ```bash
   cp -r /mnt/c/Users/YourName/.opencode/* ~/.config/opencode/
   ```

4. **Verify:**

   ```bash
   opencode debug config
   ```

---

## Verifying the installation

After installing, run:

```bash
opencode debug config
```

This prints the **resolved** configuration — everything merged from all sources.
Look for:

- Your `agent` definitions (build, plan, explore, executor, reviewer, expert-reviewer)
- Your `permission` rules (denied paths, ask-on-dangerous-commands)
- Your `model` defaults
- `autoupdate`, `compaction`, `tool_output` settings

If something is missing, check:

1. The config file is valid JSON (or JSONC). Use `opencode debug config` to see
   parse errors.
2. The file is at one of the [recognised locations](#how-opencode-finds-config).
3. There are no conflicting settings in a project-level `opencode.json` that
   override your global config.

---

## Updating

### If you cloned the repo

```bash
cd ~/.config/opencode           # Linux / macOS / WSL
# or
cd "$env:APPDATA\opencode"      # Windows (native, %APPDATA%)
# or
cd "$env:USERPROFILE\.opencode" # Windows (custom .opencode dir)
git pull
```

### Switching tiers (oc-switch)

Already on one tier but want to try the other? Use the `oc-switch` command
included in this repo. It detects your config directory, toggles the branch,
and shows the current tier — all in one step.

#### Install the command

**Linux / macOS / WSL** — Symlink the script into your PATH:

```bash
# From inside the cloned config directory
chmod +x oc-switch
sudo ln -sf "$PWD/oc-switch" /usr/local/bin/oc-switch
```

Or just create an alias in your `~/.bashrc` / `~/.zshrc`:
```bash
alias oc-switch='~/.config/opencode/oc-switch'
```

**Windows (cmd.exe)** — `oc-switch.bat` runs directly from the command prompt.
Add its folder to your PATH:

```batch
rem Run as Administrator
setx Path "%PATH%;%USERPROFILE%\.opencode"
```

After that, `oc-switch` works from any cmd.exe window.

**Windows (PowerShell)** — Use `oc-switch.ps1`. Add the script's folder to
your PATH, or create a function in your `$PROFILE`:

```powershell
# Option A — Add to PATH (run as Administrator)
[Environment]::SetEnvironmentVariable('Path', "$env:Path;$env:USERPROFILE\.opencode", 'User')

# Option B — Add a function to your PowerShell profile
Add-Content -Path $PROFILE -Value "`nfunction oc-switch { & `"$env:USERPROFILE\.opencode\oc-switch.ps1`" }"
```

#### Usage

```bash
oc-switch
```

That's it. The script:

1. Finds your config directory (checks `$OPENCODE_CONFIG`, `~/.config/opencode/`,
   `~/.opencode/`, or the Windows equivalents).
2. Checks what branch is checked out.
3. Switches to the opposite branch.
4. Prints the new tier so you can confirm.

Example output:

```
🔄  Switching from main → free-tier ...
Switched to branch 'free-tier'

✅  Now on free-tier — Free tier

    Run `opencode debug config` to verify, then restart OpenCode.
```

> **Need to see which tier is active without switching?** Just run `oc-switch`
> — it shows the current branch before toggling. If you change your mind, run
> it again to switch back.

### If you symlinked

Just `git pull` in the original repository location — the symlink picks up the
changes automatically.

### If you copied files manually

Re-run the copy step from the installation instructions.

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|-------------|-----|
| `opencode debug config` shows no agents | Config not at a recognised path | Move files to `~/.config/opencode/` (or set `OPENCODE_CONFIG`) |
| JSON parse errors | Invalid `opencode.json` | Validate with `npx jsonlint opencode.json` or an editor with JSON schema |
| Permission rules not applied | Project-level config overriding global | Check for `opencode.json` in the project root |
| Agents not showing up | Wrong subdirectory name | Use plural names: `agents/`, `skills/`, `commands/` |
| "Model not found" | Provider misconfigured | Check your `provider` block and API keys |

See the full [OpenCode docs](https://opencode.ai/docs/) for more help, or
join the [Discord community](https://opencode.ai/discord).
