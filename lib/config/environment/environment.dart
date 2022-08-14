import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:flavours_template/config/environment/env_type.dart';
import 'package:flutter/services.dart';

const String _cofigFilePath = "config/env_config.json";

class Environment {
  final int _id;
  final String baseUrl;
  final String versionNumber;

  /// `type` is an `enum`, to be used for comparison, instead of id & name
  EnvironmentType get type => EnvironmentType.fromId(_id);

  Environment._({
    required int id,
    required this.baseUrl,
    required this.versionNumber,
  }) : _id = id;
  static Environment? _this;

  /// This factory is an access point from anywhere in the application.
  /// And it will always return the same instance, since it is a singleton.
  factory Environment() {
    if (_this == null) {
      throw Exception(
          "You must call 'await Environment.init()' at the start of the application");
    }
    return _this!;
  }

  /// Must be called at the start of the application.
  /// It will initialize the environment based on the `env` attribute defined in `pubspec.yaml`
  static Future<void> init() async {
    // Load all environments from 'env_config.json' file
    List<Environment> environments = await _loadAllEnvironments(_cofigFilePath);
    // Load the id of environment that we want to use, from pubspec.yaml
    String fileAsString = await rootBundle.loadString('pubspec.yaml');
    Map pubspec = loadYaml(fileAsString);
    int envId = pubspec['env'];
    final matchedEnvironments = environments.where((env) => env._id == envId);
    if (matchedEnvironments.isNotEmpty) {
      _this = matchedEnvironments.first;
    } else {
      throw Exception(
          'The environment id in pubspec.yaml does not match any id in env_config.json');
    }
  }

  static Future<List<Environment>> _loadAllEnvironments(String filePath) async {
    final json = await rootBundle.loadString(filePath);
    Map<String, dynamic> envConfig = jsonDecode(json);
    final environments = envConfig['environments'] as List;
    return environments
        .map((map) => Environment._fromMap(map as Map<String, dynamic>))
        .toList();
  }

  factory Environment._fromMap(Map<String, dynamic> map) {
    return Environment._(
      id: map['id'] as int,
      baseUrl: map['base_url'] as String,
      versionNumber: map['version_number'] as String,
    );
  }
}
