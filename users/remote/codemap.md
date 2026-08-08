# users/remote/

## Responsibility

Remote Home Manager profile for a lightweight `remote` user account. This module focuses on shell/dev tooling and minimal desktop-independent user settings.

## Design Patterns/Structure

- Home Manager-only profile: no system services or machine hardware definitions here.
- Small, composable import set (`zsh`, `starship`) with a curated package list.
- Uses flake inputs for a few custom tools, but otherwise stays minimal.

## Data & Control Flow

- Sets the username/home directory, then adds command-line tools and shell conveniences.
- Enables direnv and Git/GH settings for a terminal-first workflow.
- Delegates shell prompt and shell initialization to imported HM modules.

## Integration Points

- Home Manager user environment only; no NixOS system-level services.
- Tooling integration: direnv, command-not-found, Git defaults, GH CLI, tmux, Neovim, and language/dev utilities.
- External flake packages: `opencode` and `codex` from `llm-agents.nix`.
- `configure-nix-cache.sh` adds the Numtide cache and signing key to the system Nix daemon configuration before the first Home Manager build.
