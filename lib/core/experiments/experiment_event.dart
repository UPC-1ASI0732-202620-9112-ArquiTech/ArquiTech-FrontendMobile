import 'dart:convert';

const String kExperimentSchemaVersion = '1.0';

enum ExperimentEventName {
  materialOperationStarted('material_operation_started'),
  materialOperationCompleted('material_operation_completed'),
  materialOperationFailed('material_operation_failed'),
  projectConsultationStarted('project_consultation_started'),
  projectConsultationLoaded('project_consultation_loaded'),
  projectConsultationFailed('project_consultation_failed'),
  projectReportOpened('project_report_opened');

  const ExperimentEventName(this.value);
  final String value;

  bool get isMaterialEvent => value.startsWith('material_operation_');

  static ExperimentEventName? tryParse(String? raw) {
    for (final candidate in ExperimentEventName.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

enum TrackedExperimentId {
  ec01('EC01', 'Q01', ['M01', 'F01']),
  ec02('EC02', 'Q02', ['M02', 'F01']),
  ec03('EC03', 'Q03', ['M03', 'F01']),
  ec04('EC04', 'Q04', ['M04', 'F01']),
  ec05('EC05', 'Q05', ['M05', 'F01']),
  ec06('EC06', 'Q06', ['M06', 'M07', 'F02']),
  ec07('EC07', 'Q07', ['M08', 'F01']),
  ec08('EC08', 'Q08', ['M09', 'F01']),
  ec09('EC09', 'Q09', ['M10', 'F01']),
  ec10('EC10', 'Q10', ['M11', 'F03']);

  const TrackedExperimentId(this.value, this.questionId, this.metricIds);
  final String value;
  final String questionId;
  final List<String> metricIds;

  static TrackedExperimentId? tryParse(String? raw) {
    for (final candidate in TrackedExperimentId.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

enum ExperimentPlatform {
  web('web'),
  mobile('mobile'),
  landing('landing');

  const ExperimentPlatform(this.value);
  final String value;

  static ExperimentPlatform? tryParse(String? raw) {
    for (final candidate in ExperimentPlatform.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

enum ExperimentCondition {
  a('A'),
  b('B'),
  unknown('unknown');

  const ExperimentCondition(this.value);
  final String value;

  static ExperimentCondition? tryParse(String? raw) {
    for (final candidate in ExperimentCondition.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

enum ExperimentOutcome {
  started('started'),
  completed('completed'),
  loaded('loaded'),
  opened('opened'),
  validationFailed('validation_failed'),
  apiFailed('api_failed');

  const ExperimentOutcome(this.value);
  final String value;

  static ExperimentOutcome? tryParse(String? raw) {
    for (final candidate in ExperimentOutcome.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

enum ExperimentOperationType {
  entry('ENTRY'),
  usage('USAGE');

  const ExperimentOperationType(this.value);
  final String value;

  static ExperimentOperationType? tryParse(String? raw) {
    for (final candidate in ExperimentOperationType.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

enum ExperimentErrorCategory {
  validation('validation'),
  insufficientStock('insufficient_stock'),
  network('network'),
  unauthorized('unauthorized'),
  conflict('conflict'),
  notFound('not_found'),
  apiError('api_error'),
  unknown('unknown');

  const ExperimentErrorCategory(this.value);
  final String value;

  static ExperimentErrorCategory? tryParse(String? raw) {
    for (final candidate in ExperimentErrorCategory.values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}

class ExperimentEventValidationResult {
  const ExperimentEventValidationResult({
    required this.valid,
    required this.errors,
  });

  final bool valid;
  final List<String> errors;
}

class ExperimentEvent {
  const ExperimentEvent({
    this.schemaVersion = kExperimentSchemaVersion,
    required this.eventName,
    required this.experimentId,
    required this.questionId,
    required this.metricIds,
    required this.platform,
    required this.condition,
    required this.timestamp,
    required this.sessionId,
    required this.attemptId,
    required this.outcome,
    this.durationMs,
    this.operationType,
    this.errorCategory,
  });

  final String schemaVersion;
  final ExperimentEventName eventName;
  final TrackedExperimentId experimentId;
  final String questionId;
  final List<String> metricIds;
  final ExperimentPlatform platform;
  final ExperimentCondition condition;
  final String timestamp;
  final String sessionId;
  final String attemptId;
  final ExperimentOutcome outcome;
  final int? durationMs;
  final ExperimentOperationType? operationType;
  final ExperimentErrorCategory? errorCategory;

  Map<String, Object> toJson() {
    final map = <String, Object>{
      'schema_version': schemaVersion,
      'event_name': eventName.value,
      'experiment_id': experimentId.value,
      'question_id': questionId,
      'metric_ids': List<String>.unmodifiable(metricIds),
      'platform': platform.value,
      'condition': condition.value,
      'timestamp': timestamp,
      'session_id': sessionId,
      'attempt_id': attemptId,
      'outcome': outcome.value,
    };
    if (durationMs != null) {
      map['duration_ms'] = durationMs!;
    }
    if (operationType != null) {
      map['operation_type'] = operationType!.value;
    }
    if (errorCategory != null) {
      map['error_category'] = errorCategory!.value;
    }
    return map;
  }

  String toJsonLine() => jsonEncode(toJson());

  ExperimentEventValidationResult validate() =>
      validateExperimentEventJson(toJson());

  static const Set<String> _allowedKeys = {
    'schema_version',
    'event_name',
    'experiment_id',
    'question_id',
    'metric_ids',
    'platform',
    'condition',
    'timestamp',
    'session_id',
    'attempt_id',
    'outcome',
    'duration_ms',
    'operation_type',
    'error_category',
  };

  static final RegExp _forbiddenKeyPattern = RegExp(
    r'^(user_?id|project_?id|material_?id|worker_?id|incident_?id|name|full_?name|user_?name|project_?name|material_?name|supplier|email|contact_?email|password|jwt|token|authorization|body|payload|note|notes|description|error_?message|message|raw_?error|company|budget|price|cost|outcome_?correct|help_?requested)$',
    caseSensitive: false,
  );
  static final RegExp _safeOpaqueIdPattern = RegExp(
    r'^(sess|att)-[a-z0-9]{8,48}$',
  );
  static final RegExp _isoUtcTimestampPattern = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z$',
  );
  static final RegExp _emailValuePattern = RegExp(r'[^\s@]+@[^\s@]+\.[^\s@]+');
  static final RegExp _jwtValuePattern = RegExp(
    r'^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$',
  );

  static ExperimentEventValidationResult validateExperimentEventJson(
    Map<String, Object?> record,
  ) {
    final errors = <String>[];

    for (final entry in record.entries) {
      final key = entry.key;
      if (_forbiddenKeyPattern.hasMatch(key) || !_allowedKeys.contains(key)) {
        errors.add('Forbidden or unknown field: $key');
      }
      final val = entry.value;
      if (val is String) {
        if (_emailValuePattern.hasMatch(val) ||
            _jwtValuePattern.hasMatch(val)) {
          errors.add('Sensitive value pattern detected in field: $key');
        }
      }
    }

    if (record['schema_version'] != kExperimentSchemaVersion) {
      errors.add('Invalid schema_version');
    }

    final eventName = ExperimentEventName.tryParse(
      record['event_name'] as String?,
    );
    if (eventName == null) {
      errors.add('Invalid event_name');
    }

    final experimentId = TrackedExperimentId.tryParse(
      record['experiment_id'] as String?,
    );
    if (experimentId == null) {
      errors.add('Invalid experiment_id');
    } else {
      if (record['question_id'] != experimentId.questionId) {
        errors.add('question_id does not match experiment_id');
      }
      final metricIds = record['metric_ids'];
      if (metricIds is! List ||
          metricIds.length != experimentId.metricIds.length ||
          !_listEquals(metricIds, experimentId.metricIds)) {
        errors.add('metric_ids do not match experiment_id catalog');
      }
    }

    if (ExperimentPlatform.tryParse(record['platform'] as String?) == null) {
      errors.add('Invalid platform');
    }

    if (ExperimentCondition.tryParse(record['condition'] as String?) == null) {
      errors.add('Invalid condition');
    }

    final timestamp = record['timestamp'];
    if (timestamp is! String ||
        !_isoUtcTimestampPattern.hasMatch(timestamp) ||
        DateTime.tryParse(timestamp) == null) {
      errors.add('Invalid UTC ISO 8601 timestamp');
    }

    final sessionId = record['session_id'];
    if (sessionId is! String ||
        !_safeOpaqueIdPattern.hasMatch(sessionId) ||
        !sessionId.startsWith('sess-')) {
      errors.add('Invalid session_id');
    }

    final attemptId = record['attempt_id'];
    if (attemptId is! String ||
        !_safeOpaqueIdPattern.hasMatch(attemptId) ||
        !attemptId.startsWith('att-')) {
      errors.add('Invalid attempt_id');
    }

    final outcome = ExperimentOutcome.tryParse(record['outcome'] as String?);
    if (outcome == null) {
      errors.add('Invalid outcome');
    }

    final durationMs = record['duration_ms'];
    if (durationMs != null) {
      if (durationMs is! num || !durationMs.isFinite || durationMs < 0) {
        errors.add('duration_ms must be a non-negative finite number');
      }
    }

    final rawOperationType = record['operation_type'];
    final operationType = rawOperationType == null
        ? null
        : ExperimentOperationType.tryParse(rawOperationType as String?);
    if (rawOperationType != null && operationType == null) {
      errors.add('Invalid operation_type');
    }

    final rawErrorCategory = record['error_category'];
    final errorCategory = rawErrorCategory == null
        ? null
        : ExperimentErrorCategory.tryParse(rawErrorCategory as String?);
    if (rawErrorCategory != null && errorCategory == null) {
      errors.add('Invalid error_category');
    }

    if (eventName != null) {
      if (eventName.isMaterialEvent) {
        if (experimentId != TrackedExperimentId.ec01) {
          errors.add('Material operation events must reference EC01');
        }
        if (operationType == null) {
          errors.add('Material operation events require operation_type');
        }
      } else {
        if (experimentId != TrackedExperimentId.ec04) {
          errors.add('Project consultation events must reference EC04');
        }
        if (rawOperationType != null) {
          errors.add(
            'operation_type is only allowed on material operation events',
          );
        }
      }

      switch (eventName) {
        case ExperimentEventName.materialOperationStarted:
        case ExperimentEventName.projectConsultationStarted:
          if (outcome != ExperimentOutcome.started) {
            errors.add('${eventName.value} requires outcome="started"');
          }
          if (rawErrorCategory != null) {
            errors.add('${eventName.value} must not include error_category');
          }
        case ExperimentEventName.materialOperationCompleted:
          if (outcome != ExperimentOutcome.completed) {
            errors.add(
              'material_operation_completed requires outcome="completed"',
            );
          }
          if (durationMs == null) {
            errors.add('material_operation_completed requires duration_ms');
          }
          if (rawErrorCategory != null) {
            errors.add(
              'material_operation_completed must not include error_category',
            );
          }
        case ExperimentEventName.materialOperationFailed:
          if (outcome != ExperimentOutcome.validationFailed &&
              outcome != ExperimentOutcome.apiFailed) {
            errors.add(
              'material_operation_failed requires outcome="validation_failed" or "api_failed"',
            );
          }
          if (durationMs == null) {
            errors.add('material_operation_failed requires duration_ms');
          }
          if (errorCategory == null) {
            errors.add('material_operation_failed requires error_category');
          }
        case ExperimentEventName.projectConsultationLoaded:
          if (outcome != ExperimentOutcome.loaded) {
            errors.add('project_consultation_loaded requires outcome="loaded"');
          }
          if (durationMs == null) {
            errors.add('project_consultation_loaded requires duration_ms');
          }
          if (rawErrorCategory != null) {
            errors.add(
              'project_consultation_loaded must not include error_category',
            );
          }
        case ExperimentEventName.projectConsultationFailed:
          if (outcome != ExperimentOutcome.apiFailed) {
            errors.add(
              'project_consultation_failed requires outcome="api_failed"',
            );
          }
          if (durationMs == null) {
            errors.add('project_consultation_failed requires duration_ms');
          }
          if (errorCategory == null) {
            errors.add('project_consultation_failed requires error_category');
          }
        case ExperimentEventName.projectReportOpened:
          if (outcome != ExperimentOutcome.opened) {
            errors.add('project_report_opened requires outcome="opened"');
          }
          if (rawErrorCategory != null) {
            errors.add('project_report_opened must not include error_category');
          }
      }
    }

    return ExperimentEventValidationResult(
      valid: errors.isEmpty,
      errors: List<String>.unmodifiable(errors),
    );
  }

  static bool _listEquals(List<dynamic> actual, List<String> expected) {
    for (var i = 0; i < expected.length; i++) {
      if (actual[i] != expected[i]) return false;
    }
    return true;
  }
}
