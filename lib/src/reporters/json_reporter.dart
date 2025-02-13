import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import '../models/context_message.dart';
import '../models/file_report.dart';
import '../models/issue.dart';
import '../models/metric_value.dart';
import '../models/replacement.dart';
import '../models/report.dart';
import 'reporter.dart';

/// Machine-readable report in JSON format
@immutable
class JsonReporter implements Reporter {
  final IOSink _output;

  static const _formatVersion = 2;

  const JsonReporter(this._output);

  @override
  Future<void> report(Iterable<FileReport> records) async {
    if (records.isEmpty) {
      return;
    }

    final nowTime = DateTime.now();
    final reportTime = DateTime(
      nowTime.year,
      nowTime.month,
      nowTime.day,
      nowTime.hour,
      nowTime.minute,
      nowTime.second,
    );

    final encodedReport = json.encode({
      'formatVersion': _formatVersion,
      'timestamp': reportTime.toString(),
      'records': records.map(_analysisRecordToJson).toList(),
    });

    _output.write(encodedReport);
  }

  Map<String, Object> _analysisRecordToJson(FileReport report) {
    final sourceContent = File(report.path).readAsStringSync();

    return {
      'path': report.relativePath,
      'classes': _reportReports(report.classes),
      'functions': _reportReports(report.functions),
      'issues': _reportIssues(report.issues, sourceContent),
      'antiPatternCases': _reportIssues(report.antiPatternCases, sourceContent),
    };
  }

  Map<String, Map<String, Object>> _reportReports(
    Map<String, Report> reports,
  ) =>
      reports.map((key, value) => MapEntry(key, {
            'codeSpan': _reportSourceSpan(value.location),
            'metrics': _reportMetrics(value.metrics),
          }));

  List<Map<String, Object>> _reportIssues(
    Iterable<Issue> issues,
    String source,
  ) =>
      issues.map((issue) {
        final suggestion = issue.suggestion;
        final verboseMessage = issue.verboseMessage;

        return {
          'ruleId': issue.ruleId,
          'documentation': issue.documentation.toString(),
          'codeSpan': _reportSourceSpan(issue.location),
          'severity': issue.severity.toString(),
          'message': issue.message,
          if (verboseMessage != null && verboseMessage.isNotEmpty)
            'verboseMessage': verboseMessage,
          if (suggestion != null) 'suggestion': _reportReplacement(suggestion),
        };
      }).toList();

  Map<String, Object> _reportSourceSpan(SourceSpan location) => {
        'start': _reportSourceLocation(location.start),
        'end': _reportSourceLocation(location.end),
        'text': location.text,
      };

  List<Map<String, Object>> _reportMetrics(
    Iterable<MetricValue<num>> metrics,
  ) =>
      metrics.map((metric) {
        final recommendation = metric.recommendation;

        return {
          'metricsId': metric.metricsId,
          'value': metric.value,
          'level': metric.level.toString(),
          'comment': metric.comment,
          if (recommendation != null) 'recommendation': recommendation,
          'context': _reportContextMessages(metric.context),
        };
      }).toList();

  Map<String, Object> _reportSourceLocation(SourceLocation location) => {
        'offset': location.offset,
        'line': location.line,
        'column': location.column,
      };

  List<Map<String, Object>> _reportContextMessages(
    Iterable<ContextMessage> messages,
  ) =>
      messages
          .map((message) => {
                'message': message.message,
                'codeSpan': _reportSourceSpan(message.location),
              })
          .toList();

  Map<String, String> _reportReplacement(Replacement replacement) => {
        'comment': replacement.comment,
        'replacement': replacement.replacement,
      };
}
