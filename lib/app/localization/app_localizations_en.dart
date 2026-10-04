// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ArquiTech';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get optional => 'Optional';

  @override
  String get accessDenied => 'Access denied';

  @override
  String get sessionExpired => 'Your session expired. Sign in again.';

  @override
  String get genericError => 'We could not complete the operation.';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get invalidNumber => 'Enter a valid number.';

  @override
  String get nonNegativeNumber => 'The value cannot be negative.';

  @override
  String get positiveNumber => 'The value must be greater than zero.';

  @override
  String get invalidRuc =>
      'The RUC must start with 10, 15, 17 or 20 and contain 11 digits.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Manage your construction sites from anywhere.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get projects => 'Projects';

  @override
  String get newProject => 'New project';

  @override
  String get noProjects => 'You do not have assigned projects yet.';

  @override
  String get projectsLoadError => 'We could not load your projects.';

  @override
  String get projectCreated => 'Project created successfully.';

  @override
  String get projectName => 'Name';

  @override
  String get location => 'Location';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get budget => 'Budget';

  @override
  String get progress => 'Progress';

  @override
  String get status => 'Status';

  @override
  String get contractor => 'Contractor';

  @override
  String get selectContractor => 'Select a contractor';

  @override
  String get endDateBeforeStart =>
      'The end date cannot be before the start date.';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get materials => 'Materials';

  @override
  String get personnel => 'Personnel';

  @override
  String get incidents => 'Incidents';

  @override
  String get machinery => 'Machinery';

  @override
  String get more => 'More';

  @override
  String get reports => 'Reports';

  @override
  String get profile => 'Profile';

  @override
  String get history => 'History';

  @override
  String get newMaterial => 'New material';

  @override
  String get editMaterial => 'Edit material';

  @override
  String get noMaterials =>
      'No materials have been registered for this project.';

  @override
  String get materialsLoadError => 'We could not load the materials.';

  @override
  String get materialCreated => 'Material registered.';

  @override
  String get materialUpdated => 'Material updated.';

  @override
  String get materialDeleted => 'Material deleted.';

  @override
  String get materialName => 'Material';

  @override
  String get unit => 'Unit';

  @override
  String get quantity => 'Total received';

  @override
  String get stock => 'Available stock';

  @override
  String get minimumStock => 'Minimum stock';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get provider => 'Provider';

  @override
  String get providerRuc => 'Provider RUC';

  @override
  String get date => 'Date';

  @override
  String get lowStock => 'Low stock';

  @override
  String get entry => 'Entry';

  @override
  String get usage => 'Usage';

  @override
  String get registerEntry => 'Register entry';

  @override
  String get registerUsage => 'Register usage';

  @override
  String get supplier => 'Entry supplier';

  @override
  String get occurredAt => 'Date and time';

  @override
  String get note => 'Note';

  @override
  String get movementRegistered => 'Movement registered.';

  @override
  String get usageExceedsStock =>
      'The quantity cannot exceed the available stock.';

  @override
  String get deleteMaterialTitle => 'Delete material?';

  @override
  String get deleteMaterialMessage =>
      'Its movement history will also be deleted. This action cannot be undone.';

  @override
  String get noMovements => 'There are no movements for the selected filters.';

  @override
  String get movementHistory => 'Movement history';

  @override
  String get all => 'All';

  @override
  String get filterByType => 'Filter by type';

  @override
  String get registeredBy => 'Registered by';

  @override
  String get comingSoon => 'This section is prepared for Part 2.';

  @override
  String get selectedProject => 'Selected project';

  @override
  String get changeProject => 'Change project';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get errorInvalidCredentials => 'The email or password is incorrect.';

  @override
  String get errorInsufficientStock =>
      'There is not enough stock for this usage.';

  @override
  String get errorDuplicatedSerialNumber =>
      'The serial number is already registered.';

  @override
  String get errorWorkerNotFound => 'The worker was not found.';

  @override
  String get errorInvalidContractor => 'The selected contractor is invalid.';

  @override
  String get errorValidation => 'Review the entered information.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorForbidden =>
      'You do not have permission to perform this action.';

  @override
  String get errorUnauthorized => 'You must sign in again.';

  @override
  String get errorEmailAlreadyExists => 'The email is already registered.';

  @override
  String get errorProjectNotFound => 'The project was not found.';

  @override
  String get errorMaterialNotFound => 'The material was not found.';

  @override
  String get errorTaskNotFound => 'The task was not found.';

  @override
  String get errorIncidentNotFound => 'The incident was not found.';

  @override
  String get errorMachineryNotFound => 'The machinery was not found.';

  @override
  String get errorWorkerHasTasks => 'A worker with tasks cannot be deleted.';

  @override
  String get errorDataConflict => 'The operation conflicts with existing data.';

  @override
  String get errorConcurrentModification =>
      'The resource changed. Refresh and try again.';

  @override
  String get errorInternal => 'An unexpected server error occurred.';

  @override
  String get networkError =>
      'Could not connect to the server. Check your connection.';
}
