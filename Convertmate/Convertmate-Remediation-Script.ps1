$tracker = 0

$procList = @("Convert Mate", "UpdateRetreiver")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if ($process) {
            Write-Host "Failed to stop ConvertMate process => $process"
            $tracker++
        } else {
            Write-Host "Stopped ConvertMate process => $process"
            $tracker++
        }
    }
}
Start-Sleep -Seconds 2

$user_list = Get-Item C:\Users\* | Select-Object -ExpandProperty Name
foreach ($username in $user_list) {
    if ($username -notlike "*Public*") {
        $targets = @(
            "C:\Users\$username\AppData\Local\ConvertMate",
            "C:\Users\$username\Downloads\convertmate*.exe"
        )
        foreach ($target in $targets) {
            if (Test-Path -Path $target) {
                Remove-Item $target -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $target) {
                    Write-Host "Failed to remove ConvertMate user path => $target"
                    $tracker++
                } else {
                    Write-Host "Removed ConvertMate user path => $target"
                    $tracker++
                }
            }
        }
    }
}

$tasks = Get-ScheduledTask -TaskName *ConvertMate* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TaskName
foreach ($task in $tasks) {
    Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
}

$taskPaths = @(
    "C:\Windows\System32\Tasks\ConvertMateTask",
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\ConvertMateTask"
)
foreach ($taskPath in $taskPaths) {
    if (Test-Path -Path $taskPath) {
        Remove-Item $taskPath -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskPath) {
            Write-Host "Failed to remove ConvertMate task => $taskPath"
            $tracker++
        } else {
            Write-Host "Removed ConvertMate task => $taskPath"
            $tracker++
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+" | ForEach-Object { $_.ToString().Trim() }
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $keyPaths = @(
            "Registry::$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\ConvertMate"
        )
        foreach ($reg in $keyPaths) {
            if (Test-Path $reg) {
                Remove-Item $reg -Recurse -Force -ErrorAction SilentlyContinue
                if (Test-Path $reg) {
                    Write-Host "Failed to remove ConvertMate HKU key => $reg"
                    $tracker++
                } else {
                    Wrrite-Host "Removed ConvertMate HKU key => $reg"
                    $tracker++
                }
            }
        }
    }
}

$regHKLM = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Compatibility32\ConvertMate",
    "Registry::HKLM\SOFTWARE\Microsoft\Tracing\ConvertMate_RASAPI32",
    "Registry::HKLM\SOFTWARE\Microsoft\Tracing\ConvertMate_RASMANCS"
)
foreach ($regPath in $regHKLM) {
    if (Test-Path $regPath) {
        Remove-Item $regPath -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $regPath) {
            Write-Host "Failed to remove ConvertMate HKLM key => $regPath"
            $tracker++
        } else {
            Write-Host "Removed ConvertMate HKLM key => $regPath"
            $tracker++
        }
    }
}

if ($tracker -eq 0) {
    Write-Host "Nothing found to remediate"
}
