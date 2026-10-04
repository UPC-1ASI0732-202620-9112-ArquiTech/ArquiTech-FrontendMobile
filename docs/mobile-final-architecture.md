# Arquitectura final de ArquiTech Mobile

## Continuidad

Implementación sobre la Parte 1, base `0b295ca`, en `feature/mobile-completion`. Se mantiene Riverpod 2, Dio, ApiClient, ApiError/ErrorMapper, go_router, Secure Storage, SharedPreferences, AppConfig, ProjectContext, Material 3, AppTheme y los ARB ES/EN.

Cada feature conserva Data / Domain / Presentation:

```text
features/<feature>/
  data/
    datasources/       # ApiClient o almacenamiento/agregación local
    models/            # parsing y serialización; un recurso por archivo
    repositories/     # implementación
  domain/
    entities/          # entidades, enums y solicitudes
    repositories/     # puertos sin Flutter/Dio
  presentation/
    controllers/       # Riverpod
    pages/             # rutas y composición de pantalla
    widgets/           # formularios o representación reutilizable
```

Workers, Tasks, Incidents y Machinery tienen entidades y solicitudes independientes, modelos de respuesta/serialización, datasources remotos y repositories tipados. Los widgets no llaman Dio. Reports reutiliza los repositories existentes: no tiene un modelo JSON remoto porque no existe recurso REST Reports. Profile contiene modelos locales de perfil y accesibilidad.

## Flujo de datos

Página → Controller Riverpod → Repository de dominio → Implementación → Datasource → ApiClient → Dio.

Las excepciones HTTP se convierten a ApiError. ErrorMapper traduce códigos conocidos, incluyendo WORKER_HAS_TASKS y DUPLICATED_SERIAL_NUMBER. Un 401 protegido expira sesión; un 403 muestra acceso denegado y conserva sesión. El login no recibe bearer token ni dispara expiración por credenciales erróneas.

Los repositories observan el id de usuario autenticado para que sus controllers se reconstruyan al cambiar de cuenta. Los controllers comprueban `mounted` tras respuestas asíncronas, evitando publicar datos en instancias destruidas. El contexto de obra también se limpia en memoria al expirar o cerrar sesión.

## Navegación y roles

Se amplía el mismo `app_router.dart` y el mismo ProjectShell. Cinco destinos de obra: Materiales / Personal / Incidentes / Maquinaria / Más. Tasks se anida conceptualmente dentro de Personal; Reports, Profile, Settings y Alerts corresponden a Más. Todas las rutas de obra validan sesión e id contra ProjectContext. Los ids inválidos o de otra obra redirigen a Projects.

| Operación | Supervisor | Contractor |
|---|---|---|
| Proyectos | Leer, crear | Leer |
| Materiales | CRUD, entradas y usos | Leer |
| Historial | Leer | Leer |
| Trabajadores | CRUD, asignar tareas | Leer |
| Tareas | CRUD, completar | Leer |
| Incidentes | CRUD, resolver | Leer |
| Maquinaria | CRUD | Leer |
| Reportes | Leer, generar PDF | Leer |
| Perfil | Edición local | Edición local |
| Configuración | Sí | Sí |

El cliente oculta controles; la autorización definitiva y el aislamiento por obra pertenecen al Backend. No se calcula autorización filtrando recursos ajenos en el dispositivo.

## Reglas de negocio

- Worker role permanece String. Estados ACTIVE / ON_LEAVE / INACTIVE.
- Una tarea nueva solo puede asignarse a un trabajador del proyecto que no esté INACTIVE. La edición puede conservar la asignación inactiva existente sin conceder nuevas asignaciones.
- Task status usa PENDING / IN_PROGRESS / COMPLETED. La fecha límite es LocalDate; vencida significa no completada y fecha anterior al día local actual.
- `completedAt` nunca sale en solicitudes; el Backend la administra.
- Incident usa HIGH / MEDIUM / LOW y OPEN / IN_REVIEW / RESOLVED. La UI incluye los seis tipos canónicos.
- `reportedByUserId` y `resolvedAt` son solo respuesta. Las solicitudes envían reportedAt en UTC.
- Machinery usa OPERATIONAL / MAINTENANCE / OUT_OF_SERVICE. Serie con 3–20 letras/números/guiones, normalizada a uppercase. registeredAt no puede ser futuro.
- projectId se envía en altas y se omite en las actualizaciones; nunca se permite mover recursos de obra en UI.

## Fechas y reportes

LocalDate se serializa YYYY-MM-DD. OffsetDateTime se serializa con `toUtc().toIso8601String()`; Material Entry, Material Usage e Incident usan UTC y la interfaz presenta hora local.

ReportLocalDataSource inicia en paralelo cinco lecturas: Tasks, Workers, History, Materials e Incidents. WeeklyReport replica `weekly-report.service.ts` y `date.utils.ts` del Web:

- Semana local de lunes 00:00 a domingo 23:59:59.999.
- Tareas completadas de la semana por completedAt; solo si falta, dueDate.
- Nombre del trabajador del listado Workers, con workerName de Task como fallback.
- Tareas abiertas e incidentes abiertos son totales actuales del proyecto.
- Entradas, usos e incidentes se restringen al período y se ordenan por fecha descendente.
- Stock bajo es stock < minimumStock, medido sobre el inventario actual.
- El progreso es el Project.progress provisto por el Backend; no se inventa una fórmula de progreso.
- Selector de fechas y navegación semanal nunca permiten superar la semana actual.

PDF se genera usando pdf y printing, sin llamadas REST. Incluye Project, período, progreso, tareas, entradas, usos, incidentes y stock bajo. Noto Sans regular/bold se incluyen como assets con licencia, evitando descarga al generar un documento.

## Alertas y persistencia

ProjectAlert agrega stock bajo e incidentes HIGH no resueltos. La campana deriva del estado ya cargado de Materials e Incidents, evitando solicitudes duplicadas. Cambios en inventario o incidentes actualizan su indicador. La pantalla de alertas permite refrescar ambos recursos en paralelo y navegar al módulo correspondiente.

ProfileLocalDataSource usa la abstracción PreferencesStorageService existente. Claves de perfil `arquitech.profile.<userId>`; se conservan localmente entre sesiones y no se comparten entre ids. Email y role provienen de sesión y nunca son editables. Company no existe en UserResource y se mantiene local. JWT no entra en SharedPreferences ni en PDF.

Idioma se conserva con LocaleController. AccessibilityController persiste escala 1.0 / 1.3 / 1.6, highContrast y reduceMotion. La escala se combina con la preferencia del sistema. AppTheme aplica ColorScheme de alto contraste y elimina transiciones de páginas; MediaQuery comunica disableAnimations y la barra de navegación usa duración cero. Los formularios son desplazables, las acciones usan Wrap y las listas usan pull-to-refresh.

## Refactors pequeños de Parte 1

1. Repositories asociados a la sesión y guards de publicación asíncrona: evitan estado de una cuenta anterior y callbacks en controllers destruidos.
2. ProjectContext escucha expiración/logout para limpiar también su estado en memoria.
3. Guard acepta segmentos de id y rechaza ids no numéricos antes de construir páginas.
4. Login adapta el encabezado con Wrap para texto aumentado; Projects tolera el intervalo de redirección posterior a logout.
5. Material.date admite null porque MaterialResource lo permite. Se muestra una raya cuando falta; CreateMaterialRequest sigue requiriendo fecha.
6. La política de parsing de UserRole rechaza roles desconocidos en vez de conceder supervisor por defecto.
7. Android declara INTERNET en el manifest principal para permitir red en release.
8. El historial vacío permite pull-to-refresh.

No se creó ApiClient2, otro Router, otra sesión, otro Theme ni una arquitectura alternativa.

## Contratos verificados

Backend local limpio en commit `a8bce9fccb6339404d6e2f16c7da915cc6c2b8a5`. Se leyeron AuthenticationController, UsersController, ProjectController, MaterialController, WorkerController, TaskController, IncidentController y MachineryController, junto con Create/Update/Response Resource records.

Web consultado en árbol `8330d9e7caf42ce8d7eef96bfeb65b7c22bec379`, especialmente los servicios de reportes/alertas y utilidades de fecha. Report se utilizó como referencia de navegación móvil y branding, manteniendo el Theme previo.

No se modificaron Backend, Web ni Report.


## Ampliación en main: asistencia y eliminación

Attendance conserva Feature First y las mismas tres capas, con entidad/request separados, modelos de parsing/serialización, repository, datasource ApiClient, controller Riverpod, página y formulario. Se integra en el mismo router y dentro de Personal; no se agrega otra pestaña inferior. La pantalla permite búsqueda, estados, fecha o todo el historial y pull-to-refresh. Formularios y errores tienen traducciones ES/EN y estados de envío.

Projects añade deleteProject en su repository existente y DELETE centralizado en ApiEndpoints. El diálogo exige el nombre exacto, bloquea doble envío y conserva errores del servidor. La lista se actualiza y se borra el ProjectContext de la obra eliminada tras recibir éxito. Contractor no ve el control.

Se conserva la arquitectura de Parte 1 y los tests anteriores; los documentos de handoff describen su alcance histórico, anterior a estos nuevos endpoints.
