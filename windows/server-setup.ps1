$ErrorActionPreference = "Stop"

$User = "eventpipe"
$LogDir = "C:\EventPipe"
$LogFile = "$LogDir\events.log"

Write-Host "[1/5] Creating log directory"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}
New-Item -ItemType File -Path $LogFile -Force | Out-Null

Write-Host "[2/5] Ensuring OpenSSH Server is installed"
Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*" | Add-WindowsCapability -Online

Write-Host "[3/5] Starting SSH service"
Start-Service sshd
Set-Service sshd -StartupType Automatic

Write-Host "[4/5] Create local user"
if (-not (Get-LocalUser -Name $User -ErrorAction SilentlyContinue)) {
    $pass = Read-Host "Set password for eventpipe user" -AsSecureString
    New-LocalUser -Name $User -Password $pass -PasswordNeverExpires
}

Write-Host "[5/5] DONE"
Write-Host "Add SSH key to: C:\Users\$User\.ssh\authorized_keys"
Write-Host "Log file: $LogFile"