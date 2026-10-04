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

  @override
  String get workers => 'Workers';

  @override
  String get tasks => 'Tasks';

  @override
  String get search => 'Search';

  @override
  String get noRecords => 'No records match these filters.';

  @override
  String get saved => 'Changes saved.';

  @override
  String get deleteRecord => 'Delete this record?';

  @override
  String get fullName => 'Full name';

  @override
  String get workerRole => 'Role';

  @override
  String get specialty => 'Specialty';

  @override
  String get hireDate => 'Hire date';

  @override
  String get description => 'Description';

  @override
  String get title => 'Title';

  @override
  String get dueDate => 'Due date';

  @override
  String get worker => 'Worker';

  @override
  String get overdue => 'Overdue';

  @override
  String get complete => 'Complete';

  @override
  String get resolve => 'Resolve';

  @override
  String get severity => 'Severity';

  @override
  String get incidentType => 'Incident type';

  @override
  String get reportedAt => 'Reported at';

  @override
  String get serialNumber => 'Serial number';

  @override
  String get registeredAt => 'Registered at';

  @override
  String get invalidSerial => 'Use 3 to 20 letters, digits or hyphens.';

  @override
  String get invalidDate => 'Enter a valid YYYY-MM-DD date.';

  @override
  String get noEligibleWorkers =>
      'Register an active or on-leave worker to assign tasks.';

  @override
  String get assignTask => 'Assign task';

  @override
  String get settings => 'Settings';

  @override
  String get phone => 'Phone';

  @override
  String get company => 'Company';

  @override
  String get localProfile => 'These details are saved only on this device.';

  @override
  String get textSize => 'Text size';

  @override
  String get normalText => 'Normal';

  @override
  String get largeText => 'Large';

  @override
  String get extraLargeText => 'Extra large';

  @override
  String get highContrast => 'High contrast';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get alerts => 'Alerts';

  @override
  String get criticalIncident => 'Critical incident';

  @override
  String get currentWeek => 'Current week';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get selectDate => 'Select date';

  @override
  String get completedTasks => 'Completed tasks';

  @override
  String get openTasks => 'Open tasks';

  @override
  String get openIncidents => 'Open incidents';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get deleteWarning => 'This action cannot be undone.';

  @override
  String get valueActive => 'Active';

  @override
  String get valueOnLeave => 'On leave';

  @override
  String get valueInactive => 'Inactive';

  @override
  String get valuePending => 'Pending';

  @override
  String get valueInProgress => 'In progress';

  @override
  String get valueCompleted => 'Completed';

  @override
  String get valueOpen => 'Open';

  @override
  String get valueInReview => 'In review';

  @override
  String get valueResolved => 'Resolved';

  @override
  String get valueOperational => 'Operational';

  @override
  String get valueMaintenance => 'Maintenance';

  @override
  String get valueOutOfService => 'Out of service';

  @override
  String get valueHigh => 'High';

  @override
  String get valueMedium => 'Medium';

  @override
  String get valueLow => 'Low';

  @override
  String get valueMaterialShortage => 'Material shortage';

  @override
  String get valueDeliveryDelay => 'Delivery delay';

  @override
  String get valueEquipmentFailure => 'Equipment failure';

  @override
  String get valueWorkAccident => 'Work accident';

  @override
  String get valueUnsafeCondition => 'Unsafe condition';

  @override
  String get valueOther => 'Other';
}
