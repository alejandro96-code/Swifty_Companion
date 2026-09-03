#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/.local/share/flutter}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.22.1}"

if [[ "$(uname -s)" != "Linux" ]]; then
  printf '%s\n' 'Este instalador sin sudo esta preparado para Linux.'
  exit 1
fi

if [[ -x "$FLUTTER_DIR/bin/flutter" ]]; then
  printf 'Flutter ya esta instalado en %s\n' "$FLUTTER_DIR"
else
  command -v git >/dev/null 2>&1 || {
    printf '%s\n' 'Falta git. Instala git o pide al administrador que lo habilite.'
    exit 1
  }

  mkdir -p "$(dirname "$FLUTTER_DIR")"
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

"$FLUTTER_DIR/bin/flutter" config --no-analytics
"$FLUTTER_DIR/bin/flutter" pub get

printf '\nFlutter esta listo en %s\n' "$FLUTTER_DIR"
printf '%s\n' 'Para ejecutar en un emulador o dispositivo Android:'
printf '  %s\n' "$FLUTTER_DIR/bin/flutter run"
printf '%s\n' 'Para usar el comando flutter en esta terminal:'
printf '  export PATH="$HOME/.local/share/flutter/bin:$PATH"'
