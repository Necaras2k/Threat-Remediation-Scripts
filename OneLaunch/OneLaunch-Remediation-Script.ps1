$procList = @("onelaunch", "onelaunchtray", "chromium")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if ($process) {
            Write-Host "Failed to stop OneLaunch process => $process"
        } else {
            Write-Host "Stopped OneLaunch process => $process"
        }
    }
}
Start-Sleep -Seconds 2

$user_list = Get-Item C:\users\* | Select-Object Name -ExpandProperty Name
foreach ($user in $user_list) {
    $installers = @(Get-ChildItem C:\users\$user\Downloads -Recurse -Filter "OneLaunch*.exe" | ForEach-Object { $_.FullName })
    foreach ($install in $installers) {
        if (Test-Path -Path $install) {
            Remove-Item -Path $install -Force -ErrorAction SilentlyContinue
            if (Test-Path -Path $install) {
                Write-Host "Failed to remove OneLaunch installer => $install"
            } else {
                Write-Host "Removed OneLaunch installer => $install"
            }
        }
    }
    $shortcuts = @(
        "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\OneLaunch.lnk",
        "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\OneLaunchChromium.lnk",
        "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\OneLaunchUpdater.lnk",
        "C:\Users\$user\desktop\OneLaunch.lnk"
    )
    foreach ($shortcut in $shortcuts) {
        if (Test-Path -Path $shortcut) {
            Remove-Item $shortcut -ErrorAction SilentlyContinue
            if (Test-Path -Path $shortcut) {
                Write-Host "Failed to remove OneLaunch shortcut => $shortcut"
            } else {
                Write-Host "Removed OneLaunch shortcut => $shortcut"
            }
        }
    }
    $localPaths = @(
        "C:\Users\$user\appdata\local\OneLaunch",
        "C:\Users\$user\appdata\Roaming\Microsoft\Windows\Start Menu\Programs\OneLaunch"
    )
    foreach ($localPath in $localpaths) {
        if (Test-Path -Path $localPath) {
            Remove-Item $localPath -Force -Recurse -ErrorAction SilentlyContinue
            if (Test-Path -Path $localPath) {
                Write-Host "Failed to remove OneLaunch user path => $localPath"
            } else {
                Write-Host "Removed OneLaunch user path => $localPath"
            }
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+" | ForEach-Object { $_.ToString().Trim() }
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $uninstallKey = "Registry::$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\{4947c51a-26a9-4ed0-9a7b-c21e5ae0e71a}_is1"
        if (Test-Path $uninstallKey) {
            Remove-Item $uninstallKey -Recurse -ErrorAction SilentlyContinue
            if (Test-Path $uninstallKey) {
                Write-Host "Failed to remove OneLaunch HKU key => $uninstallKey"
            } else {
                Write-Host "Removed OneLaunch HKU key => $uninstallKey"
            }
        }
        $runKeys = @(
            "OneLaunch",
            "OneLaunchChromium",
            "OneLaunchUpdater"
        )
        foreach ($key in $runKeys) {
            $keypath = "Registry::$sid\Software\Microsoft\Windows\CurrentVersion\Run"
            if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                Remove-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue
                if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                    Write-Host "Failed to remove OneLaunch HKU key=> $keypath.$key"
                } else {
                    Write-Host "Removed OneLaunch HKU key => $keypath.$key"
                }
            }
        }

        $miscKeys = @(
            "OneLaunchHTML_.pdf",
            "OneLaunch"
        )
        foreach ($key in $miscKeys) {
            $keypath = "Registry::$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
            if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                Remove-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue
                if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                    Write-Host "Failed to remove OneLaunch HKU key => $keypath.$key"
                } else {
                    Write-Host "Removed OneLaunch HKU key => $keypath.$key"
                }
            }
        }
        foreach ($key in $miscKeys) {
            $keypath = "Registry::$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppBadgeUpdated"
            if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                Remove-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue
                if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                    Write-Host "Failed to remove OneLaunch HKU key=> $keypath.$key"
                } else {
                    Write-Host "Removed OneLaunch HKU key => $keypath.$key"
                }
            }
        }
        foreach ($key in $miscKeys) {
            $keypath = "Registry::$sid\SOFTWARE\RegisteredApplications"
            if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                Remove-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue
                if ((Get-ItemProperty -Path $keypath -Name $key -ErrorAction SilentlyContinue)) {
                    Write-Host "Failed to remove OneLaunch HKU key=> $keypath.$key"
                } else {
                    Write-Host "Removed OneLaunch HKU key=> $keypath.$key"
                }
            }
        }
        $paths = @(
            "Registry::$sid\Software\OneLaunch",
            "Registry::$sid\SOFTWARE\Classes\OneLaunchHTML"
        )
        foreach ($path in $paths) {
            if (Test-Path -Path $path) {
                Remove-Item -Path $path -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $path) {
                    Write-Host "Failed to remove OneLaunch HKU key => $path"
                } else {
                    Write-Host "Removed OneLaunch JKU key => $path"
                }
            }
        }
    }
}

$tasks = @(
    "OneLaunchLaunchTask",
    "ChromiumLaunchTask",
    "OneLaunchUpdateTask"
)
foreach ($task in $tasks) {
    $taskPath = "C:\windows\system32\tasks\$task"
    if (Test-Path $taskPath) {
        Remove-Item $taskPath -ErrorAction SilentlyContinue
        if (Test-Path $taskPath) {
            Write-Host "Failed to remove OneLaunch task => $taskPath"
        } else {
            Write-Host "Removed OneLaunch task => $taskPath"
        }
    }
}

$taskCacheKeys = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\OneLaunchLaunchTask",
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\ChromiumLaunchTask",
    "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\OneLaunchUpdateTask"
)
foreach ($taskCacheKey in $taskCacheKeys) {
    if (Test-Path -Path $taskCacheKey) {
        Remove-Item -Path $taskCacheKey -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskCacheKey) {
            Write-Host "Failed to remove OneLaunch HKLM key => $taskCacheKey"
        } else {
            Write-Host "Removed OneLaunch HKLM key => $taskCacheKey"
        }
    }
}

$traceCacheKeys = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Tracing\onelaunch_RASMANCS",
    "Registry::HKLM\SOFTWARE\Microsoft\Tracing\onelaunch_RASAPI32"
)
foreach ($taskCacheKey in $traceCacheKeys) {
    if (Test-Path -Path $taskCacheKey) {
        Remove-Item -Path $taskCacheKey -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskCacheKey) {
            Write-Host "Failed to remove OneLaunch HKLM key => $taskCacheKey"
        } else {
            Write-Host "Removed OneLaunch HKLM key => $taskCacheKey"
        }
    }
}
