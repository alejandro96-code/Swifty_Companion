#!/bin/sh
set -eu

{
  printf '%s\n' '# 42 API credentials'
  printf 'CLIENT_ID=%s\n' "${CLIENT_ID:-}"
  printf 'CLIENT_SECRET=%s\n' "${CLIENT_SECRET:-}"
} > .env

if [ ! -f .dart_tool/package_config.json ]; then
  flutter pub get
fi

exec flutter run \
  --debug \
  --device-id web-server \
  --web-hostname 0.0.0.0 \
  --web-port 8080
