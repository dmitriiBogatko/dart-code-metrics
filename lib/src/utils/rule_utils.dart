import 'package:source_span/source_span.dart';

import '../models/issue.dart';
import '../models/replacement.dart';
import '../models/severity.dart';
import '../obsoleted/rules/obsolete_rule.dart';
import '../rules/rule.dart';

/// Creates a new [Issue] found by [rule] in the [location] with [message] or
/// with [verboseMessage] describing the problem and with information how to fix
/// this one ([replacement]).
Issue createIssue({
  required Rule rule,
  required SourceSpan location,
  required String message,
  String? verboseMessage,
  Replacement? replacement,
}) =>
    Issue(
      ruleId: rule.id,
      documentation:
          rule is ObsoleteRule ? rule.documentationUrl : documentation(rule.id),
      location: location,
      severity: rule.severity,
      message: message,
      verboseMessage: verboseMessage,
      suggestion: replacement,
    );

/// Returns the url of a page containing documentation associated with [ruleId]
Uri documentation(String ruleId) => Uri(
      scheme: 'https',
      host: 'dart-code-checker.github.io',
      pathSegments: ['dart-code-metrics', 'rules', '$ruleId.html'],
    );

/// Returns the [Severity] from map based [config] otherwise [defaultValue]
Severity readSeverity(Map<String, Object?> config, Severity defaultValue) =>
    Severity.fromString(config['severity'] as String?) ?? defaultValue;
