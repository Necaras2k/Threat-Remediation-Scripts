$procList = @("PCAppStore", "NW_store", "Watchdog")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if ($process) {
            Write-Host "Failed to stop PC App Store process => $process"
        } else {
            Write-Host "Stopped PC App Store process => $process"
        }
    }
}
Start-Sleep -Seconds 2

$user_list = Get-Item C:\users\* | Select-Object Name -ExpandProperty Name
foreach ($user in $user_list) {
    if ($user -notlike "*Public*") {
        $paths = @(
            "C:\Users\$user\PCAppStore",
            "C:\Users\$user\AppData\roaming\PCAppStore",
            "C:\Users\$user\Appdata\local\pc_app_store"
        )
        foreach ($path in $paths) {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -ErrorAction SilentlyContinue
                if (Test-Path $path) {
                    Write-Host "Failed to remove PC App Store user path => $path"
                } else {
                    Write-Host "Removed PC App Store user path => $path"
                }
            }
        }
        $path = "C:\Users\$user\downloads\Zoom-Setup-PCAppStore*.exe"
        if (Test-Path $path) {
            Remove-Item $path -ErrorAction SilentlyContinue
            if (Test-Path $path) {
                Write-Host "Failed to remove PC App Store installer => $path"
            } else {
                Write-Host "Removed PC App Store installer => $path"
            }
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-Object -ExpandProperty PSChildName
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $keynames = @(
            "PCApp",
            "PCAppStore",
            "PCAppStoreAutoUpdater"
        )
        foreach ($key in $keynames) {
            $keypath = "Registry::HKU\$sid\Software\Microsoft\Windows\CurrentVersion\Run"
            if (Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue
                if (Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue) {
                    Write-Host "Failed to remove PC App Store HKU key => $keypath.$key"
                } else {
                    Write-Host "Removed PC App Store HKU key => $keypath.$key"
                }
            }
        }
        $path = "Registry::HKU\$sid\Software\PCAppStore"
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -ErrorAction SilentlyContinue
            if (Test-Path $path) {
                Write-Host "Failed to remove PC App Store HKU key => $path"
            } else {
                Write-Host "Removed PC App Store HKU key => $path"
            }
        }
    }
}

$tasks = @(
    "C:\windows\system32\tasks\PCAppStoreAutoUpdater"
)
foreach ($task in $tasks) {
    if (Test-Path -Path $task) {
        Remove-Item $task -Force -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $task) {
            Write-Host "Failed to remove PC App Store task => $task"
        } else {
            Write-Host "Removed PC App Store task => $task"
        }
    }
}

$taskCacheKeys = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\PCAppStoreAutoUpdater"
)
foreach ($taskCacheKey in $taskCacheKeys) {
    if (Test-Path -Path $taskCacheKey) {
        Remove-Item $taskCacheKey -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskCacheKey) {
            Write-Host "Failed to PC App Store HKLM key => $taskCacheKey"
        } else {
            Write-Host "Removed PC App Store HKLM key => $taskCacheKey"
        }
    }
}
