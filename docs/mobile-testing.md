# Tests y QA Mobile

## Entorno

Flutter 3.47.6 estable / Dart 3.13.5, Windows. Se conserva la suite original de Parte 1 y se agregan unit tests, pruebas de contratos con un HttpClientAdapter de pruebas y widget tests con repositories falsos solamente en test/.

## Comandos

```bash
dart format .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

Resultado del 4 de octubre de 2026: dart format . sin cambios pendientes; flutter pub get exitoso; flutter analyze: No issues found; flutter test: 79 pruebas aprobadas; git diff --check sin errores de whitespace. Todos los tests de Parte 1 permanecen. flutter build apk --debug también terminó correctamente y generó build/app/outputs/flutter-apk/app-debug.apk. La primera compilación instaló los SDK Android 34/35/36 y CMake faltantes; no hubo errores de código ni de integración de plugins.

## Cobertura añadida

| Área | Verificación |
|---|---|
| Workers | Parsing, todos los estados, role String, specialty nullable, LocalDate, updates sin projectId, WORKER_HAS_TASKS |
| Tasks | Parsing, todos los estados, completedAt, vencimiento con límite del día, payload canónico, ausencia de GET individual y completedAt en request |
| Incidents | Combinaciones de severity/status, resolución/criticalidad, reportedByUserId de respuesta, payload UTC sin campos administrados por servidor |
| Machinery | Parsing, estados, serie, uppercase, LocalDate, duplicate serial localizado |
| Reports | Lunes-domingo y cambio de año, límites inclusivos/exclusivos, completedAt y fallback dueDate, nombres de workers, entradas/usos/incidentes semanales, totales abiertos, stock estrictamente bajo |
| Concurrencia | Las cinco consultas del reporte se inician antes de esperar la primera respuesta |
| PDF | Documento real con cabecera %PDF y fuentes locales |
| Alerts | HIGH no resuelto, stock < mínimo y módulos de destino |
| Profile / Preferences | Persistencia por usuario, fallback ante datos locales inválidos, idioma y accesibilidad restaurados, ausencia de JWT en perfil |
| HTTP | Métodos, paths, query, body, DELETE 204, ApiError, 401 protegido vs sign-in y 403 sin expiración |
| Roles | Permisos; Contractor sin CRUD, completar/resolver ni PDF; Supervisor con CRUD y formularios |
| Widgets | Alta de Worker, completar Task, resolver Incident, bloqueo de asignación a INACTIVE, búsqueda y ES/EN |
| Router real | Todos los módulos, ids inválidos/de otra obra, cinco destinos, texto 1.6 en 390×844, logout y expiración de sesión |
| Parte 1 | Tests originales de JWT, Auth, Projects, Materials, History y guards; fecha de material nullable y UTC en Entry/Usage |

No se sustituyó el Backend por un mock de runtime. El adaptador de pruebas no accede a la red. Las pruebas del router usan la implementación real de go_router y el mismo ArquiTechApp.

## QA global y reparaciones

Se inspeccionaron los archivos de app/core/features y los contratos Backend nuevamente tras integrar. Se buscaron TODO, FIXME, localhost, credenciales hardcoded, mock API y clases duplicadas de ApiClient/Router/Session. Los tokens falsos aparecen únicamente en test/.

La navegación integrada encontró un overflow de Login con texto extra grande. Se corrigió el encabezado mediante Wrap y se conservó la prueba como regresión. Se corrigieron también el intervalo de logout en Projects, ids de obra inválidos y la limpieza del ProjectContext en memoria. Android recibió INTERNET en su manifest principal, necesario para conectividad release.

## Alcance de la validación

Las pruebas automáticas verifican comportamiento y contratos sin cuentas reales. No se efectuaron escrituras contra producción ni se afirma una ejecución manual en Android/iOS con cuentas reales. La compilación Android verifica integración de dependencias/plugins; la ejecución en dispositivo con la API desplegada requiere credenciales válidas del equipo.

## Recorrido manual con cuentas del equipo

1. Login y reabrir app para verificar restauración.
2. Supervisor: seleccionar/crear proyecto, CRUD de materiales, entrada/uso e historial.
3. Crear trabajador activo, asignar tarea, completar y comprobar reporte semanal.
4. Intentar eliminar trabajador con tareas; comprobar WORKER_HAS_TASKS.
5. Crear incidente HIGH abierto, comprobar campana, resolver y refrescar.
6. CRUD de maquinaria; intentar serie duplicada y verificar mensaje.
7. Seleccionar semanas pasadas, volver a actual y generar PDF con todos los grupos.
8. Editar perfil local, cambiar ES/EN y activar texto extra grande/contraste/reducción de movimiento; reiniciar.
9. Contractor: recorrer todos los módulos y comprobar ausencia de acciones de escritura.
10. Logout y sesión expirada: contexto/token eliminados y regreso a Login.
