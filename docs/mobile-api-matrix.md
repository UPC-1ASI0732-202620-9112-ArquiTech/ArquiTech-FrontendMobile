# Matriz API Mobile

Prefijo común: `/api/v1`, definido por AppConfig. JSON canónico en camelCase. Todas las operaciones protegidas usan bearer JWT desde Secure Storage. Los permisos se refieren exclusivamente a proyectos accesibles por el principal.

Contrato base verificado en `a8bce9f`, ampliado ahora en main con AttendanceController y DELETE de ProjectController.

## Endpoints usados

| Method | Endpoint | Feature | Supervisor | Contractor | Request | Response |
|---|---|---|---|---|---|---|
| POST | /authentication/sign-in | Auth | Sí | Sí | email, password | 200: id, fullName, email, role, token |
| GET | /projects | Projects | Sí | Sí | Sin body | 200: ProjectResource[] |
| POST | /projects | Projects | Sí | No | name, location, startDate, endDate, budget, status=PENDING, progress, supervisorId de sesión, contractorId | 201: ProjectResource |
| GET | /users | Projects | Sí | No | Sin body; UI filtra CONTRACTOR para selector | 200: UserResource[] |
| GET | /materials/project/{projectId} | Materials / Reports / Alerts | Sí | Sí | Path projectId | 200: MaterialResource[] |
| POST | /materials | Materials | Sí | No | projectId, name, unit, quantity, minimumStock, unitPrice, provider, providerRuc, date | 201: MaterialResource |
| PUT | /materials/{id} | Materials | Sí | No | name, unit, minimumStock, unitPrice, provider, providerRuc | 200: MaterialResource |
| DELETE | /materials/{id} | Materials | Sí | No | Path id | 204 sin body |
| POST | /materials/{id}/entry | Materials | Sí | No | quantity, supplier, occurredAt UTC, note | 201: MaterialMovementResource |
| POST | /materials/{id}/use | Materials | Sí | No | quantity, occurredAt UTC, note | 201: MaterialMovementResource |
| GET | /materials/project/{projectId}/history | History / Reports | Sí | Sí | Path projectId | 200: MaterialMovementResource[] |
| GET | /workers?projectId={projectId} | Workers / Reports | Sí | Sí | Query projectId | 200: WorkerResource[] |
| POST | /workers | Workers | Sí | No | projectId, fullName, role String, specialty, hireDate, status | 201: WorkerResource |
| PUT | /workers/{id} | Workers | Sí | No | fullName, role String, specialty, hireDate, status | 200: WorkerResource |
| DELETE | /workers/{id} | Workers | Sí | No | Path id | 204; puede fallar WORKER_HAS_TASKS o WORKER_HAS_ATTENDANCE |
| GET | /tasks?projectId={projectId} | Tasks / Reports | Sí | Sí | Query projectId | 200: TaskResource[] |
| POST | /tasks | Tasks | Sí | No | projectId, workerId, title, description, status, dueDate | 201: TaskResource |
| PUT | /tasks/{id} | Tasks | Sí | No | workerId, title, description, status, dueDate | 200: TaskResource |
| DELETE | /tasks/{id} | Tasks | Sí | No | Path id | 204 |
| GET | /incidents/project/{projectId} | Incidents / Reports / Alerts | Sí | Sí | Path projectId | 200: IncidentResource[] |
| POST | /incidents | Incidents | Sí | No | projectId, type, description, severity, status, reportedAt UTC | 201: IncidentResource |
| PUT | /incidents/{id} | Incidents | Sí | No | type, description, severity, status, reportedAt UTC | 200: IncidentResource |
| DELETE | /incidents/{id} | Incidents | Sí | No | Path id | 204 |
| GET | /machinery?projectId={projectId} | Machinery | Sí | Sí | Query projectId | 200: MachineryResource[] |
| POST | /machinery | Machinery | Sí | No | projectId, name, serialNumber uppercase, status, registeredAt, description | 201: MachineryResource |
| PUT | /machinery/{id} | Machinery | Sí | No | name, serialNumber uppercase, status, registeredAt, description | 200: MachineryResource |
| DELETE | /machinery/{id} | Machinery | Sí | No | Path id | 204 |

GET /workers/{id}, GET /machinery/{id} y GET /users/{id} existen en el Backend actual, pero la UI usa los recursos completos recibidos en listados/sesión y no necesita emitir esas lecturas. No existe GET público /tasks/{id}.

## Respuestas y campos administrados por servidor

| Resource | Campos |
|---|---|
| UserResource | id, fullName, email, role, phone opcional, createdAt, profilePicture opcional |
| ProjectResource | id, name, location, startDate, endDate, budget, status, progress, supervisorId, contractorId, supervisorName, contractorName, createdAt, imageUrl opcional |
| MaterialResource | id, projectId, name, unit, quantity, stock, minimumStock, unitPrice, provider, providerRuc, date nullable en respuesta |
| MaterialMovementResource | id, materialId, projectId, materialName, unit, type, quantity, supplier opcional, registeredByUserId, registeredByName opcional, occurredAt, note opcional |
| WorkerResource | id, projectId, fullName, role String, specialty opcional, hireDate, status |
| TaskResource | id, projectId, workerId, workerName, title, description opcional, status, dueDate, createdAt, completedAt opcional |
| IncidentResource | id, projectId, reportedByUserId, type, description, severity, status, reportedAt, resolvedAt opcional |
| MachineryResource | id, projectId, name, serialNumber, status, registeredAt, description opcional |

Stock de materiales, ids, nombres derivados, createdAt, Task.completedAt, Incident.reportedByUserId y Incident.resolvedAt no se editan como autoridad cliente. Updates omiten projectId y conservan la obra. El Backend admite algunos campos opcionales y alias legacy, pero Mobile envía únicamente el formato canónico.

LocalDate: YYYY-MM-DD para hireDate, dueDate, registeredAt, material date y fechas de proyecto. OffsetDateTime: UTC ISO-8601 para occurredAt y reportedAt. Los campos de fecha/hora de respuesta se presentan en zona local.

| Enum | Valores enviados |
|---|---|
| WorkerStatus | ACTIVE, ON_LEAVE, INACTIVE |
| TaskStatus | PENDING, IN_PROGRESS, COMPLETED |
| IncidentSeverity | HIGH, MEDIUM, LOW |
| IncidentStatus | OPEN, IN_REVIEW, RESOLVED |
| MachineryStatus | OPERATIONAL, MAINTENANCE, OUT_OF_SERVICE |
| MovementType (respuesta) | ENTRY, USAGE |

Errores tienen code, message, timestamp, path. ApiError conserva status HTTP; ErrorMapper produce textos ES/EN. WORKER_HAS_TASKS informa que se deben atender las tareas antes de eliminar. DUPLICATED_SERIAL_NUMBER informa que la serie ya está registrada. 401 protegido limpia sesión/contexto y 403 conserva sesión.

## Operaciones locales

| Operación | Endpoint | Supervisor | Contractor | Datos / persistencia |
|---|---|---|---|---|
| Perfil local | Ninguno | Editar local | Editar local | fullName, phone, company por userId en SharedPreferences; email/role de sesión read-only |
| Preferences | Ninguno | Sí | Sí | ES/EN, escala, alto contraste, reducir movimiento |
| Weekly Report aggregation | Ninguno nuevo | Leer | Leer | Cinco GET existentes iniciados concurrentemente; criterio del Web |
| PDF | Ninguno | Generar | No expuesto | pdf + printing + Noto Sans local; sin upload |
| Alerts aggregation | Ninguno nuevo | Leer | Leer | Material.stock < minimumStock; Incident.severity HIGH y no RESOLVED |

No se emiten solicitudes PUT Project, GET Project individual, actualización REST de Profile, Notifications, Reports, PDF remoto o Password Recovery. UserResource carece de company; la edición remota de Profile necesita un endpoint futuro.


## Asistencia y eliminación de proyectos (4 de octubre de 2026)

Todas las rutas tienen prefijo /api/v1 y requieren JWT. Supervisor escribe únicamente en sus obras; Contractor consulta las obras donde está asignado. Backend aplica permisos y scope, independientemente de la UI.

| Método | Endpoint | Supervisor | Contractor | Request | Response |
|---|---|---|---|---|---|
| DELETE | /projects/{id} | Propietario | No (403) | Sin body | 204 |
| GET | /attendance?projectId=X&date=YYYY-MM-DD | Leer | Leer | projectId requerido; date opcional | 200: AttendanceResource[] |
| POST | /attendance | Crear | No (403) | projectId, workerId, attendanceDate, status, checkInAt opcional, checkOutAt opcional, notes opcional | 201: AttendanceResource |
| PUT | /attendance/{id} | Editar | No (403) | workerId, attendanceDate, status, checkInAt opcional, checkOutAt opcional, notes opcional | 200: AttendanceResource |
| DELETE | /attendance/{id} | Eliminar | No (403) | Sin body | 204 |

AttendanceResource: id, projectId, workerId, workerName, attendanceDate, status, checkInAt, checkOutAt, notes, registeredByUserId, createdAt, updatedAt.

- Estados: PRESENT, ABSENT, LATE, EXCUSED (presente, ausente, tardanza, justificado).
- attendanceDate es la fecha de la jornada, YYYY-MM-DD. Los instantes de entrada y salida son ISO-8601 UTC; Web y Mobile presentan la hora local y permiten turnos que cruzan medianoche.
- Un solo registro por trabajador/fecha, protegido por constraint de base de datos. Duplicados devuelven 409 DUPLICATE_ATTENDANCE.
- La salida requiere entrada y no puede precederla. ABSENT y EXCUSED no admiten horas. Notes tiene máximo 1000 caracteres.
- El trabajador debe pertenecer a la obra; la fecha no puede preceder su contratación. No se crean registros nuevos para INACTIVE, pero puede corregirse su historial existente.
- No se envían registeredByUserId, workerName, createdAt ni updatedAt: son administrados por el servidor. PUT no admite cambio de projectId.
- Eliminar un trabajador con asistencia devuelve 409 WORKER_HAS_ATTENDANCE; puede marcarse INACTIVE para preservar su historial.
- La eliminación del proyecto elimina asistencia, tareas, trabajadores, movimientos/materiales, maquinaria e incidentes de esa obra; conserva usuarios y otras obras. Todo ocurre en una transacción y se revierte completamente si falla un paso.
- Ambas interfaces requieren escribir el nombre exacto de la obra para confirmar su borrado. El contexto local de esa obra se limpia tras el éxito.
- Las escrituras bloquean el proyecto antes de modificar sus recursos para evitar datos huérfanos durante una eliminación simultánea. Materiales bloquea proyecto antes de material.
