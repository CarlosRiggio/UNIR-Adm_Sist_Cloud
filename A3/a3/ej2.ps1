$fecha = Get-Date -Format "yyyyMMdd"
Get-ChildItem -Path . -Filter "*.jpg" | ForEach-Object {
    $nuevoNombreconFecha = "$fecha-$($_.Name)"
    Rename-Item -Path $_.FullName -NewName $nuevoNombreconFecha
}