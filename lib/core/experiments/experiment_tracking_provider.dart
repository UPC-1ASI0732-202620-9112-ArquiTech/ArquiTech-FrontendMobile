import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'experiment_tracker.dart';

final experimentTrackerProvider = Provider<ExperimentTracker>((ref) {
  return ExperimentTracker();
});
