$fecha = Get-Date -Format "yyyyMMdd"
Get-ChildItem -Path . -Filter "*.jpg" | ForEach-Object {
    $nuevoNombre = "$fecha-$($_.Name)"
    Rename-Item -Path $_.FullName -NewName $nuevoNombre
}