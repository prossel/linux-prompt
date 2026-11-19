# Linux Prompt — Customized Starship Prompt

A two-line Bash/Zsh prompt, with a machine-specific accent color and Git information.

For example, in a Git repository:

![Linux Prompt example on a dark background](prompt-preview-dark.png)

![Linux Prompt example on a light background](prompt-preview-light.png)

The username, hostname, and prompt symbol use the chosen accent color; the directory and branch use blue and purple.

## Local installation

```sh
sh install.sh '#00BB00'
```

## Installation from the GitHub repository

```sh
curl -fsSL https://raw.githubusercontent.com/prossel/linux-prompt/main/install.sh | sh -s -- '#00BB00'
```

## Interactive color preview

Open the [interactive color preview](https://prossel.github.io/linux-prompt/) in a browser to choose an accent color and select 24-bit truecolor, 256-color, or 16-color terminal support. Truecolor preserves the exact RGB value; ANSI modes snap to the closest standard palette color and provide the matching installation command. Actual 16-color output can vary with the terminal's configured ANSI theme.

Color examples: `#00BB00` (default green), `#38BDF8` (blue), `#34D399` (mint), `#FBBF24` (orange), `#C4B5FD` (purple), `#FB7185` (pink). The installer accepts `#RRGGBB`, a 256-color ANSI index from `0` to `255`, or one of Starship's 16 ANSI names (for example, `bright-purple`).

## Features

- Always-visible username and hostname.
- Current directory, branch, and Git status.
- Duration for commands that take more than 2 seconds.
- Red symbol if the previous command failed.
- Spacing between command blocks.
- No Nerd Font required.
- Non-destructive addition of initialization blocks to `~/.bashrc` and `~/.zshrc`.
- If `~/.bash_profile` or `~/.profile` exists but does not load `~/.bashrc`, the installer offers to add it.
- Installs Starship locally under `~/.local/bin`, without `sudo`.
- Rerun the installer with a different color to change the accent.

## Notes

The installer writes `~/.config/starship.toml`, storing the selected accent in one named Starship palette entry. If it finds a Starship configuration file not managed by this installer, it backs it up with a timestamped suffix before replacing it. Git and directory colors remain fixed to preserve their meaning, while the accent color varies by machine.

The root account and each regular user account have their own configuration; run the installation under the account you want to configure. For security, inspect the script and pin a Git revision before deploying it broadly.

The installation uses Starship's official installer, downloading it over HTTPS. `curl` is required, and Git must be installed to display Git information.
