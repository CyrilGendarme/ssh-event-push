#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:?server required (user@host)}"
EVENT="${2:?event required}"

JSON=$(cat <<EOF
{"event":"$EVENT","host":"$(hostname)","ts":"$(date -Iseconds)"}
EOF
)

echo "$JSON" | ssh "$SERVER" "cat >> /var/log/eventpipe/events.log"