$User = "eventpipe"
$LogDir = "C:\EventPipe"
$LogFile = "$LogDir\events.log"

Write-Host "[1/5] Checking OpenSSH Server"

$sshCapability = Get-WindowsCapability -Online |
    Where-Object Name -like "OpenSSH.Server*"

if ($sshCapability.State -eq "Installed") {
    Write-Host "OpenSSH Server is already installed."
}
else {
    Write-Host "Installing OpenSSH Server..."
    Add-WindowsCapability -Online -Name $sshCapability.Name
}

Write-Host "[2/5] Starting SSH service"

if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    Start-Service sshd
    Set-Service sshd -StartupType Automatic
}
else {
    Write-Warning "The 'sshd' service was not found. OpenSSH Server may not have installed correctly."
}

Write-Host "[3/5] Creating log folder"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
New-Item -ItemType File -Path $LogFile -Force | Out-Null

Write-Host "[4/5] Creating user if missing"

if (-not (Get-LocalUser -Name $User -ErrorAction SilentlyContinue)) {
    $pass = Read-Host "Set password for eventpipe user" -AsSecureString
    New-LocalUser -Name $User -Password $pass -PasswordNeverExpires
    Write-Host "User '$User' created."
}
else {
    Write-Host "User '$User' already exists."
}

Write-Host "[5/5] DONE"
Write-Host "Put SSH keys in: C:\Users\$User\.ssh\authorized_keys"
Write-Host "Log file: $LogFile"
