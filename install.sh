#!/usr/bin/env bash
# Instala o tempmon em ~/.local/bin (não precisa de sudo).
#   ./install.sh               instala ou atualiza
#   ./install.sh --uninstall   remove o programa (mantém configuração e logs)
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/SerjaoSanchez/tempmon/main"
DEST="$HOME/.local/bin/tempmon"

if [[ "${1:-}" == "--uninstall" ]]; then
    rm -f "$DEST"
    echo "tempmon removido. Configuração mantida em ~/.config/tempmon e logs em ~/tempmon-logs."
    exit 0
fi

if ! command -v python3 >/dev/null; then
    echo "Erro: python3 não encontrado. Instale com: sudo apt install python3" >&2
    exit 1
fi
if ! python3 -c 'import sys; sys.exit(sys.version_info < (3, 8))'; then
    echo "Erro: o tempmon precisa de Python 3.8 ou mais novo." >&2
    exit 1
fi

mkdir -p "$(dirname "$DEST")"
SRC=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then  # rodando de um arquivo, não via pipe
    SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tempmon"
fi
if [[ -n "$SRC" && -f "$SRC" ]]; then
    install -m 755 "$SRC" "$DEST"                       # rodando de dentro do repositório clonado
else
    curl -fsSL "$REPO_RAW/tempmon" -o "$DEST"           # rodando via curl | bash
    chmod 755 "$DEST"
fi
echo "tempmon instalado em $DEST"

if ! python3 -c 'import tomllib' 2>/dev/null && ! python3 -c 'import tomli' 2>/dev/null; then
    echo
    echo "Aviso: seu Python é anterior ao 3.11. Para usar o arquivo de configuração, instale:"
    echo "    sudo apt install python3-tomli"
fi
if ! command -v nvidia-smi >/dev/null && ! ls /sys/class/hwmon/*/name 2>/dev/null | xargs cat 2>/dev/null | grep -q amdgpu; then
    echo
    echo "Aviso: nenhuma GPU NVIDIA (nvidia-smi) ou AMD (amdgpu) encontrada; o painel da GPU ficará vazio."
fi
case ":$PATH:" in
    *":$HOME/.local/bin:"*) echo "Pronto! Rode: tempmon" ;;
    *) echo
       echo "~/.local/bin ainda não está no seu PATH. Saia e entre de novo na sessão,"
       echo "ou rode por enquanto: ~/.local/bin/tempmon" ;;
esac
