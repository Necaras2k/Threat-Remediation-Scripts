$tracker = 0

$procList = @("browser")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
		$process = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "Failed to stop WebDiscover Browser process => $process"
			$tracker++
        } else {
            Write-Host "Stopped WebDiscover Browser process => $process"
			$tracker++
        }
    }
}
Start-Sleep -Seconds 5

$user_list = Get-Item C:\users\* | Select-Object Name -ExpandProperty Name
foreach ($username in $user_list) {
    if ($username -notlike "*Public*") {
        $paths = @(
            "C:\users\$username\AppData\Local\WebDiscoverBrowser"
        )
        foreach ($path in $paths) {
            if (Test-Path -Path $path) {
                Remove-Item $path -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $path) {
                    Write-Host "Failed to remove WebDiscover Browser user path => $path"
					$tracker++
                } else {
                    Write-Host "Removed WebDiscover Browser user path => $path"
					$tracker++
                }
            }
        }
    }
}

$paths = @(
    "C:\Program Files\WebDiscoverBrowser"
)
foreach ($path in $paths) {
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $path) {
            Write-Host "Failed to remove WebDiscover Browser system path => $path"
			$tracker++
        } else {
            Write-Host "Removed WebDiscover Browser system path => $path"
			$tracker++
        }
    }
}

$taskPaths = @(
    'C:\windows\system32\tasks\WebDiscover Browser Launch Task',
    'C:\windows\system32\tasks\WebDiscover Browser Update Task',
	'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\WebDiscover Browser Launch Task',
	'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\WebDiscover Browser Update Task'
)
foreach ($taskPath in $taskPaths) {
    if (Test-Path -Path $taskPath) {
        Remove-Item $taskPath -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskPath) {
            Write-Host "Failed to WebDiscover Browser task => $taskPath"
			$tracker++
        } else {
            Write-Host "Removed WebDiscover Browser task => $taskPath"
			$tracker++
        }
    }
}

$runKeys = @("WebDiscoverBrowser")
foreach ($runKey in $runKeys) {
    $keypath = "Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
    if ((Get-ItemProperty -Path $keypath -Name $runKey -ErrorAction SilentlyContinue)) {
        Remove-ItemProperty -Path $keypath -Name $runKey -ErrorAction SilentlyContinue
        if ((Get-ItemProperty -Path $keypath -Name $runKey -ErrorAction SilentlyContinue)) {
            Write-Host "Failed to remove WebDiscover Browser HKLM key => $keypath.$runKey"
			$tracker++
        } else {
            Write-Host "Removed WebDiscover Browser HKLM key => $keypath.$runKey"
			$tracker++
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+" | ForEach-Object { $_.ToString().Trim() }
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $regHKU = @(
            "Registry::$sid\Software\WebDiscoverBrowser"
        )
        foreach ($regPath in $regHKU) {
            if (Test-Path -Path $regPath) {
                Remove-Item -Path $regPath -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $regPath) {
                    Write-Host "Failed to remove WebDiscover Browser HKU key => $regPath"
					$tracker++
                } else {
                    Write-Host "Removed WebDiscover Browser HKU key => $regPath"
					$tracker++
                }
            }
        }
        $runKeys = @("WebDiscoverBrowser")
        foreach ($runKey in $runKeys) {
            $keypath = "Registry::$sid\Software\Microsoft\Windows\CurrentVersion\Run"
            if ((Get-ItemProperty -Path $keypath -Name $runKey -ErrorAction SilentlyContinue)) {
                Remove-ItemProperty -Path $keypath -Name $runKey -ErrorAction SilentlyContinue
                if ((Get-ItemProperty -Path $keypath -Name $runKey -ErrorAction SilentlyContinue)) {
                    Write-Host "Failed to remove WebDiscover Browser HKU key => $keypath.$runKey"
					$tracker++
                } else {
                    Write-Host "Removed WebDiscover Browser HKU key => $keypath.$runKey"
					$tracker++
                }
            }
        }
    }
}

if ($tracker -eq 0) {
	Write-Host "Nothing found to remediate"
}
