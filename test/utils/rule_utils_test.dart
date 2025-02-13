@TestOn('vm')
import 'package:dart_code_metrics/src/models/replacement.dart';
import 'package:dart_code_metrics/src/models/severity.dart';
import 'package:dart_code_metrics/src/rules/rule.dart';
import 'package:dart_code_metrics/src/utils/rule_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

class RuleMock extends Mock implements Rule {}

void main() {
  group('Rule utils', () {
    test(
      'createIssue returns information issue based on passed information',
      () {
        const id = 'rule-id';
        final documentationUrl = Uri.parse(
          'https://dart-code-checker.github.io/dart-code-metrics/rules/rule-id.html',
        );
        const severity = Severity.none;

        final codeUrl = Uri.parse('file://source.dart');
        final codeLocation = SourceSpan(
          SourceLocation(0, sourceUrl: codeUrl),
          SourceLocation(4, sourceUrl: codeUrl),
          'code',
        );

        const message = 'error message';

        const verboseMessage = 'information how to fix a error';

        const replacement =
            Replacement(comment: 'comment', replacement: 'new code');

        final rule = RuleMock();
        when(() => rule.id).thenReturn(id);
        when(() => rule.severity).thenReturn(severity);

        final issue = createIssue(
          rule: rule,
          location: codeLocation,
          message: message,
          verboseMessage: verboseMessage,
          replacement: replacement,
        );

        expect(issue.ruleId, equals(id));
        expect(issue.documentation, equals(documentationUrl));
        expect(issue.location, equals(codeLocation));
        expect(issue.severity, equals(severity));
        expect(issue.message, equals(message));
        expect(issue.verboseMessage, equals(verboseMessage));
        expect(issue.suggestion, equals(replacement));
      },
    );
    test('documentation returns the url with documentation', () {
      const ruleId1 = 'rule-id-1';
      const ruleId2 = 'rule-id-2';

      expect(
        documentation(ruleId1).toString(),
        equals(
          'https://dart-code-checker.github.io/dart-code-metrics/rules/$ruleId1.html',
        ),
      );
      expect(
        documentation(ruleId2).pathSegments.last,
        equals('$ruleId2.html'),
      );
    });

    test('readSeverity returns a Severity from Map based config', () {
      expect(
        [
          {'severity': 'ERROR'},
          {'severity': 'wArnInG'},
          {'severity': 'performance'},
          {'severity': ''},
          {'': null},
        ].map((data) => readSeverity(data, Severity.style)),
        equals([
          Severity.error,
          Severity.warning,
          Severity.performance,
          Severity.none,
          Severity.style,
        ]),
      );
    });
  });
}
