Get-ChildItem -Path . -File | Where-Object { $_.Length -gt 1024 }