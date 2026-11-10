# Evidencias de EC08 Mobile

Ensayo técnico del 10 de noviembre de 2026. Los registros de obra, materiales y cuentas son ficticios. Las marcas del registro de Android están en UTC.

| Evidencia | Contenido |
| --- | --- |
| [Capturas de Android](screenshots/) | A muestra el error de red, el formulario vacío tras reabrir y el reingreso. B muestra la cola local, la reconexión y la confirmación de 40 envíos. |
| [Registro de Android](android/android.txt) | Intentos de A, cortes y restauraciones, observaciones de la API y marcas de tiempo de B. |
| [Pruebas Flutter](flutter/) | Registro de las siete pruebas EC08 y de la suite completa de publicación. |
| [Estado del dispositivo](device/) | Borradores de B al guardar, antes y después de reiniciar y después de sincronizar. |
| [Backend aislado](backend/) | Historiales de A y B en cada fase y resumen final de movimientos y saldos. |
| [Conciliación por identificador](reconciliation/b-reconciliation.csv) | Identificador local, identificador del backend, número de coincidencias y resultado de la comparación de campos para cada borrador de B. |

El [manifiesto SHA-256](SHA256SUMS.txt) incluye el índice y los archivos de evidencia publicados. Desde `docs/evidence/ec08`, ejecuta `sha256sum -c SHA256SUMS.txt` o esta comprobación equivalente en PowerShell.

```powershell
Get-Content SHA256SUMS.txt | ForEach-Object {
    $expected, $path = $_ -split '  ', 2
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash -ne $expected) {
        throw "SHA-256 incorrecto para $path"
    }
}
```

El APK y el JAR del ensayo tienen sus SHA-256 en el [informe técnico](../../ec08-mobile-evaluation.md). Las copias de esos binarios y los datos internos del entorno aislado se resguardan por separado en `.ec08-backup/`, excluido de Git. El archivo privado está cifrado para la cuenta local de Windows y el respaldo tiene su propio manifiesto.
