# ssh-event-push

Minimal SSH-based event pipeline.

This repository contains helper scripts to:
1. Prepare a server to receive event lines.
2. Prepare a client with SSH keys.
3. Send JSON events over SSH to the server log.

## What The Scripts Do

### Linux scripts

- `linux/server-setup.sh`
	- Installs OpenSSH server.
	- Creates a dedicated user: `eventpipe`.
	- Creates and secures `/var/log/eventpipe/events.log`.
	- Creates `/home/eventpipe/.ssh/authorized_keys` for key-based auth.
	- Enables and restarts SSH service.

- `linux/client-setup.sh <user@server>`
	- Ensures SSH client tools are installed.
	- Generates `~/.ssh/id_ed25519` if missing.
	- Starts `ssh-agent` and adds the key.
	- Copies the public key to the server (`ssh-copy-id`, with fallback).
	- Tests SSH connectivity.

- `linux/client-send.sh <user@server> <event>`
	- Builds a JSON payload:
		- `event`: your message
		- `host`: sender hostname
		- `ts`: ISO timestamp
	- Appends it remotely to `/var/log/eventpipe/events.log` via SSH.

### Windows scripts

- `windows/server-setup.ps1`
	- Installs OpenSSH Server capability.
	- Starts and enables `sshd`.
	- Creates local user `eventpipe` (asks for password if missing).
	- Creates log file at `C:\EventPipe\events.log`.

- `windows/client-setup.ps1 -Server <user@server>`
	- Installs OpenSSH Client if needed.
	- Generates `%USERPROFILE%\.ssh\id_ed25519` if missing.
	- Starts `ssh-agent` and adds key.
	- Copies the public key to remote `authorized_keys`.
	- Tightens local `.ssh` permissions and tests connection.

- `windows/client-send.ps1 -Server <user@server> -Event <event>`
	- Builds JSON payload with `event`, `host`, and ISO timestamp.
	- Sends payload over SSH and appends to `/var/log/eventpipe/events.log` on target.

## Usage

## 1) Setup the server

Linux server (run as root):

```bash
chmod +x linux/server-setup.sh
sudo ./linux/server-setup.sh
```

Windows server (run PowerShell as Administrator):

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\server-setup.ps1
```

## 2) Setup the client

Linux client:

```bash
chmod +x linux/client-setup.sh
./linux/client-setup.sh eventpipe@<SERVER_IP_OR_HOSTNAME>
```

Windows client (PowerShell):

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\client-setup.ps1 -Server eventpipe@<SERVER_IP_OR_HOSTNAME>
```

## 3) Send an event

Linux client:

```bash
chmod +x linux/client-send.sh
./linux/client-send.sh eventpipe@<SERVER_IP_OR_HOSTNAME> "build_succeeded"
```

Windows client:

```powershell
.\windows\client-send.ps1 -Server eventpipe@<SERVER_IP_OR_HOSTNAME> -Event "build_succeeded"
```

## Check received events

On Linux server:

```bash
sudo tail -f /var/log/eventpipe/events.log
```

On Windows server:

```powershell
Get-Content C:\EventPipe\events.log -Wait
```

## Notes

- Run setup scripts with admin/root privileges.
- The Linux send scripts write to `/var/log/eventpipe/events.log` on the target.
- The Windows server setup currently logs to `C:\EventPipe\events.log`.
	- If your client send script targets a Windows server, align the remote path in send scripts if needed.