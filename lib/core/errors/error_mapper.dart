import '../../app/localization/app_localizations.dart';
import 'api_error.dart';

abstract final class ErrorMapper {
  static String message(AppLocalizations l10n, Object error) {
    final code = error is ApiError ? error.code : 'INTERNAL_ERROR';
    return switch (code) {
      'INVALID_CREDENTIALS' => l10n.errorInvalidCredentials,
      'INSUFFICIENT_STOCK' => l10n.errorInsufficientStock,
      'DUPLICATED_SERIAL_NUMBER' => l10n.errorDuplicatedSerialNumber,
      'WORKER_NOT_FOUND' => l10n.errorWorkerNotFound,
      'INVALID_CONTRACTOR' => l10n.errorInvalidContractor,
      'VALIDATION_ERROR' => l10n.errorValidation,
      'NOT_FOUND' => l10n.errorNotFound,
      'FORBIDDEN' => l10n.errorForbidden,
      'UNAUTHORIZED' => l10n.errorUnauthorized,
      'EMAIL_ALREADY_EXISTS' => l10n.errorEmailAlreadyExists,
      'PROJECT_NOT_FOUND' => l10n.errorProjectNotFound,
      'MATERIAL_NOT_FOUND' => l10n.errorMaterialNotFound,
      'TASK_NOT_FOUND' => l10n.errorTaskNotFound,
      'INCIDENT_NOT_FOUND' => l10n.errorIncidentNotFound,
      'MACHINERY_NOT_FOUND' => l10n.errorMachineryNotFound,
      'WORKER_HAS_TASKS' => l10n.errorWorkerHasTasks,
      'WORKER_HAS_ATTENDANCE' => l10n.errorWorkerHasAttendance,
      'ATTENDANCE_NOT_FOUND' => l10n.errorAttendanceNotFound,
      'DUPLICATE_ATTENDANCE' => l10n.errorDuplicateAttendance,
      'DATA_CONFLICT' => l10n.errorDataConflict,
      'CONCURRENT_MODIFICATION' => l10n.errorConcurrentModification,
      'NETWORK_ERROR' => l10n.networkError,
      _ => l10n.errorInternal,
    };
  }
}
