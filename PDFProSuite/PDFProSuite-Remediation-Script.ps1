$tracker = 0

$procList = @("pdfprosuite")
foreach ($proc in $procList) {
    $process = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if ($process) {
            Write-Host "Failed to stop PDF Pro Suite process => $process"
            $tracker++
        } else {
            Write-Host "Stopped PDF Pro Suite process => $process"
            $tracker++
        }
    }
}
Start-Sleep -Seconds 2

$user_list = Get-Item C:\Users\* | Select-Object -ExpandProperty Name
foreach ($user in $user_list) {
    if ($user -notlike "*Public*") {
        $installers = @(Get-ChildItem "C:\Users\$user\Downloads" -Filter "*pdfpro*.msi" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
        foreach ($installer in $installers) {
            if (Test-Path $installer) {
                Remove-Item $installer -Force -ErrorAction SilentlyContinue
                if (Test-Path $installer) {
                    Write-Host "Failed to remove PDF Pro Suite installer => $installer"
                    $tracker++
                } else {
                    Write-Host "Removed PDF Pro Suite installer => $installer"
                    $tracker++
                }
            }
        }
        $shortcuts = @(
            "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\pdf pro suite.lnk",
            "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PDFProSuite\pdf pro suite.lnk",
            "C:\Users\$user\Desktop\pdf pro suite.lnk"
        )
        foreach ($shortcut in $shortcuts) {
            if (Test-Path $shortcut) {
                Remove-Item $shortcut -ErrorAction SilentlyContinue
                if (Test-Path $shortcut) {
                    Write-Host "Failed to remove PDF Pro Suite shortcut => $shortcut"
                    $tracker++
                } else {
                    Write-Host "Removed PDF Pro Suite shortcut => $shortcut"
                    $tracker++
                }
            }
        }
        $localPaths = @(
            "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PDFProSuite",
            "C:\Users\$user\AppData\Local\PDFProSuite",
            "C:\Users\$user\AppData\Local\BrowserHelper"
        )
        foreach ($localPath in $localPaths) {
            if (Test-Path $localPath) {
                Remove-Item $localPath -Recurse -Force -ErrorAction SilentlyContinue
                if (Test-Path $localPath) {
                    Write-Host "Failed to remove PDF Pro Suite user path => $localPath"
                    $tracker++
                } else {
                    Write-Host "Removed PDF Pro Suite user path => $localPath"
                    $tracker++
                }
            }
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\S-*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+" | ForEach-Object { $_.ToString().Trim() }
foreach ($sid in $sid_list) {
    if ($sid -notlike "*_Classes*") {
        $runKeys = @("PDFProSuite")
        $runPath = "Registry::$sid\Software\Microsoft\Windows\CurrentVersion\Run"
        foreach ($key in $runKeys) {
            if (Get-ItemProperty -Path $runPath -Name $key -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $runPath -Name $key -ErrorAction SilentlyContinue
                if (Get-ItemProperty -Path $runPath -Name $key -ErrorAction SilentlyContinue) {
                    Write-Host "Failed to remove PDF Pro Suite HKU key => $runPath.$key"
                    $tracker++
                } else {
                    Write-Host "Removed PDF Pro Suite HKU key => $runPath.$key"
                    $tracker++
                }
            }
        }
        $regPaths = @(
            "Registry::$sid\Software\PDF Pro Suite"
        )
        foreach ($path in $regPaths) {
            if (Test-Path $path) {
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
                if (Test-Path $path) {
                    Write-Host "Failed to remove PDF Pro Suite HKU key => $path"
                    $tracker++
                } else {
                    Write-Host "Removed PDF Pro Suite HKU key => $path"
                    $tracker++
                }
            }
        }
    }
}

if ($tracker -eq 0) {
    Write-Host "Nothing found to remediate"
}
