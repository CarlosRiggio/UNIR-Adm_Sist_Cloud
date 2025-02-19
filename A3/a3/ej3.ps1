param (
    [int]$umbral
)
Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and ($_.FreeSpace / $_.Size) * 100 -lt $umbral } |
ForEach-Object {
    [PSCustomObject]@{
        Unidad = $_.DeviceID
        "Espacio Libre (GB)" = [math]::Floor($_.FreeSpace / 1GB)
        "Tamaño Total (GB)" = [math]::Floor($_.Size / 1GB)
    }
}