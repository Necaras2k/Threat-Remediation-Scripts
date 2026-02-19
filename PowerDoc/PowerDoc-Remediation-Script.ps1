$tracker = 0

$procList = @("PowerDoc")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
        if ($process) {
            Write-Host "Failed to stop PowerDoc process => $process"
            $tracker++
        } else {
            Write-Host "Stopped PowerDoc process => $process"
            $tracker++
        }
    }
}
Start-Sleep -Seconds 5

$user_list = Get-Item C:\Users\* | Select-Object -ExpandProperty Name
foreach ($user in $user_list) {
    if ($user -notlike "*Public*" -and $user -notlike "*Default*") {
        $paths = @(
            "C:\Users\$user\AppData\Local\pwrDoc",
            "C:\Users\$user\Desktop\PowerDoc.lnk"
        )
        foreach ($path in $paths) {
            if (Test-Path -Path $path) {
                Remove-Item $path -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $path) {
                    Write-Host "Failed to remove PowerDoc user path => $path"
                    $tracker++
                } else {
                    Write-Host "Removed PowerDoc user path => $path"
                    $tracker++
                }
            }
        }
        # Handle wildcarded EXE separately (Get-ChildItem)
        $exeFiles = Get-ChildItem "C:\Users\$user\Downloads" -Filter "powerdoc*.exe" -ErrorAction SilentlyContinue
        foreach ($exe in $exeFiles) {
            if (Test-Path -Path $exe.FullName) {
                Remove-Item $exe.FullName -Force -ErrorAction SilentlyContinue
                if (Test-Path -Path $exe.FullName) {
                    Write-Host "Failed to remove PowerDoc installer => $($exe.FullName)"
                    $tracker++
                } else {
                    Write-Host "Removed PowerDoc installer => $($exe.FullName)"
                    $tracker++
                }
            }
        }
    }
}

$regHKLM = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Wow64\x86\PowerDoc.exe"
)
foreach ($reg in $regHKLM) {
    if (Test-Path -Path $reg) {
        Remove-Item $reg -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $reg) {
            Write-Host "Failed to remove PowerDoc HKLM key => $reg"
            $tracker++
        } else {
            Write-Host "Removed PowerDoc HKLM key => $reg"
            $tracker++
        }
    }
}

$traceBase = "Registry::HKLM\Software\Microsoft\Tracing"
$tracingKeys = Get-ChildItem -Path $traceBase -ErrorAction SilentlyContinue | Where-Object {$_.PSChildName -like "powerdoc*_RASAPI32" -or $_.PSChildName -like "powerdoc*_RASMANCS"}
foreach ($key in $tracingKeys) {
    Remove-Item -Path $key.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path -Path $key.PSPath) {
        Write-Host "Failed to remove PowerDoc HKLM key => $($key.PSPath)"
        $tracker++
    } else {
        Write-Host "Removed PowerDoc HKLM key => $($key.PSPath)"
        $tracker++
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+" | ForEach-Object {$_.ToString().Trim()}
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $regHKU = @(
            "Registry::$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PowerDoc"
        )
        foreach ($regPath in $regHKU) {
            if (Test-Path -Path $regPath) {
                Remove-Item $regPath -Recurse -Force -ErrorAction SilentlyContinue
                if (Test-Path -Path $regPath) {
                    Write-Host "Failed to remove PowerDoc HKU key => $regPath"
                    $tracker++
                } else {
                    Write-Host "Removed PowerDoc HKU key => $regPath"
                    $tracker++
                }
            }
        }
    }
}
