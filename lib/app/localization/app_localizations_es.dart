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
}
