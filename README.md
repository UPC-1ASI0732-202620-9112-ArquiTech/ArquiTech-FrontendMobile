# ArquiTech Mobile

Aplicación Flutter de gestión de obras para Supervisor y Contractor. Continúa la Parte 1 sin reemplazar su arquitectura, router, sesión ni cliente HTTP.

## Requisitos y ejecución

Validado con Flutter 3.47.6 / Dart 3.13.5. El proyecto requiere Dart `^3.13.5`.

```bash
flutter pub get
flutter run
```

La base URL de producción vive únicamente en `lib/core/config/app_config.dart`:

`https://arquitech-backend-production-cfc2.up.railway.app/api/v1`

Para ejecutar en Chrome contra producción, usa un puerto fijo permitido por CORS:

```bash
flutter run -d chrome --web-hostname localhost --web-port 4200
```

Abre la aplicación en `http://localhost:4200`. Flutter puede elegir un puerto aleatorio al ejecutar solo `flutter run -d chrome`; Railway rechaza esos orígenes y Chrome muestra un error de conexión. Si Angular ocupa el puerto 4200, detén ese servidor o configura otro origen exacto en `CORS_ALLOWED_ORIGINS` del Backend. Reinicia Flutter después de cambiar sus parámetros.
Para el Backend local desde Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Android permite tráfico HTTP solo a `10.0.2.2`; el resto requiere HTTPS. La aplicación declara permiso INTERNET también para builds release. Las cuentas se administran mediante el Backend; no hay credenciales incluidas en la app.

### EC08 · Guardado local de movimientos

En la rama `experiment/ab-evaluation`, el supervisor puede abrir **Movimientos sin conexión** desde Materiales. La lista de materiales del proyecto se conserva localmente cuando el inventario se carga con conexión, de modo que los borradores se pueden crear por nombre y unidad incluso sin red. El catálogo de selección está aislado por usuario y proyecto; los borradores mantienen su almacenamiento persistente por proyecto.

La sincronización **solo se habilita cuando el servidor anuncia** `idempotentOfflineMovements: true` a través de `GET /api/v1/materials/offline-sync-capabilities`. Los servidores anteriores no admiten envíos de EC08. El botón «Comprobar conexión» y una comprobación periódica detectan la compatibilidad al recuperar internet.

Cada borrador conserva su `clientRequestId` hasta obtener confirmación del endpoint `POST /api/v1/materials/{id}/offline-movements`. Si se pierde una respuesta, el borrador puede reenviarse sin aplicar el movimiento dos veces: el Backend devuelve el movimiento ya registrado. Un conflicto de contenido requiere revisión manual, y los borradores pueden descartarse localmente con confirmación. Las colas existentes conservan sus registros. El **PR del Backend** que implementa este contrato debe validarse y desplegarse antes de activar envíos contra Railway.

Para validar el protocolo de extremo a extremo, se recomienda un Backend y una base de datos aislados, usando datos de pruebas y verificando historial, saldos y reintentos antes de desplegarlo en Railway.

La pantalla y su acceso desde Materiales respetan el idioma ES/EN y las restricciones del rol supervisor.

## Funcionalidad

- Login JWT, restauración de sesión, expiración por 401, manejo de 403 y logout.
- Proyectos: lectura para ambos roles; creación y eliminación confirmada para Supervisor. El borrado elimina los registros de la obra.
- Materiales: inventario, CRUD, entradas, usos e historial.
- Personal: trabajadores con búsqueda y filtros, tareas, asignación, vencimientos y finalización.
- Asistencia diaria: presente, ausente, tardanza o justificado; fecha, horas opcionales, observaciones, historial y CRUD para Supervisor. Contractor consulta.
- Incidentes: severidad, estados, CRUD y resolución.
- Maquinaria: CRUD, estados y validación de series en mayúsculas.
- Reportes semanales equivalentes al Web; Supervisor genera PDF local con branding ARQUITECH y fuentes incluidas.
- Campana de alertas locales por stock bajo e incidentes críticos; cada alerta abre su módulo.
- Perfil local separado por usuario: nombre, teléfono y empresa. Email y rol de solo lectura.
- Preferencias persistentes ES/EN, texto normal/grande/extra grande, alto contraste y reducción de movimiento.

Supervisor administra los registros de sus obras. Contractor accede a lectura, reportes y preferencias/perfil local; no ve controles de escritura ni generación de PDF. La autorización efectiva siempre corresponde al Backend.

## Navegación

Projects es el nivel superior. Dentro de una obra hay cinco destinos: Materiales, Personal, Incidentes, Maquinaria y Más. Personal abre Trabajadores y desde su menú se accede a Tareas y Asistencia. Más contiene Reportes, Perfil, Configuración, Alertas, Volver a Proyectos y Cerrar sesión.

## Operaciones locales y límites del Backend

Perfil y preferencias se guardan en SharedPreferences; el JWT se guarda exclusivamente en Secure Storage. El Backend no publica actualización HTTP de perfil, ni endpoints de reportes, PDF o notificaciones. Reportes y alertas se calculan usando los recursos existentes. La ampliación actual incluye asistencia y eliminación de proyectos mediante endpoints reales. No hay recuperación remota de contraseña ni actualización de proyectos.

## Calidad

```bash
dart format .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Los tests originales se conservan. La suite añadida verifica contratos HTTP, reglas, agregación concurrente, PDF, almacenamiento local, permisos, formularios y navegación real del router con ambos roles y texto aumentado.

## Documentación

- [Handoff Parte 1](docs/mobile-part1-handoff.md)
- [Arquitectura final](docs/mobile-final-architecture.md)
- [Matriz API](docs/mobile-api-matrix.md)
- [Pruebas y QA](docs/mobile-testing.md)

Fuentes consultadas con prioridad Backend > Web > Report:

- [Backend](https://github.com/UPC-1ASI0732-202620-9112-ArquiTech/Arquitech-Backend)
- [Frontend Web](https://github.com/UPC-1ASI0732-202620-9112-ArquiTech/ArquiTech-FrontendWeb)
- [Report](https://github.com/UPC-1ASI0732-202620-9112-ArquiTech/ArquiTech-Report)

Las fuentes Noto Sans incluidas para PDF están bajo SIL Open Font License; ver `assets/fonts/LICENSE.txt`.
