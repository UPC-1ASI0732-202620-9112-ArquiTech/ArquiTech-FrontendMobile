# EC08 · Evaluación técnica Mobile

**Fecha del ensayo** · 10 de noviembre de 2026 (America/Lima)

**Rama y revisión evaluada** · `experiment/ab-evaluation`, `d0be8f8b035868f07803a1e548d469871b090867`

La última suite Flutter aprobó 100 de 100 pruebas. Las dos condiciones del ensayo técnico en Android cumplieron sus objetivos, con 40 intentos por condición. A reprodujo el fallo sin red y el reingreso manual. B conservó y sincronizó íntegramente los 40 borradores.

[Índice de evidencias y verificación SHA-256](evidence/ec08/README.md).

## Diseño y alcance

El informe experimental de ArquiTech, sección 8.2 y tarjeta EC08, requiere resolver Q11 antes del ensayo con supervisores. Prevé ocho supervisores y cinco intentos por condición, con orden A/B contrabalanceado. El plan mantiene iguales el dispositivo, los datos de entrada y el patrón de interrupción. A registra el esfuerzo de recuperación manual. B aporta los 40 registros potencialmente elegibles para M09.

M09 divide los registros de B sincronizados completos, sin duplicados y en un máximo de 300 segundos desde la reconexión por los registros generados sin conexión. La meta para una muestra de 40 es 36 registros conformes. La condición A permite medir reingreso y reproceso para F01. El ensayo técnico automatizado se documenta por separado de las sesiones con participantes.

## Implementación revisada

| Condición | Flujo evaluado | Comportamiento de la implementación |
| --- | --- | --- |
| A | Formulario habitual de entrada o uso de materiales | Envía la operación a la API al confirmar. Ante un error, conserva los campos mientras el formulario sigue abierto. Los campos viven en memoria y la operación requiere confirmación manual tras recuperar la conexión. |
| B | Pantalla de borradores de materiales, restringida a supervisores | Guarda por proyecto un identificador, material, tipo, cantidad, proveedor, fecha y estado en `SharedPreferences`. La sincronización es manual y requiere `EC08_ALLOW_SYNC=true` y un destino local permitido. Antes del POST, el borrador pasa a revisión. Se elimina de la cola cuando el envío devuelve éxito. |

En B, una respuesta incierta interrumpe el lote y deja el borrador en revisión. El reenvío requiere comprobar el historial y rearmar el borrador de forma explícita. El identificador local viaja en la nota para reconciliar filas. Este flujo depende de la revisión manual para evitar duplicados ante una respuesta perdida. En el APK experimental se accede a A mediante el formulario habitual y a B mediante el acceso a borradores.

## Entorno de prueba

- Flutter 3.47.6 y Dart 3.13.5 en Windows. Las dependencias se resolvieron con `flutter pub get --offline`.
- Emulador 37.2.12 con Android API 37, `Medium_Phone_API_37.0`, 1080 × 2400. Se inició sin cargar ni guardar snapshots y con el AVD en modo de solo lectura. `flutter doctor -v` informó licencias pendientes del SDK. La compilación e instalación del APK terminaron correctamente.
- Backend Spring Boot 3.5.0 en `127.0.0.1:18080` y MySQL 8.0.46 en `127.0.0.1:13377`, con directorio de datos nuevo y esquema `ec08_isolated`. El backend respondió HTTP 200 en `/v3/api-docs`. JAR local SHA-256 `5b1e372e609b2c28d3d46e2001ee0b76b99e76b0b4ed47f81a89f5015cf804c5`.
- Dos proyectos ficticios equivalentes con 1 000 kg iniciales, proyecto/material 1 en A y 2 en B. APK debug con `API_BASE_URL=http://10.0.2.2:18080/api/v1` y `EC08_ALLOW_SYNC=true`. Gradle registró 277,1 s. APK SHA-256 `1cc227854da6ca4e39506015bfb5173e02c64dc3ff9777d13f5aec10b4a88ba6`.
- El primer arranque de Spring dentro del sandbox falló al conectar por JDBC. El arranque fuera del sandbox mantuvo ambos puertos en loopback. ADB registró el emulador inicialmente como `offline` durante el arranque y posteriormente como `device`. Hubo un aviso de bloqueo del launcher y fallos intermitentes de volcado de la jerarquía de la interfaz durante la preparación.

## Pruebas Flutter

```powershell
flutter pub get --offline
flutter test --no-pub --reporter expanded --dart-define=API_BASE_URL=http://127.0.0.1:18080/api/v1
```

La suite original ejecutó 99 pruebas y las 99 pasaron. Tras añadir la comprobación de 40 borradores, la suite ejecutó 100 pruebas y las 100 pasaron, incluidas las siete de EC08. La segunda ejecución registró 39 segundos en el reporte de Flutter. La prueba nueva verifica los 40 identificadores y todos los campos tras recargar el almacén simulado. El caso de cinco borradores simula el cambio a revisión y la eliminación tras confirmación. Ambas comprobaciones usan preferencias simuladas.

[Salida de las siete pruebas EC08](evidence/ec08/flutter/flutter-ec08.txt) · [Suite completa de publicación, 100/100](evidence/ec08/flutter/flutter-final.txt).

## Ensayo en Android

Se utilizó la misma cuenta de supervisor, instalación, API y tipo de movimiento (`USAGE`). Se partió de un historial con una sola entrada inicial por proyecto. Las cantidades de ensayo son enteros de 1 a 40 kg para identificar cada operación. El guion deshabilitó Wi‑Fi y datos móviles con ADB y comprobó desde Android que la API dejó de responder. La verificación desde el host siguió disponible. Al restaurar ambas interfaces, se comprobó que Android volvió a obtener HTTP 200. Se ejecutó B primero y A después, con un solo operador automatizado. Los cortes siguieron la misma secuencia y duraron lo necesario para capturar cada lote.

### B · Cola persistente y sincronización manual

| Punto de observación | Resultado |
| --- | --- |
| Antes del corte | Cola vacía y una entrada de inventario inicial en la API. |
| Durante el corte | 40 borradores creados en Android en 68,0 s entre el primero y el último. La API conservó solo la entrada inicial. |
| Después de detener y relanzar el proceso sin red | 40 borradores con el mismo contenido en las preferencias de Android. SHA-256 de ambos volcados `e036a0213c45261051cbdf48b14ae2be6e37ac4cb30224a5a9b44487a84c1470`. La app volvió a Proyectos al arrancar. |
| Tras recuperar conectividad | Se volvió al proyecto y se pulsó «Sincronizar con API local de ensayo». Los 40 movimientos se observaron 17,4 s después de pulsar y 50,7 s desde el inicio de la restauración. |
| Conciliación | Una fila por identificador, con proyecto, material, tipo, cantidad, proveedor y fecha concordantes. El proveedor ausente en un uso se compara como campo vacío. Historial final de 41 filas, incluida la entrada inicial. Cola final vacía y saldo de 180 kg tras registrar 820 kg de uso. |

El recuento de B en este ensayo técnico satisface el criterio operativo de M09 en **40/40 = 100 %**. El tiempo de 50,7 s incluye la restauración, la navegación y el envío manual, y funciona como cota superior para el lote completo. El valor se limita a este lote automatizado de usos; el resultado del estudio con supervisores queda pendiente.

El registro de B incluye los volcados del dispositivo, el historial de la API y la conciliación de ambos. [Cola sin conexión](evidence/ec08/device/b-queue-offline.json) · [Cola tras reiniciar](evidence/ec08/device/b-queue-after-restart.json) · [Historial durante el corte](evidence/ec08/backend/b-backend-offline.json) · [Historial final](evidence/ec08/backend/b-backend-after.json) · [Conciliación por identificador](evidence/ec08/reconciliation/b-reconciliation.csv) · [Captura sin conexión](evidence/ec08/screenshots/b-offline-after.png) · [Confirmación de 40 envíos](evidence/ec08/screenshots/b-reconnected-after-sync.png).

### A · Formulario habitual y recuperación manual

Se hicieron 40 intentos consecutivos en el formulario habitual de uso, con una cantidad distinta por intento. En los 40 apareció el error de conexión, la cantidad siguió visible en el formulario abierto y «Confirmar» volvió a quedar habilitado. Pasaron 400,6 s entre el primer y el último resultado registrado por el guion. El historial aislado conservó solo la entrada inicial durante el corte.

Después de reiniciar y recuperar conectividad, el formulario se abrió con la cantidad vacía. El historial anterior al reingreso fue idéntico al historial inicial. Se digitó nuevamente la operación de 1 kg y se confirmó. La API mostró exactamente un uso nuevo y un saldo de 999 kg. El guion lo observó 43,8 s después de iniciar la restauración de la red, incluidos el arranque de la interfaz y la navegación.

[Primer error de conexión](evidence/ec08/screenshots/a-offline-first-attempt.png) · [Último intento](evidence/ec08/screenshots/a-offline-last-attempt.png) · [Historial durante el corte](evidence/ec08/backend/a-backend-offline.json) · [Formulario tras reabrir](evidence/ec08/screenshots/a-reopened-blank.png) · [Historial tras el reingreso](evidence/ec08/backend/a-backend-after-one-reentry.json).

El registro de Android usa marcas UTC. La consulta final al backend verifica los saldos y el número de usos en los dos proyectos. [Registro de Android](evidence/ec08/android/android.txt) · [Resumen del backend](evidence/ec08/backend/backend-final-summary.json).

## Alcance y pendientes

- **Q11.** Adjuntar la evidencia de la investigación exploratoria antes de iniciar las sesiones.
- **Ocho sesiones con supervisores.** Contrabalancear el orden A/B y registrar cinco intentos por condición y participante para estimar M09 en el estudio. Este ensayo técnico usó un emulador, un corte por condición y las dos rutas del mismo APK. El botón de borradores seguía visible desde el módulo común de materiales.
- **F01.** Medir minutos de reingreso y reparación por participante en A y B y calcular el ahorro de reproceso.
- La comprobación de B en Android cubre sincronización de usos después de una reconexión estable. La evidencia para entradas y para el estado de revisión ante una respuesta incierta procede de pruebas del almacén simulado.
