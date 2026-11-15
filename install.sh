#!/usr/bin/env bash
# Installs tempmon to ~/.local/bin (no sudo needed).
#   ./install.sh               install or update
#   ./install.sh --uninstall   remove the program (keeps config and logs)
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/SerjaoSanchez/tempmon/main"
DEST="$HOME/.local/bin/tempmon"

if [[ "${1:-}" == "--uninstall" ]]; then
    rm -f "$DEST"
    echo "tempmon removed. Config kept in ~/.config/tempmon and logs in ~/tempmon-logs."
    exit 0
fi

if ! command -v python3 >/dev/null; then
    echo "Error: python3 not found. Install it with: sudo apt install python3" >&2
    exit 1
fi
if ! python3 -c 'import sys; sys.exit(sys.version_info < (3, 8))'; then
    echo "Error: tempmon requires Python 3.8 or newer." >&2
    exit 1
fi

mkdir -p "$(dirname "$DEST")"
SRC=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then  # running from a file, not through a pipe
    SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tempmon"
fi
if [[ -n "$SRC" && -f "$SRC" ]]; then
    install -m 755 "$SRC" "$DEST"                       # running from a cloned repository
else
    curl -fsSL "$REPO_RAW/tempmon" -o "$DEST"           # running through curl | bash
    chmod 755 "$DEST"
fi
echo "tempmon installed to $DEST"

if ! python3 -c 'import tomllib' 2>/dev/null && ! python3 -c 'import tomli' 2>/dev/null; then
    echo
    echo "Note: your Python is older than 3.11. To use the config file, install:"
    echo "    sudo apt install python3-tomli"
fi
if ! command -v nvidia-smi >/dev/null && ! ls /sys/class/hwmon/*/name 2>/dev/null | xargs cat 2>/dev/null | grep -q amdgpu; then
    echo
    echo "Note: no NVIDIA (nvidia-smi) or AMD (amdgpu) GPU found; the GPU panel will be empty."
fi
case ":$PATH:" in
    *":$HOME/.local/bin:"*) echo "Done! Run: tempmon" ;;
    *) echo
       echo "~/.local/bin is not in your PATH yet. Log out and back in,"
       echo "or run it for now as: ~/.local/bin/tempmon" ;;
esac
