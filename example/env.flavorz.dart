/// Auto Generated. Do Not Edit ⚠️
///
/// For more info. refer to the README.md file https://pub.dev/packages/flavorz
///

/// This is the key of the list of environments(flavors) inside the .flavorz.json file
const environmentsJsonKey = 'environments';

/// This is the key from the .flavorz.json file that specify which environment is the default
const defaultEnvironmentJsonKey = 'default';

/// This will holds the name of the environment that we want to run,
/// using `flutter run --dart-define="env=dev"`.
/// if we run without specifying the env variable, then the default value inside json file will be used.
const environmentToRun = String.fromEnvironment('env');

class Environment {
  final String _name;
  final String? versionNumber;

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
  /// It will initialize the environment based on the [environmentToRun]
  static Future<void> init() async {
    final content = jsonConfigFileContent;
    List<Environment> environments = _loadAllEnvironments(content);
    String envToRun = environmentToRun;

    if (envToRun.isEmpty) {
      if (content.keys.contains(defaultEnvironmentJsonKey)) {
        final defaultEnvironment = content[defaultEnvironmentJsonKey] as String;
        envToRun = defaultEnvironment;
      } else {
        throw Exception(
            'The $defaultEnvironmentJsonKey key is not defined inside the .flavorz.json file');
      }
    }

    final matchedEnvironments = environments
        .where((env) => env._name.toLowerCase() == envToRun.toLowerCase());
    if (matchedEnvironments.isNotEmpty) {
      _this = matchedEnvironments.first;
    } else {
      throw Exception(
          'The environment $envToRun does not exist in .flavorz.json file');
    }
  }

  static List<Environment> _loadAllEnvironments(Map<String, dynamic> json) {
    /// if the [environmentsJsonKey] is not found inside the .flavorz.json file
    if (!json.keys.contains(environmentsJsonKey)) {
      throw Exception(
          'The $environmentsJsonKey key is not defined inside the .flavorz.json file');
    }
    final environments = json[environmentsJsonKey] as List;
    return environments
        .map((map) => Environment._fromMap(map as Map<String, dynamic>))
        .toList();
  }

  factory Environment._fromMap(Map<String, dynamic> map) {
    return Environment._(
      map["_name"] as String,
      map["versionNumber"] as String?,
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

/// This is the content of the .flavorz.json file
const jsonConfigFileContent = {
    "default": "dev",
    "environments": [
        {
            "_name": "dev",
            "versionNumber": "Dev 1.0.0"
        },
        {
            "_name": "local",
            "versionNumber": "Local 1.0.1"
        }
    ]
};
