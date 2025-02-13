import 'package:meta/meta.dart';

import '../utils/analysis_options_utils.dart';
import 'analysis_options.dart';

/// Class representing config
@immutable
class Config {
  final Iterable<String> excludePatterns;
  final Iterable<String> excludeForMetricsPatterns;
  final Map<String, Object> metrics;
  final Map<String, Map<String, Object>> rules;
  final Map<String, Map<String, Object>> antiPatterns;

  const Config({
    required this.excludePatterns,
    required this.excludeForMetricsPatterns,
    required this.metrics,
    required this.rules,
    required this.antiPatterns,
  });

  factory Config.fromAnalysisOptions(AnalysisOptions options) {
    const _rootKey = 'dart_code_metrics';

    return Config(
      excludePatterns: options.readIterableOfString(['analyzer', 'exclude']),
      excludeForMetricsPatterns:
          options.readIterableOfString([_rootKey, 'metrics-exclude']),
      metrics: options.readMap([_rootKey, 'metrics']),
      rules: options.readMapOfMap([_rootKey, 'rules']),
      antiPatterns: options.readMapOfMap([_rootKey, 'anti-patterns']),
    );
  }

  Config merge(Config overrides) => Config(
        excludePatterns: {...excludePatterns, ...overrides.excludePatterns},
        excludeForMetricsPatterns: {
          ...excludeForMetricsPatterns,
          ...overrides.excludeForMetricsPatterns,
        },
        metrics: mergeMaps(defaults: metrics, overrides: overrides.metrics),
        rules: mergeMaps(defaults: rules, overrides: overrides.rules)
            .cast<String, Map<String, Object>>(),
        antiPatterns:
            mergeMaps(defaults: antiPatterns, overrides: overrides.antiPatterns)
                .cast<String, Map<String, Object>>(),
      );
}
