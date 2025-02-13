import 'package:meta/meta.dart';

import 'issue.dart';
import 'report.dart';

/// Represents the metrics report collected for a file.
@immutable
class FileReport {
  /// The path to the target file.
  final String path;

  /// The path to the target file relative to the package root.
  final String relativePath;

  /// The all classes reports in the target file.
  final Map<String, Report> classes;

  /// The all functions / methods reports in the target file.
  final Map<String, Report> functions;

  /// The issues detected in the target file.
  final Iterable<Issue> issues;

  /// The anti-pattern cases detected in the target file.
  final Iterable<Issue> antiPatternCases;

  const FileReport({
    required this.path,
    required this.relativePath,
    required this.classes,
    required this.functions,
    required this.issues,
    required this.antiPatternCases,
  });
}
