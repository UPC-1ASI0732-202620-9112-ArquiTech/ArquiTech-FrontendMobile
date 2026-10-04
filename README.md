# ArquiTech Mobile

Aplicación Flutter de gestión de obras para Supervisor y Contractor. Continúa la Parte 1 sin reemplazar su arquitectura, router, sesión ni cliente HTTP.

## Requisitos y ejecución

Validado con Flutter 3.47.6 / Dart 3.13.5. El proyecto requiere Dart `^3.13.5`.

```bash
flutter pub get
flutter run
```

La base URL de producción vive únicamente en `lib/core/config/app_config.dart`:

`https://arquitech-backend-production.up.railway.app/api/v1`

Para el Backend local desde Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Android permite tráfico HTTP solo a `10.0.2.2`; el resto requiere HTTPS. La aplicación declara permiso INTERNET también para builds release. Las cuentas se administran mediante el Backend; no hay credenciales incluidas en la app.

## Funcionalidad

- Login JWT, restauración de sesión, expiración por 401, manejo de 403 y logout.
- Proyectos: lectura para ambos roles y creación para Supervisor.
- Materiales: inventario, CRUD, entradas, usos e historial.
- Personal: trabajadores con búsqueda y filtros, tareas, asignación, vencimientos y finalización.
- Incidentes: severidad, estados, CRUD y resolución.
- Maquinaria: CRUD, estados y validación de series en mayúsculas.
- Reportes semanales equivalentes al Web; Supervisor genera PDF local con branding ARQUITECH y fuentes incluidas.
- Campana de alertas locales por stock bajo e incidentes críticos; cada alerta abre su módulo.
- Perfil local separado por usuario: nombre, teléfono y empresa. Email y rol de solo lectura.
- Preferencias persistentes ES/EN, texto normal/grande/extra grande, alto contraste y reducción de movimiento.

Supervisor administra los registros de sus obras. Contractor accede a lectura, reportes y preferencias/perfil local; no ve controles de escritura ni generación de PDF. La autorización efectiva siempre corresponde al Backend.

## Navegación

Projects es el nivel superior. Dentro de una obra hay cinco destinos: Materiales, Personal, Incidentes, Maquinaria y Más. Personal abre Trabajadores y desde allí Tareas. Más contiene Reportes, Perfil, Configuración, Alertas, Volver a Proyectos y Cerrar sesión.

## Operaciones locales y límites del Backend

Perfil y preferencias se guardan en SharedPreferences; el JWT se guarda exclusivamente en Secure Storage. El Backend no publica actualización HTTP de perfil, ni endpoints de reportes, PDF o notificaciones. Reportes y alertas se calculan usando los recursos existentes. No hay asistencia, recuperación remota de contraseña ni actualización/eliminación de proyectos.

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
