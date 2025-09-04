# bhnode - Ubuntu Node setup helper

A small Bash CLI for Ubuntu 22.04 and 24.04 that helps you quickly set up Node.js, PM2, update npm, install Certbot, and now self-update from a GitHub repo.

## Features

- Interactive menu or direct subcommands
- Installs Node.js (LTS) via NodeSource
- Installs PM2 globally
- Updates npm to latest globally
- Installs Certbot via snap
- Self-update from a configured GitHub repo or raw URL

## Files

- `scripts/bhnode`: the CLI script
- `install.sh`: installer that copies `bhnode` to `/usr/local/bin` and can write `/etc/bhnode.conf`

## Installation

On your Ubuntu server (22.04 or 24.04):

```bash
# Clone or upload this repo directory, then run installer
chmod +x install.sh scripts/bhnode
# Option A: interactive (will prompt to set update source)
sudo ./install.sh
# Option B: configure update source now from your GitHub repo
sudo ./install.sh --repo https://github.com/<user>/<repo>
# or explicitly provide a raw base URL
sudo ./install.sh --raw-base https://raw.githubusercontent.com/<user>/<repo>/main
```

This puts `bhnode` in `/usr/local/bin` and (optionally) writes `/etc/bhnode.conf` with:

```bash
BHNODE_REPO_URL="https://github.com/<user>/<repo>"
BHNODE_RAW_BASE="https://raw.githubusercontent.com/<user>/<repo>/main"
```

## Usage

Interactive menu:

```bash
bhnode
```

Subcommands:

```bash
bhnode help        # show help
bhnode version     # show version
bhnode nodejs      # install Node.js (LTS)
bhnode pm2         # install PM2 globally
bhnode npm-update  # update npm to latest globally
bhnode certbot     # install Certbot (via snap)
bhnode update      # self-update bhnode from configured repo/raw URL
```

## Self-update details

- The update command prefers:
  1) If `bhnode` lives in a git repo: runs `git pull` in the script directory.
  2) Otherwise: downloads `scripts/bhnode` from `BHNODE_RAW_BASE` and installs to `/usr/local/bin/bhnode`.
- Configure the source via `/etc/bhnode.conf` or environment variables:

```bash
# /etc/bhnode.conf or exported in shell
BHNODE_REPO_URL="https://github.com/<user>/<repo>"   # optional
BHNODE_RAW_BASE="https://raw.githubusercontent.com/<user>/<repo>/main"  # required if not using git pull
```

## Notes

- Requires root privileges for package installation. The CLI will use `sudo` when needed.
- Designed for Ubuntu 22.04 and 24.04; other versions may still work but are untested.
- Certbot is installed via `snap`. If `snapd` is missing, the script installs it.
