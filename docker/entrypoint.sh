#!/bin/sh
# Container start: serve the CodeIgniter app on 0.0.0.0:$PORT.
set -e
# CodeIgniter builds links from app.baseURL; default it to the fleet's public URL.
if [ -z "${app_baseURL:-}" ]; then
  export app_baseURL="${FLEET_APP_URL:-http://localhost:${PORT:-8080}}/"
fi
export SERVER_NAME=":${PORT:-8080}"
exec frankenphp run --config /etc/frankenphp/Caddyfile
