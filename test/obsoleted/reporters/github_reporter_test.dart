@TestOn('vm')
import 'dart:io';

import 'package:dart_code_metrics/src/models/file_report.dart';
import 'package:dart_code_metrics/src/models/issue.dart';
import 'package:dart_code_metrics/src/models/replacement.dart';
import 'package:dart_code_metrics/src/models/report.dart';
import 'package:dart_code_metrics/src/models/severity.dart';
import 'package:dart_code_metrics/src/obsoleted/reporters/github/github_reporter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

class IOSinkMock extends Mock implements IOSink {}

void main() {
  group('GitHubReporter.report report about', () {
    // ignore: close_sinks
    late IOSinkMock output;
    const fullPath = '/home/developer/work/project/example.dart';

    setUp(() {
      output = IOSinkMock();
    });

    test('files without any records', () async {
      await GitHubReporter(output).report([]);

      verifyNever(() => output.writeln(any()));
    });

    test('with design issues', () async {
      final records = [
        FileReport(
          path: fullPath,
          relativePath: 'example.dart',
          classes: Map.unmodifiable(<String, Report>{}),
          functions: Map.unmodifiable(<String, Report>{}),
          issues: const [],
          antiPatternCases: [
            Issue(
              ruleId: 'patternId1',
              documentation: Uri.parse('https://docu.edu/patternId1.html'),
              location: SourceSpanBase(
                SourceLocation(
                  1,
                  sourceUrl: Uri.parse(fullPath),
                  line: 2,
                  column: 3,
                ),
                SourceLocation(6, sourceUrl: Uri.parse(fullPath)),
                'issue',
              ),
              severity: Severity.none,
              message: 'first issue message',
              verboseMessage: 'recommendation',
            ),
          ],
        ),
      ];

      await GitHubReporter(output).report(records);

      expect(
        verify(() => output.writeln(captureAny())).captured.cast<String>(),
        equals([
          '::warning file=/home/developer/work/project/example.dart,line=2,col=3::first issue message',
        ]),
      );
    });

    test('with style severity issues', () async {
      final records = [
        FileReport(
          path: fullPath,
          relativePath: 'example.dart',
          classes: Map.unmodifiable(<String, Report>{}),
          functions: Map.unmodifiable(<String, Report>{}),
          issues: [
            Issue(
              ruleId: 'ruleId1',
              documentation: Uri.parse('https://docu.edu/ruleId1.html'),
              severity: Severity.style,
              location: SourceSpanBase(
                SourceLocation(
                  1,
                  sourceUrl: Uri.parse(fullPath),
                  line: 2,
                  column: 3,
                ),
                SourceLocation(6, sourceUrl: Uri.parse(fullPath)),
                'issue',
              ),
              message: 'first issue message',
              suggestion: const Replacement(
                comment: 'correction comment',
                replacement: 'correction',
              ),
            ),
            Issue(
              ruleId: 'ruleId2',
              documentation: Uri.parse('https://docu.edu/ruleId2.html'),
              severity: Severity.error,
              location: SourceSpanBase(
                SourceLocation(
                  11,
                  sourceUrl: Uri.parse(fullPath),
                  line: 4,
                  column: 3,
                ),
                SourceLocation(17, sourceUrl: Uri.parse(fullPath)),
                'issue2',
              ),
              message: 'second issue message',
              suggestion: const Replacement(
                comment: 'correction comment',
                replacement: 'correction',
              ),
            ),
          ],
          antiPatternCases: const [],
        ),
      ];

      await GitHubReporter(output).report(records);

      expect(
        verify(() => output.writeln(captureAny())).captured.cast<String>(),
        equals([
          '::warning file=/home/developer/work/project/example.dart,line=2,col=3::first issue message',
          '::error file=/home/developer/work/project/example.dart,line=4,col=3::second issue message',
        ]),
      );
    });
  });
}
