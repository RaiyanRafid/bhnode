#!/usr/bin/env bash
set -euo pipefail

# Installer for bhnode CLI on Ubuntu 22.04 / 24.04
# - Copies scripts/bhnode to /usr/local/bin/bhnode
# - Ensures executable permissions
# - Optionally writes /etc/bhnode.conf with update source

PROGRAM_NAME="bhnode"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SCRIPT="${SRC_DIR}/scripts/${PROGRAM_NAME}"
DEST="/usr/local/bin/${PROGRAM_NAME}"
CONF="/etc/bhnode.conf"

usage() {
  cat <<EOF
Usage: sudo ./install.sh [--raw-base <URL>] [--repo <GITHUB_URL>] [--non-interactive]

Options:
  --raw-base URL     Raw base URL to fetch updates, e.g. https://raw.githubusercontent.com/<user>/<repo>/main
  --repo URL         GitHub repo URL (used to derive raw base), e.g. https://github.com/<user>/<repo>
  --non-interactive  Do not prompt for config; only use flags if provided
EOF
}

RAW_BASE=""
REPO_URL=""
NON_INTERACTIVE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --raw-base) RAW_BASE="$2"; shift 2 ;;
    --repo) REPO_URL="$2"; shift 2 ;;
    --non-interactive) NON_INTERACTIVE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -f "${SRC_SCRIPT}" ]]; then
  echo "Source script not found: ${SRC_SCRIPT}" >&2
  exit 1
fi

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "This installer requires root privileges. Please run as root or install sudo." >&2
    exit 1
  fi
  exec sudo bash "$0" "$@"
fi

install -Dm755 "${SRC_SCRIPT}" "${DEST}"
chmod 755 "${DEST}"

# Configure update source
if [[ ${NON_INTERACTIVE} -eq 0 && -z "${RAW_BASE}" && -z "${REPO_URL}" ]]; then
  echo "Configure self-update source for bhnode (optional)."
  read -rp "GitHub repo URL (e.g. https://github.com/<user>/<repo>) [leave empty to skip]: " REPO_URL || true
  if [[ -n "${REPO_URL}" && -z "${RAW_BASE}" ]]; then
    if [[ "${REPO_URL}" =~ ^https?://github.com/([^/]+)/([^/]+)(\.git)?$ ]]; then
      RAW_BASE="https://raw.githubusercontent.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/main"
    fi
  fi
  if [[ -z "${RAW_BASE}" ]]; then
    read -rp "Raw base URL (e.g. https://raw.githubusercontent.com/<user>/<repo>/main) [leave empty to skip]: " RAW_BASE || true
  fi
fi

if [[ -n "${RAW_BASE}" || -n "${REPO_URL}" ]]; then
  echo "Writing ${CONF} with update source..."
  {
    echo "# bhnode configuration"
    [[ -n "${REPO_URL}" ]] && echo "BHNODE_REPO_URL=\"${REPO_URL}\""
    [[ -n "${RAW_BASE}" ]] && echo "BHNODE_RAW_BASE=\"${RAW_BASE}\""
  } > "${CONF}"
fi

if command -v ${PROGRAM_NAME} >/dev/null 2>&1; then
  echo "Installed ${PROGRAM_NAME} to ${DEST}"
  ${PROGRAM_NAME} --version || true
else
  echo "Installed to ${DEST}. Make sure /usr/local/bin is in your PATH."
fi
