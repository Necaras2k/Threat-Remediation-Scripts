$size = 0
Get-ChildItem "C:\Path\To\Directory" -Recurse -File -ErrorAction SilentlyContinue |
 ForEach-Object { $size += $_.Length }
"{0:N2} GB" -f ($size / 1GB)
