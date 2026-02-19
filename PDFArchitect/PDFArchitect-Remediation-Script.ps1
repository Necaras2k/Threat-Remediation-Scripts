$process = Get-Process "PDF Architect 7" -ErrorAction SilentlyContinue
if ($process) {
    $process | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

$services = @(
    "PDF Architect 7",
    "PDF Architect 7 Update Service"
)

foreach ($svcName in $services) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.Status -ne "Stopped") {
            Stop-Service -Name $svcName -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }

        sc.exe delete "$svcName" | Out-Null

        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc) {
            "Failed to remove PDF Architect 7 service -> $svcName"
        }
    }
}

$msiGuids = @(
    "{B600CC13-8F68-4D44-8867-93490894FAE5}",
    "{BA2C2671-B379-4101-A21C-4C549671FC8D}"
)

$uninstallPaths = @(
    "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "Registry::HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($basePath in $uninstallPaths) {
    foreach ($guid in $msiGuids) {
        $fullPath = "$basePath\$guid"
        if (Test-Path -Path $fullPath) {
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
            if (Test-Path -Path $fullPath) {
                "Failed to remove PDF Architect 7 uninstall key -> $fullPath"
            }
        }
    }
}

$paths = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PDF Architect 7.lnk",
    "C:\ProgramData\PDF Architect 7",
    "C:\Program Files\PDF Architect 7",
    "C:\Program Files (x86)\PDF Architect 7"
)

foreach ($path in $paths) {
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $path) {
            "Failed to remove PDF Architect 7 -> $path"
        }
    }
}

$regKeys = @(
    "Registry::HKLM\Software\PDF Architect 7"
)

foreach ($reg in $regKeys) {
    if (Test-Path -Path $reg) {
        Remove-Item -Path $reg -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $reg) {
            "Failed to remove PDF Architect 7 registry key -> $reg"
        }
    }
}
