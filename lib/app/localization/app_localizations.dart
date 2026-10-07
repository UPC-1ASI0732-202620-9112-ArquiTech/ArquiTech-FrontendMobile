import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'ArquiTech'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @optional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get optional;

  /// No description provided for @accessDenied.
  ///
  /// In es, this message translates to:
  /// **'Acceso denegado'**
  String get accessDenied;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión expiró. Inicia sesión nuevamente.'**
  String get sessionExpired;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la operación.'**
  String get genericError;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido.'**
  String get invalidEmail;

  /// No description provided for @invalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número válido.'**
  String get invalidNumber;

  /// No description provided for @nonNegativeNumber.
  ///
  /// In es, this message translates to:
  /// **'El valor no puede ser negativo.'**
  String get nonNegativeNumber;

  /// No description provided for @positiveNumber.
  ///
  /// In es, this message translates to:
  /// **'El valor debe ser mayor que cero.'**
  String get positiveNumber;

  /// No description provided for @invalidRuc.
  ///
  /// In es, this message translates to:
  /// **'El RUC debe comenzar con 10, 15, 17 o 20 y tener 11 dígitos.'**
  String get invalidRuc;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus obras desde cualquier lugar.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @projects.
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get projects;

  /// No description provided for @newProject.
  ///
  /// In es, this message translates to:
  /// **'Nuevo proyecto'**
  String get newProject;

  /// No description provided for @noProjects.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes proyectos asignados.'**
  String get noProjects;

  /// No description provided for @projectsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus proyectos.'**
  String get projectsLoadError;

  /// No description provided for @projectCreated.
  ///
  /// In es, this message translates to:
  /// **'Proyecto creado correctamente.'**
  String get projectCreated;

  /// No description provided for @projectName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get projectName;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @startDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin'**
  String get endDate;

  /// No description provided for @budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get budget;

  /// No description provided for @progress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progress;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @contractor.
  ///
  /// In es, this message translates to:
  /// **'Contratista'**
  String get contractor;

  /// No description provided for @selectContractor.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un contratista'**
  String get selectContractor;

  /// No description provided for @endDateBeforeStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior al inicio.'**
  String get endDateBeforeStart;

  /// No description provided for @statusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get statusActive;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get statusCompleted;

  /// No description provided for @statusSuspended.
  ///
  /// In es, this message translates to:
  /// **'Suspendido'**
  String get statusSuspended;

  /// No description provided for @materials.
  ///
  /// In es, this message translates to:
  /// **'Materiales'**
  String get materials;

  /// No description provided for @personnel.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get personnel;

  /// No description provided for @incidents.
  ///
  /// In es, this message translates to:
  /// **'Incidentes'**
  String get incidents;

  /// No description provided for @machinery.
  ///
  /// In es, this message translates to:
  /// **'Maquinaria'**
  String get machinery;

  /// No description provided for @more.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get more;

  /// No description provided for @reports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get reports;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @newMaterial.
  ///
  /// In es, this message translates to:
  /// **'Nuevo material'**
  String get newMaterial;

  /// No description provided for @editMaterial.
  ///
  /// In es, this message translates to:
  /// **'Editar material'**
  String get editMaterial;

  /// No description provided for @noMaterials.
  ///
  /// In es, this message translates to:
  /// **'No hay materiales registrados en esta obra.'**
  String get noMaterials;

  /// No description provided for @materialsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los materiales.'**
  String get materialsLoadError;

  /// No description provided for @materialCreated.
  ///
  /// In es, this message translates to:
  /// **'Material registrado.'**
  String get materialCreated;

  /// No description provided for @materialUpdated.
  ///
  /// In es, this message translates to:
  /// **'Material actualizado.'**
  String get materialUpdated;

  /// No description provided for @materialDeleted.
  ///
  /// In es, this message translates to:
  /// **'Material eliminado.'**
  String get materialDeleted;

  /// No description provided for @materialName.
  ///
  /// In es, this message translates to:
  /// **'Material'**
  String get materialName;

  /// No description provided for @unit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get unit;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad recibida'**
  String get quantity;

  /// No description provided for @stock.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible'**
  String get stock;

  /// No description provided for @minimumStock.
  ///
  /// In es, this message translates to:
  /// **'Stock mínimo'**
  String get minimumStock;

  /// No description provided for @unitPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio unitario'**
  String get unitPrice;

  /// No description provided for @provider.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get provider;

  /// No description provided for @providerRuc.
  ///
  /// In es, this message translates to:
  /// **'RUC del proveedor'**
  String get providerRuc;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @lowStock.
  ///
  /// In es, this message translates to:
  /// **'Stock bajo'**
  String get lowStock;

  /// No description provided for @entry.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get entry;

  /// No description provided for @usage.
  ///
  /// In es, this message translates to:
  /// **'Uso'**
  String get usage;

  /// No description provided for @registerEntry.
  ///
  /// In es, this message translates to:
  /// **'Registrar entrada'**
  String get registerEntry;

  /// No description provided for @registerUsage.
  ///
  /// In es, this message translates to:
  /// **'Registrar uso'**
  String get registerUsage;

  /// No description provided for @supplier.
  ///
  /// In es, this message translates to:
  /// **'Proveedor de la entrada'**
  String get supplier;

  /// No description provided for @occurredAt.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get occurredAt;

  /// No description provided for @note.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get note;

  /// No description provided for @movementRegistered.
  ///
  /// In es, this message translates to:
  /// **'Movimiento registrado.'**
  String get movementRegistered;

  /// No description provided for @usageExceedsStock.
  ///
  /// In es, this message translates to:
  /// **'La cantidad no puede superar el stock disponible.'**
  String get usageExceedsStock;

  /// No description provided for @deleteMaterialTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar material?'**
  String get deleteMaterialTitle;

  /// No description provided for @deleteMaterialMessage.
  ///
  /// In es, this message translates to:
  /// **'También se eliminará su historial de movimientos. Esta acción no se puede deshacer.'**
  String get deleteMaterialMessage;

  /// No description provided for @noMovements.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos para los filtros seleccionados.'**
  String get noMovements;

  /// No description provided for @movementHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de movimientos'**
  String get movementHistory;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @filterByType.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por tipo'**
  String get filterByType;

  /// No description provided for @registeredBy.
  ///
  /// In es, this message translates to:
  /// **'Registrado por'**
  String get registeredBy;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Esta sección está preparada para la Parte 2.'**
  String get comingSoon;

  /// No description provided for @selectedProject.
  ///
  /// In es, this message translates to:
  /// **'Obra seleccionada'**
  String get selectedProject;

  /// No description provided for @changeProject.
  ///
  /// In es, this message translates to:
  /// **'Cambiar proyecto'**
  String get changeProject;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'El correo o la contraseña son incorrectos.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInsufficientStock.
  ///
  /// In es, this message translates to:
  /// **'No hay stock suficiente para registrar este uso.'**
  String get errorInsufficientStock;

  /// No description provided for @errorDuplicatedSerialNumber.
  ///
  /// In es, this message translates to:
  /// **'El número de serie ya está registrado.'**
  String get errorDuplicatedSerialNumber;

  /// No description provided for @errorWorkerNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el trabajador.'**
  String get errorWorkerNotFound;

  /// No description provided for @errorInvalidContractor.
  ///
  /// In es, this message translates to:
  /// **'El contratista seleccionado no es válido.'**
  String get errorInvalidContractor;

  /// No description provided for @errorValidation.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos ingresados.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el recurso solicitado.'**
  String get errorNotFound;

  /// No description provided for @errorForbidden.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para realizar esta acción.'**
  String get errorForbidden;

  /// No description provided for @errorUnauthorized.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión nuevamente.'**
  String get errorUnauthorized;

  /// No description provided for @errorEmailAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'El correo ya está registrado.'**
  String get errorEmailAlreadyExists;

  /// No description provided for @errorProjectNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el proyecto.'**
  String get errorProjectNotFound;

  /// No description provided for @errorMaterialNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el material.'**
  String get errorMaterialNotFound;

  /// No description provided for @errorTaskNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la tarea.'**
  String get errorTaskNotFound;

  /// No description provided for @errorIncidentNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la incidencia.'**
  String get errorIncidentNotFound;

  /// No description provided for @errorMachineryNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la maquinaria.'**
  String get errorMachineryNotFound;

  /// No description provided for @errorWorkerHasTasks.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar un trabajador con tareas.'**
  String get errorWorkerHasTasks;

  /// No description provided for @errorDataConflict.
  ///
  /// In es, this message translates to:
  /// **'La operación entra en conflicto con datos existentes.'**
  String get errorDataConflict;

  /// No description provided for @errorConcurrentModification.
  ///
  /// In es, this message translates to:
  /// **'El recurso cambió. Actualiza e inténtalo de nuevo.'**
  String get errorConcurrentModification;

  /// No description provided for @errorInternal.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado en el servidor.'**
  String get errorInternal;

  /// No description provided for @networkError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con el servidor. Revisa tu conexión.'**
  String get networkError;

  /// No description provided for @workers.
  ///
  /// In es, this message translates to:
  /// **'Trabajadores'**
  String get workers;

  /// No description provided for @tasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasks;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @noRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay registros para estos filtros.'**
  String get noRecords;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados.'**
  String get saved;

  /// No description provided for @deleteRecord.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este registro?'**
  String get deleteRecord;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @workerRole.
  ///
  /// In es, this message translates to:
  /// **'Cargo'**
  String get workerRole;

  /// No description provided for @specialty.
  ///
  /// In es, this message translates to:
  /// **'Especialidad'**
  String get specialty;

  /// No description provided for @hireDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de contratación'**
  String get hireDate;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @title.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @dueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha límite'**
  String get dueDate;

  /// No description provided for @worker.
  ///
  /// In es, this message translates to:
  /// **'Trabajador'**
  String get worker;

  /// No description provided for @overdue.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get overdue;

  /// No description provided for @complete.
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get complete;

  /// No description provided for @resolve.
  ///
  /// In es, this message translates to:
  /// **'Resolver'**
  String get resolve;

  /// No description provided for @severity.
  ///
  /// In es, this message translates to:
  /// **'Gravedad'**
  String get severity;

  /// No description provided for @incidentType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de incidente'**
  String get incidentType;

  /// No description provided for @reportedAt.
  ///
  /// In es, this message translates to:
  /// **'Fecha de reporte'**
  String get reportedAt;

  /// No description provided for @serialNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de serie'**
  String get serialNumber;

  /// No description provided for @registeredAt.
  ///
  /// In es, this message translates to:
  /// **'Fecha de registro'**
  String get registeredAt;

  /// No description provided for @invalidSerial.
  ///
  /// In es, this message translates to:
  /// **'Usa 3 a 20 letras, números o guiones.'**
  String get invalidSerial;

  /// No description provided for @invalidDate.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una fecha válida YYYY-MM-DD.'**
  String get invalidDate;

  /// No description provided for @noEligibleWorkers.
  ///
  /// In es, this message translates to:
  /// **'Registra un trabajador activo o de licencia para asignar tareas.'**
  String get noEligibleWorkers;

  /// No description provided for @assignTask.
  ///
  /// In es, this message translates to:
  /// **'Asignar tarea'**
  String get assignTask;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @company.
  ///
  /// In es, this message translates to:
  /// **'Empresa'**
  String get company;

  /// No description provided for @localProfile.
  ///
  /// In es, this message translates to:
  /// **'Estos datos se guardan solo en este dispositivo.'**
  String get localProfile;

  /// No description provided for @textSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de texto'**
  String get textSize;

  /// No description provided for @normalText.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normalText;

  /// No description provided for @largeText.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get largeText;

  /// No description provided for @extraLargeText.
  ///
  /// In es, this message translates to:
  /// **'Muy grande'**
  String get extraLargeText;

  /// No description provided for @highContrast.
  ///
  /// In es, this message translates to:
  /// **'Alto contraste'**
  String get highContrast;

  /// No description provided for @reduceMotion.
  ///
  /// In es, this message translates to:
  /// **'Reducir movimiento'**
  String get reduceMotion;

  /// No description provided for @alerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alerts;

  /// No description provided for @criticalIncident.
  ///
  /// In es, this message translates to:
  /// **'Incidente crítico'**
  String get criticalIncident;

  /// No description provided for @currentWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana actual'**
  String get currentWeek;

  /// No description provided for @previousWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana anterior'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana siguiente'**
  String get nextWeek;

  /// No description provided for @selectDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get selectDate;

  /// No description provided for @completedTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas completadas'**
  String get completedTasks;

  /// No description provided for @openTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas abiertas'**
  String get openTasks;

  /// No description provided for @openIncidents.
  ///
  /// In es, this message translates to:
  /// **'Incidentes abiertos'**
  String get openIncidents;

  /// No description provided for @generatePdf.
  ///
  /// In es, this message translates to:
  /// **'Generar PDF'**
  String get generatePdf;

  /// No description provided for @deleteWarning.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get deleteWarning;

  /// No description provided for @valueActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get valueActive;

  /// No description provided for @valueOnLeave.
  ///
  /// In es, this message translates to:
  /// **'De licencia'**
  String get valueOnLeave;

  /// No description provided for @valueInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get valueInactive;

  /// No description provided for @valuePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get valuePending;

  /// No description provided for @valueInProgress.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get valueInProgress;

  /// No description provided for @valueCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get valueCompleted;

  /// No description provided for @valueOpen.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get valueOpen;

  /// No description provided for @valueInReview.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get valueInReview;

  /// No description provided for @valueResolved.
  ///
  /// In es, this message translates to:
  /// **'Resuelto'**
  String get valueResolved;

  /// No description provided for @valueOperational.
  ///
  /// In es, this message translates to:
  /// **'Operativa'**
  String get valueOperational;

  /// No description provided for @valueMaintenance.
  ///
  /// In es, this message translates to:
  /// **'En mantenimiento'**
  String get valueMaintenance;

  /// No description provided for @valueOutOfService.
  ///
  /// In es, this message translates to:
  /// **'Fuera de servicio'**
  String get valueOutOfService;

  /// No description provided for @valueHigh.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get valueHigh;

  /// No description provided for @valueMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get valueMedium;

  /// No description provided for @valueLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get valueLow;

  /// No description provided for @valueMaterialShortage.
  ///
  /// In es, this message translates to:
  /// **'Falta de materiales'**
  String get valueMaterialShortage;

  /// No description provided for @valueDeliveryDelay.
  ///
  /// In es, this message translates to:
  /// **'Retraso en entrega'**
  String get valueDeliveryDelay;

  /// No description provided for @valueEquipmentFailure.
  ///
  /// In es, this message translates to:
  /// **'Falla de equipo'**
  String get valueEquipmentFailure;

  /// No description provided for @valueWorkAccident.
  ///
  /// In es, this message translates to:
  /// **'Accidente laboral'**
  String get valueWorkAccident;

  /// No description provided for @valueUnsafeCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición insegura'**
  String get valueUnsafeCondition;

  /// No description provided for @valueOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get valueOther;

  /// No description provided for @attendance.
  ///
  /// In es, this message translates to:
  /// **'Asistencia'**
  String get attendance;

  /// No description provided for @attendanceDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de asistencia'**
  String get attendanceDate;

  /// No description provided for @attendancePresent.
  ///
  /// In es, this message translates to:
  /// **'Presente'**
  String get attendancePresent;

  /// No description provided for @attendanceAbsent.
  ///
  /// In es, this message translates to:
  /// **'Ausente'**
  String get attendanceAbsent;

  /// No description provided for @attendanceLate.
  ///
  /// In es, this message translates to:
  /// **'Tardanza'**
  String get attendanceLate;

  /// No description provided for @attendanceExcused.
  ///
  /// In es, this message translates to:
  /// **'Justificado'**
  String get attendanceExcused;

  /// No description provided for @attendanceHistory.
  ///
  /// In es, this message translates to:
  /// **'Todo el historial'**
  String get attendanceHistory;

  /// No description provided for @checkIn.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get checkOut;

  /// No description provided for @clearTime.
  ///
  /// In es, this message translates to:
  /// **'Quitar hora'**
  String get clearTime;

  /// No description provided for @attendanceInvalidTimes.
  ///
  /// In es, this message translates to:
  /// **'La salida requiere entrada y no puede ser anterior.'**
  String get attendanceInvalidTimes;

  /// No description provided for @attendanceBeforeHire.
  ///
  /// In es, this message translates to:
  /// **'La asistencia no puede ser anterior a la contratación.'**
  String get attendanceBeforeHire;

  /// No description provided for @errorDuplicateAttendance.
  ///
  /// In es, this message translates to:
  /// **'Ya existe asistencia para este trabajador en esa fecha. Edita el registro existente.'**
  String get errorDuplicateAttendance;

  /// No description provided for @errorAttendanceNotFound.
  ///
  /// In es, this message translates to:
  /// **'El registro de asistencia ya no existe.'**
  String get errorAttendanceNotFound;

  /// No description provided for @errorWorkerHasAttendance.
  ///
  /// In es, this message translates to:
  /// **'El trabajador tiene registros de asistencia. Márcalo como inactivo para conservar su historial o elimina primero esos registros.'**
  String get errorWorkerHasAttendance;

  /// No description provided for @deleteProject.
  ///
  /// In es, this message translates to:
  /// **'Eliminar proyecto'**
  String get deleteProject;

  /// No description provided for @deleteProjectWarning.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible. Se eliminarán trabajadores, tareas, asistencia, materiales y movimientos, incidentes y maquinaria de esta obra.'**
  String get deleteProjectWarning;

  /// No description provided for @confirmProjectName.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del proyecto para confirmar'**
  String get confirmProjectName;

  /// No description provided for @projectDeleted.
  ///
  /// In es, this message translates to:
  /// **'Proyecto eliminado'**
  String get projectDeleted;

  /// No description provided for @termsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditions;

  /// No description provided for @legalOpensBrowser.
  ///
  /// In es, this message translates to:
  /// **'Abrir el acuerdo SaaS público en el navegador'**
  String get legalOpensBrowser;

  /// No description provided for @legalOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el navegador. Inténtalo de nuevo.'**
  String get legalOpenError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
