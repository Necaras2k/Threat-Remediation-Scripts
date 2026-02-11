$procList = @("OneBrowser", "OBUpdateService")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if ($process) {
            Write-Host "Failed to stop OneBrowser proccess => $process"
        } else {
            Write-Host "Stopped OneBrowse process => $process"
        }
    }
}
Start-Sleep -Seconds 2

$user_list = Get-Item C:\users\* | Select-Object Name -ExpandProperty Name
foreach ($user in $user_list) {
    $installers = @(Get-ChildItem "C:\users\$user\Downloads" -Recurse -Filter "OneBrowser*.exe" | ForEach-Object { $_.FullName })
    foreach ($install in $installers) {
        if (Test-Path -Path $install) {
            Remove-Item $install -ErrorAction SilentlyContinue
            if (Test-Path -Path $install) {
                Write-Host "Failed to remove OneBrowser installer => $install"
            } else {
                Write-Host "Removed OneBrowser installer => $install"
            }
        }
    }

    $installers = @(Get-ChildItem "C:\users\$user\Downloads" -Recurse -Filter "*OneBrowser*.msi" | ForEach-Object { $_.FullName })
    foreach ($install in $installers) {
        if (Test-Path -Path $install) {
            Remove-Item $install -ErrorAction SilentlyContinue
            if (Test-Path -Path $install) {
                Write-Host "Failed to remove OneBrowser installer => $install"
            } else {
                Write-Host "Removed OneBrowser installer => $install"
            }
        }
    }

    $paths = @(
        "C:\Users\$user\AppData\Local\OneBrowser",
        "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneBrowser.lnk"
    )
    foreach ($path in $paths) {
        if (Test-Path -Path $path) {
            Remove-Item $path -Force -Recurse -ErrorAction SilentlyContinue
            if (Test-Path -Path $path) {
                Write-Host "Failed to remove OneBrowser user path => $path"
            } else {
                Write-Host "Removed OneBrowser user path => $path"
            }
        }
    }
}  

$tasks = @(
    "C:\Windows\System32\Tasks\OBUpdate"

)
foreach ($task in $tasks) {
    if (Test-Path -Path $task) {
        Remove-Item $task -Force -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $task) {
            Write-Host "Failed to remove OneBrowser task => $task"
        } else {
            Write-Host "Removed OneBrowser task => $task"
        }
    }
}

$taskCacheKeys = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\OBUpdate*"
)
foreach ($taskCacheKey in $taskCacheKeys) {
    if (Test-Path -Path $taskCacheKey) {
        Remove-Item $taskCacheKey -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskCacheKey) {
            Write-Host "Failed to remove OneBrowser HKLM key => $taskCacheKey"
        } else {
            Write-Host "Removed OneBrowser HKLM key => $taskCacheKey"
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+" | ForEach-Object { $_.ToString().Trim() }
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $registryPaths = @(
            "Registry::$sid\Software\OneBrowser",
            "Registry::$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneBrowser"
        )
        foreach ($regPath in $registryPaths) {
            if (Test-Path -Path $regPath) {
                Remove-Item $regPath -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $regPath) {
                    Write-Host "Failed to remove OneBrowser HKU key=> $regPath"
                } else {
                    Write-Host "Removed OneBrowser HKU key => $regPath"
                }
            }
        }
    }
}
