$procList = @("DSOne", "DSOneWD")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if ($process) {
            Write-Host "Failed to stop DSOne Agent process => $process"
        } else {
            Write-Host "Stopped DSOne Agent process => $process"
        }
    }
}
Start-Sleep -Seconds 2

$user_list = Get-Item C:\Users\* | Select-Object -ExpandProperty Name
foreach ($username in $user_list) {
    if ($username -notlike "*Public*") {
        $targets = @(
            "C:\Users\$username\downloads\DSOne*.exe"
        )
        foreach ($target in $targets) {
            if (Test-Path -Path $target) {
                Remove-Item $target -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $target) {
                    Write-Host "Failed to remove DSOne Agent installer => $target"
                } else {
                    Write-Host "Removed DSOne Agent installer => $target"
                }
            }
        }
    }
}

$paths = @(
    "C:\Program Files (x86)\Driver Support One"
)
foreach ($path in $paths) {
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
        if (Test-Path -Path $path) {
            Write-Host "Failed to remove DSOne Agent system path => $path"
        } else {
            Write-Host "Removed DSOne Agent system path => $path"
        }
    }
}

$tasks = Get-ScheduledTask -TaskName *DSOne* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TaskName
foreach ($task in $tasks) {
    Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
}

$taskPaths = @(
    "C:\windows\system32\tasks\DSOne Agent",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\DSOne Agent"
)
foreach ($taskPath in $taskPaths) {
    if (Test-Path -Path $taskPath) {
        Remove-Item $taskPath -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $taskPath) {
            Write-Host "Failed to remove DSOne Agent task => $taskPath"
        } else {
            Write-Host "Removed DSOne Agent task => $taskPath"
        }
    }
}
