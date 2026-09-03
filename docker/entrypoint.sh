#!/bin/sh
set -eu

{
  printf '%s\n' '# 42 API credentials'
  printf 'CLIENT_ID=%s\n' "${CLIENT_ID:-}"
  printf 'CLIENT_SECRET=%s\n' "${CLIENT_SECRET:-}"
} > .env

flutter config --enable-web --no-analytics
flutter pub get

exec flutter run \
  --debug \
  --device-id web-server \
  --web-hostname 0.0.0.0 \
  --web-port 8080
