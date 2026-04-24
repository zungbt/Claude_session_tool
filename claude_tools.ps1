function Get-FolderDates {
    param(
        [string]$Path = "C:\Users\d\.claude\session-env"
    )
    Get-ChildItem -Path $Path -Directory | Select-Object Name, LastWriteTime | Sort-Object LastWriteTime -Descending | Format-Table -AutoSize
}

function Resume-ClaudeSession {
    $path = "C:\Users\d\.claude\session-env"
    $folders = Get-ChildItem -Path $path -Directory | Sort-Object LastWriteTime -Descending
    
    if ($folders.Count -eq 0) {
        Write-Host "No sessions found in $path" -ForegroundColor Red
        return
    }

    $selectedIndex = 0
    
    # Save initial position and ensure space
    $startPos = $Host.UI.RawUI.CursorPosition
    $menuHeight = $folders.Count + 2
    if ($startPos.Y + $menuHeight -ge $Host.UI.RawUI.WindowSize.Height) {
        Clear-Host
        $startPos = @{X=0;Y=0}
    }

    :SelectionLoop while ($true) {
        $Host.UI.RawUI.CursorPosition = $startPos
        Write-Host "--- Select Session (Arrows to move, Enter to pick, Esc to cancel) ---" -ForegroundColor Cyan
        
        for ($i = 0; $i -lt $folders.Count; $i++) {
            $line = " {0} ({1}) " -f $folders[$i].Name, $folders[$i].LastWriteTime
            if ($i -eq $selectedIndex) {
                Write-Host ("> $line") -ForegroundColor Green -BackgroundColor DarkGray
            } else {
                Write-Host ("  $line") -ForegroundColor White
            }
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.VirtualKeyCode) {
            38 { # Up Arrow
                $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $folders.Count - 1 }
            }
            40 { # Down Arrow
                $selectedIndex = if ($selectedIndex -lt $folders.Count - 1) { $selectedIndex + 1 } else { 0 }
            }
            13 { # Enter
                break SelectionLoop
            }
            27 { # Escape
                Write-Host "`nCancelled." -ForegroundColor Red
                return
            }
        }
    }

    $selected = $folders[$selectedIndex].Name
    Write-Host "`nResuming session: $selected..." -ForegroundColor Green
    claude --resume $selected
}

# Aliases
if (-not (Get-Alias lsf -ErrorAction SilentlyContinue)) { New-Alias lsf Get-FolderDates }
if (-not (Get-Alias cr -ErrorAction SilentlyContinue)) { New-Alias cr Resume-ClaudeSession }

