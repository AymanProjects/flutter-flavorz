import 'dart:convert';
import 'package:build/build.dart';

/// Input file must end with .json
const inputExtension = ".flavor.json";

/// Output file must end with .dart
const outputExtension = ".g.dart";

/// The key of the list of environments(flavors) inside the json file
const environmentsJsonKey = "environments";

/// The key from the json file that holds the id of the environment(flavor) that we wish to run.
const environmentToRunJsonKey = "environmentToRun";

/// The `FlavorBuilder` is a code gerenator that will look for file
/// that ends with [inputExtension] inside the lib folder, and consturct a new dart file that will
/// contain `Environment` class, that will be used across the app.
/// The new file will end with [outputExtension].
class FlavorBuilder implements Builder {
  /// Specify the input & output file extensions
  @override
  final buildExtensions = const {
    inputExtension: [outputExtension]
  };

  /// The build function will be called for each file that ends with [inputExtension].
  /// In our case, there should be only one file.
  @override
  Future<void> build(BuildStep buildStep) async {
    /// Store the input file path
    AssetId inputFileId = buildStep.inputId;

    /// Decode the content of the input file
    Map<String, dynamic> json =
        jsonDecode(await buildStep.readAsString(inputFileId));

    /// Get all flavors from the file as a `list` of `map`
    final flavors = json[environmentsJsonKey] as List;

    /// Generate the `Environment` class
    final outputContent = generateEnvironmentClass(flavors, inputFileId.path);

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
    List flavors,
    String inputFileId,
  ) {
    /// Since all elements in the `flavors` list are identical in terms of structure,
    /// we will just grab the first element to generate the `Environment` class from it.
    final flavor = flavors.first as Map<String, dynamic>;

    return '''
/// Auto Generated. Do Not Edit ⚠️

import 'dart:convert';
import 'dart:io';

/// Path to the json file that holds the configurations of the environments
const pathToJsonConfigFile = '$inputFileId';

/// The key of the list of environments(flavors) inside the json file
const environmentsJsonKey = '$environmentsJsonKey';

/// The key from the json file that holds the id of the environment(flavor) that we wish to run.
const environmentToRunJsonKey = '$environmentToRunJsonKey';

class Environment {
${_generateAttributes(flavor)}
  ${_generatePrivateConstructor(flavor)}

  /// `type` is an `enum`, to be used for comparison, instead of id & name
  EnvironmentType get type => EnvironmentType.fromId(_id);

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
    int environmnetToRunId = json[environmentToRunJsonKey];
    final matchedEnvironments =
        environments.where((env) => env._id == environmnetToRunId);
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

  ${_generateFromMapFuntion(flavor)}

  ${_generateToString(flavor)}
}

${_generateEnumTypes(flavors)}
''';
  }

  /// Will go over all the attributes in the json file and make the same attributes in the Environment class
  String _generateAttributes(Map<String, dynamic> flavor) {
    String attributes = '';
    for (var entry in flavor.entries) {
      attributes += '  final ${entry.value.runtimeType} ${entry.key};\n';
    }
    return attributes;
  }

  /// Will generate a private constructor based on the attributes in the json file
  String _generatePrivateConstructor(Map<String, dynamic> flavor) {
    String attributes = "";
    for (int i = 0; i < flavor.entries.length; i++) {
      attributes += '    this.${flavor.entries.toList()[i].key},';
      if (i != flavor.entries.length - 1) {
        attributes += '\n';
      }
    }
    return '''
Environment._(
$attributes
  );''';
  }

  /// Will generate the `fromMap` function to prase json into object of type `Environment`
  String _generateFromMapFuntion(Map<String, dynamic> flavor) {
    String attributes = '';
    for (int i = 0; i < flavor.entries.length; i++) {
      attributes +=
          '      map["${flavor.entries.toList()[i].key}"] as ${flavor.entries.toList()[i].value.runtimeType},';
      if (i != flavor.entries.length - 1) {
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
      final idAttribute =
          flavor.entries.firstWhere((attr) => attr.key == '_id');
      types += '  ${nameAttribute.value}(${idAttribute.value})';
      if (i != flavors.length - 1) {
        types += ',\n';
      } else {
        types += ';';
      }
    }
    return '''
enum EnvironmentType {
$types
  
  const EnvironmentType(this.id);
  final int id;

  factory EnvironmentType.fromId(int id) {
    return values.firstWhere((e) => e.id == id);
  }
}''';
  }

  String _generateToString(Map<String, dynamic> flavor) {
    String attributes = '';
    for (var entry in flavor.entries) {
      attributes += '"${entry.key}": \$${entry.key}';
      if (entry.key != flavor.entries.last.key) {
        attributes += ',';
      }
    }
    return '''
@override
  String toString() {
    return '{$attributes}';
  }''';
  }
}
