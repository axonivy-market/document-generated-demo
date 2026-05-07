# Managing Skills with skillshare

[skillshare](https://github.com/runkids/skillshare) is a single-binary CLI tool that installs skills from any Git host and syncs them to all your AI tools — GitHub Copilot, Claude Code, Cursor, Codex, and 60+ more — from one source of truth.

### Install skillshare

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | sh
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/runkids/skillshare/main/install.ps1 | iex
```

**Homebrew:**

```bash
brew install skillshare
```

### Install skills from this repository

```bash
skillshare install github.com/axonivy-market/skillset-for-documentation
```

This downloads all skills and agents into your local skillshare source directory:

| Platform | Skills directory |
|----------|-----------------|
| macOS / Linux | `~/.config/skillshare/` |
| Windows | `%AppData%\skillshare\` |

### Configure targets (one-time setup)

Tell skillshare which AI tools you want to sync skills to. Run this once per machine — the configuration is saved and reused for every future `sync` and `update`.

```bash
skillshare init
```

`init` auto-detects installed tools (VS Code Copilot, Claude Code, Cursor, Codex, etc.) and adds them as targets. To add or modify a target manually:

```bash
# Add a specific target
skillshare target add copilot

# List all configured targets
skillshare target list

# Switch a target to copy mode if symlinks don't work (e.g. on some Windows setups)
skillshare target <name> --mode copy
```

After this step you never need to configure targets again — `sync` and `update` will always use the saved list.

### Sync skills to your AI tools

After installation and target configuration, push the skills to all configured targets:

```bash
skillshare sync
```

To sync skills and agents together:

```bash
skillshare sync --all
```

### Update to the latest version of the skills

```bash
skillshare update --all
```

Or update only this skill set:

```bash
skillshare update skillset-for-documentation
```

### Set up on a new machine

```bash
skillshare init            # detect targets and create config (one-time)
skillshare install github.com/axonivy-market/skillset-for-documentation
skillshare sync --all      # push skills + agents to every configured target
```

### Audit skills before use

```bash
skillshare audit
```

Scans installed skills for prompt injection and data exfiltration patterns before they reach your AI agent.

### Web dashboard

```bash
skillshare ui
```

Opens a local web dashboard where you can browse, enable/disable, and manage all installed skills visually.

### Web dashboard walkthrough

The skillshare web dashboard provides an interactive UI to install skills, view installed resources, and check update status.

- **Overview:** Browse and manage all targets, enable/disable skills, and view summaries from the main dashboard.

	![Skillshare dashboard overview](images/skillshare-dashboard.png)

- **Install:** Click "Install" on a skill page to add it to your machine.

	![Install a skill via the dashboard](images/skillshare-install-skill.png)

- **Installed skills:** Open the "Resources" view to see installed resources, versions, and status.

	![Installed skills and resource details](images/skillshare-installed-resource.png)

- **Target locations:** View and manage the locations of your configured targets.

    ![Manage target locations](images/skillshare-set-up-global-target.png)

- **Update status / Auto-tracking:** The dashboard shows whether a skill is auto-tracked and if updates are available; use the "Update" button or enable auto-tracking to keep skills current.

	![Auto-tracking and update status](images/skillshare-auto-tracking-skill.png)


### Upgrade skillshare itself

```bash
skillshare upgrade
```

For full documentation see [skillshare.runkids.cc/docs](https://skillshare.runkids.cc/docs).
