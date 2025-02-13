import 'package:analyzer/dart/analysis/results.dart';

import '../models/issue.dart';
import '../models/rule_documentation.dart';
import '../models/severity.dart';

/// An interface to communicate with the rules
///
/// All rules must implement from this interface.
abstract class Rule {
  /// The id of the rule.
  final String id;

  /// The documentation associated with the rule
  final RuleDocumentation documentation;

  /// The severity of issues emitted by the rule
  final Severity severity;

  /// Initialize a newly created [Rule].
  const Rule({
    required this.id,
    required this.documentation,
    required this.severity,
  });

  /// Returns [Iterable] with [Issue]'s detected while check the passed [source]
  Iterable<Issue> check(ResolvedUnitResult source);
}
