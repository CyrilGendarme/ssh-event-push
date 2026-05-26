$User = "eventpipe"
$LogDir = "C:\EventPipe"
$LogFile = "$LogDir\events.log"

Write-Host "[1/5] Installing OpenSSH Server"
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Write-Host "[2/5] Starting SSH service"
Start-Service sshd
Set-Service sshd -StartupType Automatic

Write-Host "[3/5] Creating log folder"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
New-Item -ItemType File -Path $LogFile -Force | Out-Null

Write-Host "[4/5] Creating user if missing"
if (-not (Get-LocalUser -Name $User -ErrorAction SilentlyContinue)) {
    $pass = Read-Host "Set password for eventpipe user" -AsSecureString
    New-LocalUser -Name $User -Password $pass -PasswordNeverExpires
}

Write-Host "[5/5] DONE"
Write-Host "Put SSH keys in: C:\Users\$User\.ssh\authorized_keys"
Write-Host "Log file: $LogFile"