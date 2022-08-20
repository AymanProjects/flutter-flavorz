import 'dart:convert';
import 'package:build/build.dart';

/// Input file must end with .json
const inputExtension = ".flavorz.json";

/// Output file must end with .dart
const outputExtension = ".flavorz.dart";

/// The key of the list of environments(flavors) inside the json file
const environmentsJsonKey = "environments";

/// This is the key from the .flavorz.json file that specify which environment is the default
const defaultEnvironmentJsonKey = "default";

/// The `FlavorBuilder` is a code gerenator that will look for files
/// that end with [inputExtension] inside the lib folder, and consturct a new dart file that will
/// contain `Environment` class, that will be used across the app.
///
/// The generated file will have the same name & path of the input file but with this extension: [outputExtension].
///
/// For more info. refer to the README.md file
class FlavorBuilder implements Builder {
  /// Specify the input & output file extensions
  @override
  final buildExtensions = const {
    inputExtension: [outputExtension]
  };

  /// This build function will be called for each file that ends with [inputExtension].
  /// In our case, there should be only one file.
  @override
  Future<void> build(BuildStep buildStep) async {
    /// Store the input file path
    final inputFileId = buildStep.inputId;

    final inputContent = await buildStep.readAsString(inputFileId);

    /// Generate the `Environment` class
    final outputContent =
        generateEnvironmentClass(inputContent, inputFileId.path);

    /// The output file will have the same path & name of the input file
    /// but with [outputExtension] instead of [inputExtension].
    final pathWithOutExtension = inputFileId.path.split('.').first;
    final outputFileId = AssetId(inputFileId.package, pathWithOutExtension)
        .addExtension(outputExtension);

    /// Finally, create & write to the output file
    await buildStep.writeAsString(outputFileId, outputContent);
  }

  /// This will gerenate the Environment class based on the attributes inside the json file
  String generateEnvironmentClass(
    String inputContent,
    String inputFileId,
  ) {
    /// Since all elements in the `flavors` list are identical in terms of structure,
    /// we will just grab the first element to generate the `Environment` class from it.
    final flavors = jsonDecode(inputContent)[environmentsJsonKey] as List;

    return '''
/// Auto Generated. Do Not Edit ⚠️
///
/// For more info. refer to the README.md file https://pub.dev/packages/flavorz
///

/// This is the key of the list of environments(flavors) inside the .flavorz.json file
const environmentsJsonKey = '$environmentsJsonKey';

/// This is the key from the .flavorz.json file that specify which environment is the default
const defaultEnvironmentJsonKey = '$defaultEnvironmentJsonKey';

/// This will holds the name of the environment that we want to run,
/// using `flutter run --dart-define="env=dev"`.
/// if we run without specifying the env variable, then the default value inside json file will be used.
const environmentToRun = String.fromEnvironment('env');

class Environment {
${_generateAttributes(flavors)}
  ${_generatePrivateConstructor(flavors)}

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
            'The \$defaultEnvironmentJsonKey key is not defined inside the .flavorz.json file');
      }
    }

    final matchedEnvironments = environments
        .where((env) => env._name.toLowerCase() == envToRun.toLowerCase());
    if (matchedEnvironments.isNotEmpty) {
      _this = matchedEnvironments.first;
    } else {
      throw Exception(
          'The environment \$envToRun does not exist in .flavorz.json file');
    }
  }

  static List<Environment> _loadAllEnvironments(Map<String, dynamic> json) {
    /// if the [environmentsJsonKey] is not found inside the .flavorz.json file
    if (!json.keys.contains(environmentsJsonKey)) {
      throw Exception(
          'The \$environmentsJsonKey key is not defined inside the .flavorz.json file');
    }
    final environments = json[environmentsJsonKey] as List;
    return environments
        .map((map) => Environment._fromMap(map as Map<String, dynamic>))
        .toList();
  }

  ${_generateFromMapFuntion(flavors)}

  ${_generateToString(flavors)}
}

${_generateEnumTypes(flavors)}

/// This is the content of the .flavorz.json file
const jsonConfigFileContent = $inputContent;
''';
  }

  /// Will go over all the attributes in the json file and make the same attributes in the Environment class
  String _generateAttributes(List flavors) {
    String attributes = '';
    final entries = _getAllPossibleAttributes(flavors);
    for (var entry in entries) {
      if (entry.key == "_name") {
        attributes += '  final ${entry.value.runtimeType} ${entry.key};\n';
      } else {
        attributes += '  final ${entry.value.runtimeType}? ${entry.key};\n';
      }
    }
    return attributes;
  }

  /// Will generate a private constructor based on the attributes in the json file
  String _generatePrivateConstructor(List flavors) {
    String attributes = "";
    final entries = _getAllPossibleAttributes(flavors);
    for (int i = 0; i < entries.length; i++) {
      attributes += '    this.${entries[i].key},';
      if (i != entries.length - 1) {
        attributes += '\n';
      }
    }
    return '''
Environment._(
$attributes
  );''';
  }

  /// Will generate the `fromMap` function to prase json into object of type `Environment`
  String _generateFromMapFuntion(List flavors) {
    String attributes = '';
    final entries = _getAllPossibleAttributes(flavors);
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].key == "_name") {
        attributes +=
            '      map["${entries[i].key}"] as ${entries[i].value.runtimeType},';
      } else {
        attributes +=
            '      map["${entries[i].key}"] as ${entries[i].value.runtimeType}?,';
      }
      if (i != entries.length - 1) {
        attributes += '\n';
      }
    }
    return '''
factory Environment._fromMap(Map<String, dynamic> map) {
    return Environment._(
$attributes
    );
  }''';
  }

  /// Will generate enum types for each environment in the json file.
  /// The name of each type is matched to the `_name` attribute inside the json file.
  String _generateEnumTypes(List flavors) {
    String types = "";
    for (int i = 0; i < flavors.length; i++) {
      final flavor = flavors[i] as Map<String, dynamic>;
      final nameAttribute =
          flavor.entries.firstWhere((attr) => attr.key == '_name');
      types += '  ${nameAttribute.value}';
      if (i != flavors.length - 1) {
        types += ',\n';
      } else {
        types += ';';
      }
    }
    return '''
enum EnvironmentType {
$types

  factory EnvironmentType.fromString(String name) {
    return values.firstWhere((EnvironmentType e) => e.name == name);
  }
}''';
  }

  String _generateToString(List flavors) {
    String attributes = '';
    final entries = _getAllPossibleAttributes(flavors);
    for (var entry in entries) {
      attributes += '"${entry.key}": \$${entry.key}';
      if (entry.key != entries.last.key) {
        attributes += ',';
      }
    }
    return '''
@override
  String toString() {
    return '{$attributes}';
  }''';
  }

  List<MapEntry> _getAllPossibleAttributes(List flavors) {
    final attributes = <MapEntry>[];
    for (var flavor in flavors) {
      for (var currentEntry in flavor.entries) {
        if (attributes
            .where((entry) => entry.key == currentEntry.key)
            .isEmpty) {
          attributes.add(currentEntry);
        }
      }
    }
    return attributes;
  }
}
