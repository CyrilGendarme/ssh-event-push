#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:?Usage: setup.sh user@server}"

KEY="$HOME/.ssh/id_ed25519"
PUB="$KEY.pub"

echo "[1/5] Ensuring SSH client tools exist"
command -v ssh >/dev/null || (apt-get update && apt-get install -y openssh-client)

echo "[2/5] Generating SSH key if missing"
if [[ ! -f "$KEY" ]]; then
  ssh-keygen -t ed25519 -N "" -f "$KEY"
else
  echo "✔ Key already exists"
fi

echo "[3/5] Ensuring ssh-agent running"
eval "$(ssh-agent -s)" >/dev/null
ssh-add "$KEY" >/dev/null 2>&1 || true

echo "[4/5] Installing key on server (first-time bootstrap)"
ssh-copy-id -o StrictHostKeyChecking=accept-new "$SERVER" || {
  echo "ssh-copy-id failed, trying manual fallback..."
  cat "$PUB" | ssh "$SERVER" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
}

echo "[5/5] Test connection"
ssh "$SERVER" "echo 'SSH OK from $(hostname)'"