param (
    [int]$umbral
)
Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and ($_.FreeSpace / $_.Size) * 100 -lt $umbral } |
ForEach-Object {
    [PSCustomObject]@{
        Unidad = $_.DeviceID
        "Espacio Libre" = [math]::Floor($_.FreeSpace / 1GB)
        "Tamaño Total" = [math]::Floor($_.Size / 1GB)
    }
}