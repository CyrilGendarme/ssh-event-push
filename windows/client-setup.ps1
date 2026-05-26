param(
    [string]$Server
)

$ErrorActionPreference = "Stop"

Write-Host "[1/6] Checking OpenSSH Client"
if (-not (Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*" | Where-Object State -eq "Installed")) {
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}

Write-Host "[2/6] Ensuring SSH key exists"
$sshDir = "$env:USERPROFILE\.ssh"
$key = "$sshDir\id_ed25519"
$pub = "$key.pub"

if (-not (Test-Path $key)) {
    ssh-keygen -t ed25519 -N "" -f $key
} else {
    Write-Host "✔ Key exists"
}

Write-Host "[3/6] Starting ssh-agent"
Start-Service ssh-agent
Set-Service ssh-agent -StartupType Automatic
ssh-add $key | Out-Null

Write-Host "[4/6] Copying key to server"

try {
    type $pub | ssh $Server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
} catch {
    Write-Host "⚠ Direct copy failed, fallback to ssh-copy-id equivalent not available on Windows"
    throw
}

Write-Host "[5/6] Locking down permissions (important on Windows)"
icacls $sshDir /inheritance:r /grant "$env:USERNAME:F" | Out-Null

Write-Host "[6/6] Testing connection"
ssh $Server "echo SSH OK from $env:COMPUTERNAME"