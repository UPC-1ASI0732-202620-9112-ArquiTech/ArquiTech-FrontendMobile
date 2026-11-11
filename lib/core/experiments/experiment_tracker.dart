import 'dart:math';

import 'package:flutter/foundation.dart';

import '../errors/api_error.dart';
import 'experiment_event.dart';

const bool kExperimentTrackingEnabledByDefine = bool.fromEnvironment(
  'EXPERIMENT_TRACKING_ENABLED',
  defaultValue: false,
);

abstract interface class ExperimentEventSink {
  void emit(ExperimentEvent event);
}

class NoopExperimentEventSink implements ExperimentEventSink {
  const NoopExperimentEventSink();

  @override
  void emit(ExperimentEvent event) {}
}

class InMemoryExperimentEventSink implements ExperimentEventSink {
  final List<ExperimentEvent> _buffer = <ExperimentEvent>[];

  @override
  void emit(ExperimentEvent event) {
    _buffer.add(event);
  }

  List<ExperimentEvent> get events => List<ExperimentEvent>.unmodifiable(_buffer);

  void clear() => _buffer.clear();

  String toJsonLines() => _buffer.map((event) => event.toJsonLine()).join('\n');
}

class DebugPrintExperimentEventSink implements ExperimentEventSink {
  DebugPrintExperimentEventSink({void Function(String line)? logger})
    : _logger = logger ?? ((line) => debugPrint('[experiment-tracking] $line'));

  final void Function(String line) _logger;

  @override
  void emit(ExperimentEvent event) {
    _logger(event.toJsonLine());
  }
}

class MaterialOperationAttemptHandle {
  MaterialOperationAttemptHandle._({
    required this.attemptId,
    required this._onComplete,
    required this._onFailValidation,
    required this._onFailApi,
  });

  final String attemptId;
  final void Function() _onComplete;
  final void Function(ExperimentErrorCategory category) _onFailValidation;
  final void Function(ExperimentErrorCategory category) _onFailApi;
  bool _finalized = false;

  void complete() {
    if (_finalized) return;
    _finalized = true;
    _onComplete();
  }

  void failValidation({
    ExperimentErrorCategory errorCategory = ExperimentErrorCategory.validation,
  }) {
    if (_finalized) return;
    _finalized = true;
    _onFailValidation(errorCategory);
  }

  void failApi({
    ExperimentErrorCategory errorCategory = ExperimentErrorCategory.apiError,
  }) {
    if (_finalized) return;
    _finalized = true;
    _onFailApi(errorCategory);
  }
}

class ProjectConsultationAttemptHandle {
  ProjectConsultationAttemptHandle._({
    required this.attemptId,
    required this.condition,
    required this._onLoaded,
    required this._onFailApi,
    required this._onOpenReport,
  });

  final String attemptId;
  final ExperimentCondition condition;
  final void Function() _onLoaded;
  final void Function(ExperimentErrorCategory category) _onFailApi;
  final void Function() _onOpenReport;
  bool _loadFinalized = false;
  bool _loadSucceeded = false;
  bool _reportOpened = false;
  bool _openReportAfterLoad = false;

  void loaded() {
    if (_loadFinalized) return;
    _loadFinalized = true;
    _loadSucceeded = true;
    _onLoaded();
    if (_openReportAfterLoad) {
      openReport();
    }
  }

  void failApi({
    ExperimentErrorCategory errorCategory = ExperimentErrorCategory.apiError,
  }) {
    if (_loadFinalized) return;
    _loadFinalized = true;
    _openReportAfterLoad = false;
    _onFailApi(errorCategory);
  }

  void openReport() {
    if (_reportOpened) return;
    _reportOpened = true;
    _onOpenReport();
  }

  void openReportWhenLoaded() {
    if (_loadSucceeded) {
      openReport();
    } else if (!_loadFinalized) {
      _openReportAfterLoad = true;
    }
  }
}

class _ConsultationRecord {
  _ConsultationRecord({
    required this.attemptId,
    required this.startedAtMs,
    this.reportOpened = false,
  });

  final String attemptId;
  final int startedAtMs;
  bool reportOpened;
}

class ExperimentTracker {
  ExperimentTracker({
    bool enabled = kExperimentTrackingEnabledByDefine,
    ExperimentEventSink? sink,
    ExperimentEventSink? debugSink,
    int Function()? monotonicMilliseconds,
    String Function()? utcTimestamp,
  }) : _monotonicMilliseconds =
           monotonicMilliseconds ?? _defaultMonotonicClock(),
       _utcTimestamp =
           utcTimestamp ?? (() => DateTime.now().toUtc().toIso8601String()),
       sessionId = _generateOpaqueToken('sess') {
    _enabled = enabled;
    _customSink = sink;
    _debugSink = debugSink;
  }

  static int Function() _defaultMonotonicClock() {
    final stopwatch = Stopwatch()..start();
    return () => stopwatch.elapsedMilliseconds;
  }

  final InMemoryExperimentEventSink _memorySink = InMemoryExperimentEventSink();
  final NoopExperimentEventSink _noopSink = const NoopExperimentEventSink();
  late bool _enabled;
  ExperimentEventSink? _customSink;
  ExperimentEventSink? _debugSink;
  final int Function() _monotonicMilliseconds;
  final String Function() _utcTimestamp;

  final String sessionId;

  final Map<ExperimentCondition, ProjectConsultationAttemptHandle>
  _pendingConsultations =
      <ExperimentCondition, ProjectConsultationAttemptHandle>{};
  final Map<ExperimentCondition, _ConsultationRecord> _latestConsultations =
      <ExperimentCondition, _ConsultationRecord>{};

  bool get isEnabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  void setSink(ExperimentEventSink? sink) {
    _customSink = sink;
  }

  void setDebugSink(ExperimentEventSink? sink) {
    _debugSink = sink;
  }

  List<ExperimentEvent> get events => _memorySink.events;

  void clear() {
    _memorySink.clear();
    _pendingConsultations.clear();
    _latestConsultations.clear();
  }

  String toJsonLines() => _memorySink.toJsonLines();

  MaterialOperationAttemptHandle startMaterialOperation({
    ExperimentCondition condition = ExperimentCondition.a,
    required ExperimentOperationType operationType,
  }) {
    final attemptId = _generateOpaqueToken('att');
    final startedAtMs = _safeNowMs();

    emitValidated(
      ExperimentEvent(
        eventName: ExperimentEventName.materialOperationStarted,
        experimentId: TrackedExperimentId.ec01,
        questionId: TrackedExperimentId.ec01.questionId,
        metricIds: TrackedExperimentId.ec01.metricIds,
        platform: ExperimentPlatform.mobile,
        condition: condition,
        timestamp: _safeUtcTimestamp(),
        sessionId: sessionId,
        attemptId: attemptId,
        outcome: ExperimentOutcome.started,
        operationType: operationType,
      ),
    );

    return MaterialOperationAttemptHandle._(
      attemptId: attemptId,
      onComplete: () {
        emitValidated(
          ExperimentEvent(
            eventName: ExperimentEventName.materialOperationCompleted,
            experimentId: TrackedExperimentId.ec01,
            questionId: TrackedExperimentId.ec01.questionId,
            metricIds: TrackedExperimentId.ec01.metricIds,
            platform: ExperimentPlatform.mobile,
            condition: condition,
            timestamp: _safeUtcTimestamp(),
            sessionId: sessionId,
            attemptId: attemptId,
            outcome: ExperimentOutcome.completed,
            durationMs: _elapsedMs(startedAtMs),
            operationType: operationType,
          ),
        );
      },
      onFailValidation: (errorCategory) {
        emitValidated(
          ExperimentEvent(
            eventName: ExperimentEventName.materialOperationFailed,
            experimentId: TrackedExperimentId.ec01,
            questionId: TrackedExperimentId.ec01.questionId,
            metricIds: TrackedExperimentId.ec01.metricIds,
            platform: ExperimentPlatform.mobile,
            condition: condition,
            timestamp: _safeUtcTimestamp(),
            sessionId: sessionId,
            attemptId: attemptId,
            outcome: ExperimentOutcome.validationFailed,
            durationMs: _elapsedMs(startedAtMs),
            operationType: operationType,
            errorCategory: errorCategory,
          ),
        );
      },
      onFailApi: (errorCategory) {
        emitValidated(
          ExperimentEvent(
            eventName: ExperimentEventName.materialOperationFailed,
            experimentId: TrackedExperimentId.ec01,
            questionId: TrackedExperimentId.ec01.questionId,
            metricIds: TrackedExperimentId.ec01.metricIds,
            platform: ExperimentPlatform.mobile,
            condition: condition,
            timestamp: _safeUtcTimestamp(),
            sessionId: sessionId,
            attemptId: attemptId,
            outcome: ExperimentOutcome.apiFailed,
            durationMs: _elapsedMs(startedAtMs),
            operationType: operationType,
            errorCategory: errorCategory,
          ),
        );
      },
    );
  }

  ProjectConsultationAttemptHandle startProjectConsultation({
    ExperimentCondition condition = ExperimentCondition.a,
  }) {
    final attemptId = _generateOpaqueToken('att');
    final startedAtMs = _safeNowMs();

    emitValidated(
      ExperimentEvent(
        eventName: ExperimentEventName.projectConsultationStarted,
        experimentId: TrackedExperimentId.ec04,
        questionId: TrackedExperimentId.ec04.questionId,
        metricIds: TrackedExperimentId.ec04.metricIds,
        platform: ExperimentPlatform.mobile,
        condition: condition,
        timestamp: _safeUtcTimestamp(),
        sessionId: sessionId,
        attemptId: attemptId,
        outcome: ExperimentOutcome.started,
      ),
    );

    _latestConsultations[condition] = _ConsultationRecord(
      attemptId: attemptId,
      startedAtMs: startedAtMs,
    );

    late final ProjectConsultationAttemptHandle handle;
    handle = ProjectConsultationAttemptHandle._(
      attemptId: attemptId,
      condition: condition,
      onLoaded: () {
        if (_pendingConsultations[condition]?.attemptId == attemptId) {
          _pendingConsultations.remove(condition);
        }
        emitValidated(
          ExperimentEvent(
            eventName: ExperimentEventName.projectConsultationLoaded,
            experimentId: TrackedExperimentId.ec04,
            questionId: TrackedExperimentId.ec04.questionId,
            metricIds: TrackedExperimentId.ec04.metricIds,
            platform: ExperimentPlatform.mobile,
            condition: condition,
            timestamp: _safeUtcTimestamp(),
            sessionId: sessionId,
            attemptId: attemptId,
            outcome: ExperimentOutcome.loaded,
            durationMs: _elapsedMs(startedAtMs),
          ),
        );
      },
      onFailApi: (errorCategory) {
        if (_pendingConsultations[condition]?.attemptId == attemptId) {
          _pendingConsultations.remove(condition);
        }
        emitValidated(
          ExperimentEvent(
            eventName: ExperimentEventName.projectConsultationFailed,
            experimentId: TrackedExperimentId.ec04,
            questionId: TrackedExperimentId.ec04.questionId,
            metricIds: TrackedExperimentId.ec04.metricIds,
            platform: ExperimentPlatform.mobile,
            condition: condition,
            timestamp: _safeUtcTimestamp(),
            sessionId: sessionId,
            attemptId: attemptId,
            outcome: ExperimentOutcome.apiFailed,
            durationMs: _elapsedMs(startedAtMs),
            errorCategory: errorCategory,
          ),
        );
      },
      onOpenReport: () {
        final latest = _latestConsultations[condition];
        if (latest != null && latest.attemptId == attemptId) {
          latest.reportOpened = true;
        }
        emitValidated(
          ExperimentEvent(
            eventName: ExperimentEventName.projectReportOpened,
            experimentId: TrackedExperimentId.ec04,
            questionId: TrackedExperimentId.ec04.questionId,
            metricIds: TrackedExperimentId.ec04.metricIds,
            platform: ExperimentPlatform.mobile,
            condition: condition,
            timestamp: _safeUtcTimestamp(),
            sessionId: sessionId,
            attemptId: attemptId,
            outcome: ExperimentOutcome.opened,
            durationMs: _elapsedMs(startedAtMs),
          ),
        );
      },
    );

    _pendingConsultations[condition] = handle;
    return handle;
  }

  ProjectConsultationAttemptHandle acquireProjectConsultation({
    ExperimentCondition condition = ExperimentCondition.a,
    bool forceNew = false,
  }) {
    if (!forceNew) {
      final existing = _pendingConsultations[condition];
      if (existing != null) {
        return existing;
      }
    }
    return startProjectConsultation(condition: condition);
  }

  void openProjectReportFromNavigation({
    ExperimentCondition condition = ExperimentCondition.a,
  }) {
    final pending = _pendingConsultations[condition];
    if (pending != null) {
      pending.openReportWhenLoaded();
      return;
    }
    final latest = _latestConsultations[condition];
    if (latest != null) {
      recordProjectReportOpened(condition: condition);
      return;
    }
    acquireProjectConsultation(
      condition: condition,
      forceNew: false,
    ).openReportWhenLoaded();
  }

  void recordProjectReportOpened({
    ExperimentCondition condition = ExperimentCondition.a,
  }) {
    final pending = _pendingConsultations[condition];
    if (pending != null) {
      pending.openReportWhenLoaded();
      return;
    }

    final latest = _latestConsultations[condition];
    if (latest != null) {
      if (latest.reportOpened) {
        return;
      }
      latest.reportOpened = true;
      emitValidated(
        ExperimentEvent(
          eventName: ExperimentEventName.projectReportOpened,
          experimentId: TrackedExperimentId.ec04,
          questionId: TrackedExperimentId.ec04.questionId,
          metricIds: TrackedExperimentId.ec04.metricIds,
          platform: ExperimentPlatform.mobile,
          condition: condition,
          timestamp: _safeUtcTimestamp(),
          sessionId: sessionId,
          attemptId: latest.attemptId,
          outcome: ExperimentOutcome.opened,
          durationMs: _elapsedMs(latest.startedAtMs),
        ),
      );
      return;
    }

    final attemptId = _generateOpaqueToken('att');
    _latestConsultations[condition] = _ConsultationRecord(
      attemptId: attemptId,
      startedAtMs: _safeNowMs(),
      reportOpened: true,
    );
    emitValidated(
      ExperimentEvent(
        eventName: ExperimentEventName.projectReportOpened,
        experimentId: TrackedExperimentId.ec04,
        questionId: TrackedExperimentId.ec04.questionId,
        metricIds: TrackedExperimentId.ec04.metricIds,
        platform: ExperimentPlatform.mobile,
        condition: condition,
        timestamp: _safeUtcTimestamp(),
        sessionId: sessionId,
        attemptId: attemptId,
        outcome: ExperimentOutcome.opened,
        durationMs: 0,
      ),
    );
  }

  bool emitValidated(ExperimentEvent event) {
    if (!_enabled) {
      _noopSink.emit(event);
      return false;
    }
    final validation = event.validate();
    if (!validation.valid) {
      return false;
    }
    try {
      _memorySink.emit(event);
    } on Object {
      // Never propagate sink errors to mobile UI flows.
    }
    final custom = _customSink;
    if (custom != null) {
      try {
        custom.emit(event);
      } on Object {
        // Sink failures must never interrupt business operations.
      }
    }
    final debug = _debugSink;
    if (debug != null) {
      try {
        debug.emit(event);
      } on Object {
        // Ignore debug sink errors.
      }
    }
    return true;
  }

  static ExperimentErrorCategory classifyError(Object error) {
    if (error is ApiError) {
      if (error.code == 'INSUFFICIENT_STOCK') {
        return ExperimentErrorCategory.insufficientStock;
      }
      if (error.code == 'VALIDATION_ERROR') {
        return ExperimentErrorCategory.validation;
      }
      if (error.code == 'FORBIDDEN' || error.code == 'UNAUTHORIZED') {
        return ExperimentErrorCategory.unauthorized;
      }
      if (error.code == 'NOT_FOUND' || error.code == 'PROJECT_NOT_FOUND') {
        return ExperimentErrorCategory.notFound;
      }
      if (error.code == 'NETWORK_ERROR') {
        return ExperimentErrorCategory.network;
      }
      switch (error.statusCode) {
        case 0:
          return ExperimentErrorCategory.network;
        case 400:
        case 422:
          return ExperimentErrorCategory.validation;
        case 401:
        case 403:
          return ExperimentErrorCategory.unauthorized;
        case 404:
          return ExperimentErrorCategory.notFound;
        case 409:
          return ExperimentErrorCategory.conflict;
        default:
          return ExperimentErrorCategory.apiError;
      }
    }
    return ExperimentErrorCategory.apiError;
  }

  int _safeNowMs() {
    try {
      final value = _monotonicMilliseconds();
      return value >= 0 ? value : 0;
    } on Object {
      return 0;
    }
  }

  int _elapsedMs(int startedAtMs) {
    final diff = _safeNowMs() - startedAtMs;
    return diff >= 0 ? diff : 0;
  }

  String _safeUtcTimestamp() {
    try {
      final raw = _utcTimestamp();
      return raw.endsWith('Z')
          ? raw
          : DateTime.now().toUtc().toIso8601String();
    } on Object {
      return DateTime.now().toUtc().toIso8601String();
    }
  }

  static String _generateOpaqueToken(String prefix) {
    final rng = Random.secure();
    final hex = List<int>.generate(8, (_) => rng.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '$prefix-$hex';
  }
}
