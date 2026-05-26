#!/usr/bin/env bash
set -euo pipefail

USER="eventpipe"
LOG="/var/log/eventpipe/events.log"

echo "[1/6] Installing SSH server"
command -v sshd >/dev/null || apt-get update && apt-get install -y openssh-server

echo "[2/6] Creating service user"
id "$USER" &>/dev/null || useradd -m -s /usr/sbin/nologin "$USER"

echo "[3/6] Preparing log directory"
mkdir -p /var/log/eventpipe
touch "$LOG"
chown -R $USER:$USER /var/log/eventpipe
chmod 750 /var/log/eventpipe

echo "[4/6] Configuring SSH directory"
mkdir -p /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER/.ssh

echo "[5/6] Ensuring SSH service"
systemctl enable ssh || systemctl enable sshd
systemctl restart ssh || systemctl restart sshd

echo "[6/6] DONE"
echo "Add keys to /home/$USER/.ssh/authorized_keys"