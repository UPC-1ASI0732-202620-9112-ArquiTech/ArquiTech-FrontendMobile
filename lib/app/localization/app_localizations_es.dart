// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'ArquiTech';

  @override
  String get loading => 'Cargando…';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get optional => 'Opcional';

  @override
  String get accessDenied => 'Acceso denegado';

  @override
  String get sessionExpired => 'Tu sesión expiró. Inicia sesión nuevamente.';

  @override
  String get genericError => 'No pudimos completar la operación.';

  @override
  String get requiredField => 'Este campo es obligatorio.';

  @override
  String get invalidEmail => 'Ingresa un correo válido.';

  @override
  String get invalidNumber => 'Ingresa un número válido.';

  @override
  String get nonNegativeNumber => 'El valor no puede ser negativo.';

  @override
  String get positiveNumber => 'El valor debe ser mayor que cero.';

  @override
  String get invalidRuc =>
      'El RUC debe comenzar con 10, 15, 17 o 20 y tener 11 dígitos.';

  @override
  String get loginTitle => 'Inicia sesión';

  @override
  String get loginSubtitle => 'Gestiona tus obras desde cualquier lugar.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Ingresar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get projects => 'Proyectos';

  @override
  String get newProject => 'Nuevo proyecto';

  @override
  String get noProjects => 'Aún no tienes proyectos asignados.';

  @override
  String get projectsLoadError => 'No pudimos cargar tus proyectos.';

  @override
  String get projectCreated => 'Proyecto creado correctamente.';

  @override
  String get projectName => 'Nombre';

  @override
  String get location => 'Ubicación';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get budget => 'Presupuesto';

  @override
  String get progress => 'Progreso';

  @override
  String get status => 'Estado';

  @override
  String get contractor => 'Contratista';

  @override
  String get selectContractor => 'Selecciona un contratista';

  @override
  String get endDateBeforeStart =>
      'La fecha de fin no puede ser anterior al inicio.';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusCompleted => 'Completado';

  @override
  String get statusSuspended => 'Suspendido';

  @override
  String get materials => 'Materiales';

  @override
  String get personnel => 'Personal';

  @override
  String get incidents => 'Incidentes';

  @override
  String get machinery => 'Maquinaria';

  @override
  String get more => 'Más';

  @override
  String get reports => 'Reportes';

  @override
  String get profile => 'Perfil';

  @override
  String get history => 'Historial';

  @override
  String get newMaterial => 'Nuevo material';

  @override
  String get editMaterial => 'Editar material';

  @override
  String get noMaterials => 'No hay materiales registrados en esta obra.';

  @override
  String get materialsLoadError => 'No pudimos cargar los materiales.';

  @override
  String get materialCreated => 'Material registrado.';

  @override
  String get materialUpdated => 'Material actualizado.';

  @override
  String get materialDeleted => 'Material eliminado.';

  @override
  String get materialName => 'Material';

  @override
  String get unit => 'Unidad';

  @override
  String get quantity => 'Cantidad recibida';

  @override
  String get stock => 'Stock disponible';

  @override
  String get minimumStock => 'Stock mínimo';

  @override
  String get unitPrice => 'Precio unitario';

  @override
  String get provider => 'Proveedor';

  @override
  String get providerRuc => 'RUC del proveedor';

  @override
  String get date => 'Fecha';

  @override
  String get lowStock => 'Stock bajo';

  @override
  String get entry => 'Entrada';

  @override
  String get usage => 'Uso';

  @override
  String get registerEntry => 'Registrar entrada';

  @override
  String get registerUsage => 'Registrar uso';

  @override
  String get supplier => 'Proveedor de la entrada';

  @override
  String get occurredAt => 'Fecha y hora';

  @override
  String get note => 'Nota';

  @override
  String get movementRegistered => 'Movimiento registrado.';

  @override
  String get usageExceedsStock =>
      'La cantidad no puede superar el stock disponible.';

  @override
  String get deleteMaterialTitle => '¿Eliminar material?';

  @override
  String get deleteMaterialMessage =>
      'También se eliminará su historial de movimientos. Esta acción no se puede deshacer.';

  @override
  String get noMovements =>
      'No hay movimientos para los filtros seleccionados.';

  @override
  String get movementHistory => 'Historial de movimientos';

  @override
  String get all => 'Todos';

  @override
  String get filterByType => 'Filtrar por tipo';

  @override
  String get registeredBy => 'Registrado por';

  @override
  String get comingSoon => 'Esta sección está preparada para la Parte 2.';

  @override
  String get selectedProject => 'Obra seleccionada';

  @override
  String get changeProject => 'Cambiar proyecto';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get errorInvalidCredentials =>
      'El correo o la contraseña son incorrectos.';

  @override
  String get errorInsufficientStock =>
      'No hay stock suficiente para registrar este uso.';

  @override
  String get errorDuplicatedSerialNumber =>
      'El número de serie ya está registrado.';

  @override
  String get errorWorkerNotFound => 'No se encontró el trabajador.';

  @override
  String get errorInvalidContractor =>
      'El contratista seleccionado no es válido.';

  @override
  String get errorValidation => 'Revisa los datos ingresados.';

  @override
  String get errorNotFound => 'No se encontró el recurso solicitado.';

  @override
  String get errorForbidden => 'No tienes permiso para realizar esta acción.';

  @override
  String get errorUnauthorized => 'Debes iniciar sesión nuevamente.';

  @override
  String get errorEmailAlreadyExists => 'El correo ya está registrado.';

  @override
  String get errorProjectNotFound => 'No se encontró el proyecto.';

  @override
  String get errorMaterialNotFound => 'No se encontró el material.';

  @override
  String get errorTaskNotFound => 'No se encontró la tarea.';

  @override
  String get errorIncidentNotFound => 'No se encontró la incidencia.';

  @override
  String get errorMachineryNotFound => 'No se encontró la maquinaria.';

  @override
  String get errorWorkerHasTasks =>
      'No se puede eliminar un trabajador con tareas.';

  @override
  String get errorDataConflict =>
      'La operación entra en conflicto con datos existentes.';

  @override
  String get errorConcurrentModification =>
      'El recurso cambió. Actualiza e inténtalo de nuevo.';

  @override
  String get errorInternal => 'Ocurrió un error inesperado en el servidor.';

  @override
  String get networkError =>
      'No se pudo conectar con el servidor. Revisa tu conexión.';

  @override
  String get workers => 'Trabajadores';

  @override
  String get tasks => 'Tareas';

  @override
  String get search => 'Buscar';

  @override
  String get noRecords => 'No hay registros para estos filtros.';

  @override
  String get saved => 'Cambios guardados.';

  @override
  String get deleteRecord => '¿Eliminar este registro?';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get workerRole => 'Cargo';

  @override
  String get specialty => 'Especialidad';

  @override
  String get hireDate => 'Fecha de contratación';

  @override
  String get description => 'Descripción';

  @override
  String get title => 'Título';

  @override
  String get dueDate => 'Fecha límite';

  @override
  String get worker => 'Trabajador';

  @override
  String get overdue => 'Vencida';

  @override
  String get complete => 'Completar';

  @override
  String get resolve => 'Resolver';

  @override
  String get severity => 'Gravedad';

  @override
  String get incidentType => 'Tipo de incidente';

  @override
  String get reportedAt => 'Fecha de reporte';

  @override
  String get serialNumber => 'Número de serie';

  @override
  String get registeredAt => 'Fecha de registro';

  @override
  String get invalidSerial => 'Usa 3 a 20 letras, números o guiones.';

  @override
  String get invalidDate => 'Ingresa una fecha válida YYYY-MM-DD.';

  @override
  String get noEligibleWorkers =>
      'Registra un trabajador activo o de licencia para asignar tareas.';

  @override
  String get assignTask => 'Asignar tarea';

  @override
  String get settings => 'Configuración';

  @override
  String get phone => 'Teléfono';

  @override
  String get company => 'Empresa';

  @override
  String get localProfile => 'Estos datos se guardan solo en este dispositivo.';

  @override
  String get textSize => 'Tamaño de texto';

  @override
  String get normalText => 'Normal';

  @override
  String get largeText => 'Grande';

  @override
  String get extraLargeText => 'Muy grande';

  @override
  String get highContrast => 'Alto contraste';

  @override
  String get reduceMotion => 'Reducir movimiento';

  @override
  String get alerts => 'Alertas';

  @override
  String get criticalIncident => 'Incidente crítico';

  @override
  String get currentWeek => 'Semana actual';

  @override
  String get previousWeek => 'Semana anterior';

  @override
  String get nextWeek => 'Semana siguiente';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get completedTasks => 'Tareas completadas';

  @override
  String get openTasks => 'Tareas abiertas';

  @override
  String get openIncidents => 'Incidentes abiertos';

  @override
  String get generatePdf => 'Generar PDF';

  @override
  String get deleteWarning => 'Esta acción no se puede deshacer.';

  @override
  String get valueActive => 'Activo';

  @override
  String get valueOnLeave => 'De licencia';

  @override
  String get valueInactive => 'Inactivo';

  @override
  String get valuePending => 'Pendiente';

  @override
  String get valueInProgress => 'En progreso';

  @override
  String get valueCompleted => 'Completada';

  @override
  String get valueOpen => 'Abierto';

  @override
  String get valueInReview => 'En revisión';

  @override
  String get valueResolved => 'Resuelto';

  @override
  String get valueOperational => 'Operativa';

  @override
  String get valueMaintenance => 'En mantenimiento';

  @override
  String get valueOutOfService => 'Fuera de servicio';

  @override
  String get valueHigh => 'Alta';

  @override
  String get valueMedium => 'Media';

  @override
  String get valueLow => 'Baja';

  @override
  String get valueMaterialShortage => 'Falta de materiales';

  @override
  String get valueDeliveryDelay => 'Retraso en entrega';

  @override
  String get valueEquipmentFailure => 'Falla de equipo';

  @override
  String get valueWorkAccident => 'Accidente laboral';

  @override
  String get valueUnsafeCondition => 'Condición insegura';

  @override
  String get valueOther => 'Otro';
}
