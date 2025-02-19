function Mostrar-Menu {
    Clear-Host
    Write-Host "1. Listar los servicios arrancados"
    Write-Host "2. Mostrar la fecha del sistema"
    Write-Host "3. Bloc de notas"
    Write-Host "4. Calculadora"
    Write-Host "5. Salir"
}

do {
    Mostrar-Menu
    $opcion = Read-Host "Seleccione una opción"
    switch ($opcion) {
        1 { Get-Service | Where-Object { $_.Status -eq "Running" } }
        2 { Get-Date }
        3 { Start-Process notepad }
        4 { Start-Process calc }
        5 { Write-Host "Saliendo..." }
        default { Write-Host "Opción no válida. Intente de nuevo." }
    }
    if ($opcion -ne 5) { Pause }
} while ($opcion -ne 5)
