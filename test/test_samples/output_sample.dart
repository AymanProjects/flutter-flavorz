/// Auto Generated. Do Not Edit ⚠️
///
/// For more info. refer to the README.md file

import 'dart:convert';
import 'dart:io';

/// Path to the json file that holds the configurations of the environments
const pathToJsonConfigFile = 'lib/env_config.flavorz.json';

/// The key of the list of environments(flavors) inside the json file
const environmentsJsonKey = 'environments';

/// The key from the json file that holds the id of the environment(flavor) that we wish to run.
const environmentToRunJsonKey = 'environmentToRun';

class Environment {
  final String _name;
  final String versionNumber;

  Environment._(
    this._name,
    this.versionNumber,
  );

  /// `type` is an `enum`, to be used for comparison, instead of hardcoding the name
  EnvironmentType get type => EnvironmentType.fromString(_name);

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
  /// It will initialize the environment based on the `environmentToRun` attribute defined in the json file
  static Future<void> init() async {
    final content = await File(pathToJsonConfigFile).readAsString();
    Map<String, dynamic> json = jsonDecode(content);
    List<Environment> environments = _loadAllEnvironments(json);
    final environmnetToRunId = json[environmentToRunJsonKey] as String;
    final matchedEnvironments =
        environments.where((env) => env._name == environmnetToRunId);
    if (matchedEnvironments.isNotEmpty) {
      _this = matchedEnvironments.first;
    } else {
      throw Exception(
          'The environment id in pubspec.yaml does not match any id in env_config.json');
    }
  }

  static List<Environment> _loadAllEnvironments(Map<String, dynamic> json) {
    final environments = json[environmentsJsonKey] as List;
    return environments
        .map((map) => Environment._fromMap(map as Map<String, dynamic>))
        .toList();
  }

  factory Environment._fromMap(Map<String, dynamic> map) {
    return Environment._(
      map["_name"] as String,
      map["versionNumber"] as String,
    );
  }

  @override
  String toString() {
    return '{"_name": $_name,"versionNumber": $versionNumber}';
  }
}

enum EnvironmentType {
  dev,
  local;

  factory EnvironmentType.fromString(String name) {
    return values.firstWhere((EnvironmentType e) => e.name == name);
  }
}
