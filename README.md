# ArquiTech Mobile

Aplicación Flutter para la gestión de obras de ArquiTech, con acceso diferenciado para supervisores y contratantes. La implementación mantiene los servicios existentes de autenticación, navegación y comunicación con la API.

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

### Movimientos sin conexión (EC08)

En la versión de evaluación de EC08, el supervisor accede a **Movimientos sin conexión** desde Materiales. Al consultar el inventario con conectividad, la aplicación conserva un catálogo local con los nombres y las unidades de cada material. Esto permite preparar movimientos cuando no hay acceso a internet. El catálogo se organiza por usuario y proyecto, y los borradores se guardan de forma persistente en el dispositivo.

La aplicación habilita **Enviar borradores** únicamente si el servidor confirma `idempotentOfflineMovements: true` mediante `GET /api/v1/materials/offline-sync-capabilities`. El usuario puede consultar el estado con «Comprobar conexión»; la aplicación también realiza verificaciones periódicas. Si la capacidad no está disponible, los borradores permanecen guardados y no se envían.

Cada borrador mantiene su `clientRequestId` hasta recibir la confirmación de `POST /api/v1/materials/{id}/offline-movements`. El backend puede reconocer un reintento del mismo movimiento sin descontar o aumentar las existencias por duplicado. Los conflictos de contenido requieren revisión y la eliminación de borradores locales solicita confirmación. El contrato del backend está incorporado en la rama `main`, pero su publicación en Railway y la validación conjunta con Mobile deben verificarse antes de habilitar envíos sobre el inventario del servidor.

La validación de extremo a extremo debe comprobar el historial, los saldos, los reintentos y la integridad de los datos en un entorno de pruebas aislado antes de habilitar el envío en producción.

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
