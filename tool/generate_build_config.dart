import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

void main() async {
  log('Generating build config...');

  // 1. Get App Version from pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  final pubspecContent = await pubspecFile.readAsString();
  final pubspec = loadYaml(pubspecContent);
  final appVersion = pubspec['version'];

  // 2. Get Current Date
  final now = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final buildDate = formatter.format(now);

  // 3. Fetch API Version
  // Note: hardcoding the URL here as per the plan/existing code knowledge
  // Ideally this could be shared but for a tool script it's safer to be standalone or read from a config
  final apiVersionUrl = 'https://app.sharpcutae.com/api/version';
  String apiVersion = 'Unknown';

  try {
    final dio = Dio();
    final response = await dio.get(apiVersionUrl);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data.containsKey('api_version')) {
        apiVersion = data['api_version'].toString();
        log("api ${apiVersion}");
      }
    }
  } catch (e) {
    log('Failed to fetch API version: $e');

    apiVersion = 'ErrorFetching';
  }

  // 4. Get Git Commit Hash
  String gitCommit = 'Unknown';
  try {
    final result = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
    if (result.exitCode == 0) {
      gitCommit = result.stdout.toString().trim();
    }
  } catch (e) {
    log('Failed to fetch git commit: $e');
  }

  // 5. Generate lib/build_config.dart
  final outputFile = File('lib/build_config.dart');
  final content =
      '''
// GENERATED CODE - DO NOT MODIFY BY HAND

class BuildConfig {
  static const String buildDate = '$buildDate';
  static const String appVersionAtBuild = '$appVersion';
  static const String apiVersionAtBuild = '$apiVersion';
  static const String gitCommit = '$gitCommit';
}
''';

  await outputFile.writeAsString(content);
  log('Build config generated successfully.');
}
