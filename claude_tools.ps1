function Get-FolderDates {
    param(
        [string]$Path = (Join-Path $env:USERPROFILE ".claude\session-env")
    )
    if (-not (Test-Path $Path)) {
        Write-Host "Path not found: $Path" -ForegroundColor Red
        return
    }
    Get-ChildItem -Path $Path -Directory | Select-Object Name, LastWriteTime | Sort-Object LastWriteTime -Descending | Format-Table -AutoSize
}

function Resume-ClaudeSession {
    $claudePath = Join-Path $env:USERPROFILE ".claude"
    $sessionEnvPath = Join-Path $claudePath "session-env"
    $historyPath = Join-Path $claudePath "history.jsonl"
    
    if (-not (Test-Path $sessionEnvPath)) {
        Write-Host "Claude session directory not found at $sessionEnvPath" -ForegroundColor Red
        return
    }

    $folders = Get-ChildItem -Path $sessionEnvPath -Directory
    if (-not $folders) {
        Write-Host "No sessions found in $sessionEnvPath" -ForegroundColor Red
        return
    }

    $history = @()
    if (Test-Path $historyPath) {
        $history = Get-Content $historyPath | ForEach-Object { 
            if ([string]::IsNullOrWhiteSpace($_)) { return }
            try { $_ | ConvertFrom-Json } catch { $null } 
        } | Where-Object { $_ -and $_.sessionId }
    }

    $sessions = foreach ($f in $folders) {
        $id = $f.Name
        # Try to find a matching entry in history (either by sessionId or display name)
        $match = $history | Where-Object { $_.sessionId -eq $id -or $_.display -eq $id } | Sort-Object timestamp -Descending | Select-Object -First 1
        
        [PSCustomObject]@{
            id = $id
            display = if ($match) { $match.display } else { "Unknown Session" }
            lastWrite = $f.LastWriteTime
        }
    }

    $sortedSessions = $sessions | Sort-Object lastWrite -Descending | Select-Object -First 20
    
    $selectedIndex = 0
    $running = $true
    
    while ($running) {
        Clear-Host
        Write-Host "--- Select Claude Session to Resume (Arrows to move, Enter to pick, Esc to cancel) ---" -ForegroundColor Cyan
        Write-Host ""
        
        for ($i = 0; $i -lt $sortedSessions.Count; $i++) {
            $s = $sortedSessions[$i]
            $date = $s.lastWrite.ToString("MM/dd HH:mm")
            $displayName = $s.display
            
            # Truncate display name if too long
            if ($displayName.Length -gt 60) { $displayName = $displayName.Substring(0, 57) + "..." }
            
            $line = "{0} | {1} | {2}" -f $s.id.Substring(0, 8), $date, $displayName
            if ($i -eq $selectedIndex) {
                Write-Host ("> $line  ") -ForegroundColor Green -BackgroundColor DarkGray
            } else {
                Write-Host ("  $line  ") -ForegroundColor White
            }
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.VirtualKeyCode) {
            38 { $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $sortedSessions.Count - 1 } } # Up
            40 { $selectedIndex = if ($selectedIndex -lt $sortedSessions.Count - 1) { $selectedIndex + 1 } else { 0 } } # Down
            13 { $running = $false } # Enter (CR)
            10 { $running = $false } # Enter (LF)
            27 { Write-Host "`nCancelled."; return } # Esc
        }
    }

    $selected = $sortedSessions[$selectedIndex].id
    Write-Host "`nResuming session: $selected..." -ForegroundColor Green
    claude --resume $selected
}

# Aliases
if (-not (Get-Alias lsf -ErrorAction SilentlyContinue)) { New-Alias lsf Get-FolderDates }
if (-not (Get-Alias cr -ErrorAction SilentlyContinue)) { New-Alias cr Resume-ClaudeSession }
