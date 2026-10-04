# ArquiTech Mobile — Handoff de la Parte 1

## Alcance entregado

Esta primera mitad establece la arquitectura definitiva de la aplicación Flutter e implementa autenticación JWT, sesión persistente, selección de obra, proyectos e inventario de materiales. Workers, Tasks, Incidents, Machinery, Reports y Profile conservan su topología Feature First y páginas de navegación preparadas, pero su funcionalidad de negocio queda expresamente fuera de esta parte.

Las fuentes se aplicaron con esta prioridad: Backend actual, Frontend Web y Project Report. Los contratos se contrastaron directamente con los controladores y `record` resources de `Arquitech-Backend/main`.

## Arquitectura

El código usa **Feature First** y, dentro de cada feature, separación **Data / Domain / Presentation**:

- `data/datasources`: llamadas remotas mediante `ApiClient`.
- `data/models`: parsing y serialización del contrato JSON.
- `data/repositories`: implementación de los puertos de dominio.
- `domain/entities`: entidades, enums y comandos/request del negocio.
- `domain/repositories`: interfaces sin dependencia de Dio o Flutter UI.
- `presentation/controllers`: estado Riverpod y coordinación de casos de uso.
- `presentation/pages` y `presentation/widgets`: interfaz Material 3.

Los widgets nunca reciben ni conocen una instancia de Dio. Dio queda confinado a `core/network` y los datasources dependen del wrapper `ApiClient`.

## Dependencias

- `flutter_riverpod`: única solución de estado e inyección.
- `dio`: transporte HTTP.
- `flutter_secure_storage`: JWT.
- `shared_preferences`: usuario serializado, proyecto seleccionado e idioma.
- `go_router`: guards, redirecciones y navegación.
- `flutter_localizations` + `intl`: ES/EN y formatos locales.

No se introdujo GetX, otro state manager, generadores de modelos ni API mock en runtime.

## Configuración global

`lib/core/config/app_config.dart` define una única fuente de la base URL.

Producción por defecto:

```text
https://arquitech-backend-production.up.railway.app/api/v1
```

Override de ejecución:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Android permite cleartext únicamente para `10.0.2.2` mediante `android/app/src/main/res/xml/network_security_config.xml`; el resto del tráfico requiere HTTPS.

Todos los paths están centralizados en `lib/core/constants/api_endpoints.dart`. No deben escribirse URLs o endpoints directamente en una feature.

## Material Design 3 y branding

Los tokens están separados en:

- `app_colors.dart`: Sinopia `#C43508`, Fulvous `#DE7F1A`, Selective Yellow `#FFB627`, Isabelline `#F8F5F1`, Jet `#2F2E2D` y Green Pigment `#2BBA51`.
- `app_typography.dart`: escala legible y jerarquías.
- `app_spacing.dart`: grilla y target táctil de 48 dp.
- `app_theme.dart`: `ColorScheme`, cards, inputs, FAB, SnackBars y bottom navigation.

La UI toma del Report la navegación inferior, cards, contraste para trabajo en campo, pull-to-refresh y acciones primarias mediante FAB. No replica la sidebar web ni usa tablas horizontales.

## Localización

Los ARB fuente son:

- `lib/app/localization/app_es.arb`
- `lib/app/localization/app_en.arb`

`l10n.yaml` genera `AppLocalizations` dentro de la misma carpeta. Toda cadena funcional de las pantallas implementadas proviene de localización, incluidas validaciones, estados, errores y navegación. `LocaleController` persiste `es` o `en` en SharedPreferences.

Después de añadir una clave ARB, ejecutar `flutter gen-l10n` o `flutter pub get` antes de analizar.

## Red, errores e interceptor

`ApiClient` encapsula `GET`, `POST`, `PUT` y `DELETE`. Convierte cualquier `DioException` en `ApiError` usando el contrato:

```json
{
  "code": "...",
  "message": "...",
  "timestamp": "...",
  "path": "..."
}
```

`ErrorMapper` traduce ES/EN todos los códigos conocidos: `INVALID_CREDENTIALS`, `INSUFFICIENT_STOCK`, `DUPLICATED_SERIAL_NUMBER`, `WORKER_NOT_FOUND`, `INVALID_CONTRACTOR`, `VALIDATION_ERROR`, `NOT_FOUND`, `FORBIDDEN`, `UNAUTHORIZED`, `EMAIL_ALREADY_EXISTS`, `PROJECT_NOT_FOUND`, `MATERIAL_NOT_FOUND`, `TASK_NOT_FOUND`, `INCIDENT_NOT_FOUND`, `MACHINERY_NOT_FOUND`, `WORKER_HAS_TASKS`, `DATA_CONFLICT`, `CONCURRENT_MODIFICATION` e `INTERNAL_ERROR`.

`AuthInterceptor`:

- lee el token desde secure storage;
- agrega `Authorization: Bearer <token>` a recursos protegidos;
- nunca agrega Authorization a `/authentication/sign-in`;
- ante `401` protegido borra token, usuario y contexto de proyecto y marca sesión expirada;
- ante `403` no altera la sesión; el error localizado vuelve a la pantalla mediante SnackBar.

No existe logging de bodies, passwords o tokens.

## Auth y sesión

Contrato implementado:

```http
POST /authentication/sign-in
```

```json
{ "email": "...", "password": "..." }
```

La respuesta se parsea como `id`, `fullName`, `email`, `role`, `token`. Solo existen `SUPERVISOR` y `CONTRACTOR`.

El JWT vive exclusivamente en `flutter_secure_storage`; la contraseña nunca se persiste. Los datos no sensibles del usuario se serializan en SharedPreferences para poder restaurar sesión. `JwtUtils` decodifica `exp` y considera inválido un token vencido o sin expiry legible.

`SessionController` expone `restoring`, `authenticated` y `unauthenticated`, y soporta `restore`, `start`, `logout` y `expireSession`. La pantalla splash evita mostrar rutas protegidas antes de completar el restore.

## Router y guards

Rutas principales:

- `/login`
- `/projects`
- `/projects/new` (solo Supervisor)
- `/projects/:projectId/materials`
- `/projects/:projectId/materials/history`
- `/projects/:projectId/workers`
- `/projects/:projectId/incidents`
- `/projects/:projectId/machinery`
- `/projects/:projectId/more`

`AppRouteGuard` redirige visitantes a Login, usuarios autenticados fuera de Login, Contractors fuera de creación de proyectos y cualquier ruta de obra cuyo id no coincida con `ProjectContext`.

El shell de obra tiene cinco destinos adecuados a móvil: Materiales, Personal, Incidentes, Maquinaria y Más. Personal albergará Workers/Tasks. Más albergará Reports, Profile, Settings y Logout.

## Project Context

`ProjectContextController` persiste el proyecto seleccionado completo. Esto es necesario porque el Backend no expone `GET /projects/{id}`. Nunca se inventó ese endpoint. El contexto se elimina al cambiar de proyecto, cerrar sesión o recibir un `401`.

## Projects

Endpoints:

- `GET /projects`
- `POST /projects`
- `GET /users` para seleccionar Contractors

`GET /projects` se usa para ambos roles porque el Backend actual filtra por el principal autenticado. No se filtran proyectos ajenos como sustituto de autorización.

El listado incluye cards, ubicación, presupuesto, status chip, progreso, estados loading/empty/error/retry y pull-to-refresh. Solo Supervisor ve el FAB Nuevo Proyecto.

El alta envía exactamente:

```json
{
  "name": "...",
  "location": "...",
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "budget": 0,
  "status": "PENDING",
  "progress": 0,
  "supervisorId": 1,
  "contractorId": 2
}
```

El supervisor proviene siempre de la sesión; no es seleccionable. Contractors se obtienen de `/users` y se filtran por rol.

## Materials

Endpoints implementados:

- `GET /materials/project/{projectId}`
- `POST /materials`
- `PUT /materials/{id}`
- `DELETE /materials/{id}`
- `POST /materials/{id}/entry`
- `POST /materials/{id}/use`
- `GET /materials/project/{projectId}/history`

`Material` mantiene por separado `quantity` (total recibido) y `stock` (disponible). El stock nunca se incluye en formularios o payloads de edición.

El alta valida nombre, unidad, quantity, minimumStock, unitPrice, provider, providerRuc y date. La unidad es un String editable con chips de sugerencia. RUC usa `^(10|15|17|20)[0-9]{9}$`.

La edición envía exclusivamente nombre, unidad, minimumStock, unitPrice, provider y providerRuc. La eliminación exige diálogo de confirmación.

Las entradas requieren cantidad positiva, supplier, occurredAt y note. Los usos requieren cantidad positiva, occurredAt y note. `occurredAt` siempre sale de `toUtc().toIso8601String()`, por lo que termina en `Z` para instantes UTC.

La UI bloquea uso mayor a stock, pero el Backend sigue siendo la autoridad y `INSUFFICIENT_STOCK` se traduce si existe concurrencia.

El historial muestra fecha/hora local, material, tipo, cantidad, supplier, usuario y nota; permite filtrar All/Entry/Usage.

Low stock se calcula localmente exactamente como `stock < minimumStock`; no se inventó ningún endpoint.

## Roles

`RolePermissions` es la política cliente reutilizable y testeable:

- Supervisor: lee y crea proyectos; lee, crea, edita, elimina, registra entradas/usos y consulta historial de materiales.
- Contractor: solo lee proyectos, materiales e historial.

La ocultación UI mejora la experiencia, pero no reemplaza el `403` del Backend.

## Tests

La suite cubre:

- parsing de Auth response y User;
- lectura y expiración JWT;
- contrato ApiError;
- restauración y limpieza de sesión;
- parsing Project;
- políticas Supervisor/Contractor y comportamiento de proyectos;
- parsing Material y Movement;
- low stock;
- uso mayor al stock;
- navegación sin sesión, guard de Supervisor, bloqueo de Contractor y Project Context.

Comando: `flutter test`.

## Archivos clave

- `lib/main.dart`: inicialización de SharedPreferences y ProviderScope.
- `lib/app/app.dart`: MaterialApp, tema, idioma y router.
- `lib/app/router/app_router.dart`: mapa de navegación.
- `lib/core/network/*`: Dio, ApiClient e interceptor.
- `lib/features/auth/presentation/controllers/session_controller.dart`: ciclo de sesión.
- `lib/features/projects/presentation/controllers/project_context_controller.dart`: obra activa.
- `lib/features/materials/presentation/controllers/materials_controller.dart`: inventario y movimientos.
- `lib/core/constants/api_endpoints.dart`: paths REST canónicos.

## Cómo continuar la Parte 2

1. No cambies el patrón de capas ni introduzcas otro state manager.
2. Contrasta primero cada Controller/Resource actual del Backend.
3. Añade endpoints únicamente a `ApiEndpoints`.
4. Crea entidad, model, repository interface, datasource, repository impl, controller y UI por feature.
5. Mantén `projectId` derivado del `ProjectContext` y las mismas reglas de roles.
6. Reemplaza gradualmente las páginas placeholder de Workers, Incidents y Machinery; agrega rutas internas de Tasks/Reports/Profile bajo el shell existente.
7. Coloca strings nuevos en ambos ARB.
8. Añade unit tests de parsing, reglas y guards, más widget tests de los flujos críticos.
9. Ejecuta siempre `dart format .`, `flutter analyze` y `flutter test`.

No deben añadirse `GET /projects/{id}`, `PUT /projects/{id}` ni `DELETE /projects/{id}` salvo que el Backend real los incorpore posteriormente.
