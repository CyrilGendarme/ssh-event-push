param(
    [string]$Server,
    [string]$Event
)

$json = @{
    event = $Event
    host  = $env:COMPUTERNAME
    ts    = (Get-Date).ToString("o")
} | ConvertTo-Json -Compress

$json | ssh $Server "cat >> /var/log/eventpipe/events.log"