#!/usr/bin/env bash
set -euo pipefail

USER="eventpipe"
LOG_DIR="/var/log/eventpipe"
LOG_FILE="$LOG_DIR/events.log"

echo "[1/5] Creating user"
id "$USER" &>/dev/null || useradd -m -s /usr/sbin/nologin "$USER"

echo "[2/5] Creating log directory"
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"
chown -R "$USER:$USER" "$LOG_DIR"
chmod 750 "$LOG_DIR"

echo "[3/5] Ensure SSH server installed"
command -v sshd >/dev/null || apt-get update && apt-get install -y openssh-server

echo "[4/5] Prepare authorized keys"
mkdir -p /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER/.ssh

echo "[5/5] Done"
echo "Add SSH keys to /home/$USER/.ssh/authorized_keys"
echo "Logs stored in $LOG_FILE"