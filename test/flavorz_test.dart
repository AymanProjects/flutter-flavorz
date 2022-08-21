import 'package:build/build.dart';
import 'package:flavorz/src/flavorz_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Testing Flavorz Code Generator', () {
    final builder = FlavorBuilder();
    final inputFalvors = [
      {'_name': 'dev', 'intNumber': 8},
      {'_name': 'local'},
      {'_name': 'prod', 'doubleNumber': 2.3, 'baseUrl': '/'},
    ];

    test('Ensure Input & output files have identical path', () {
      String inputPath = 'lib/config/env.flavorz.json';
      final outputAssetId =
          builder.createOutputFileId(AssetId('flavorz', inputPath));
      final outputPath = outputAssetId.path;
      expect(outputPath, 'lib/config/env.flavorz.dart');
    });

    test('Ensure the generated Environment attributes are correct', () {
      final generated = builder.generateAttributes(inputFalvors);
      final expected = '''
  final String _name;
  final int? intNumber;
  final double? doubleNumber;
  final String? baseUrl;
''';
      expect(generated, expected);
    });

    test('Ensure the generated Environment Constructor is correct', () {
      final generated = builder.generatePrivateConstructor(inputFalvors);
      final expected = '''
Environment._(
    this._name,
    this.intNumber,
    this.doubleNumber,
    this.baseUrl,
  );''';
      expect(generated, expected);
    });

    test('Ensure the generated fromMap function is correct', () {
      final generated = builder.generateFromMapFuntion(inputFalvors);
      final expected = '''
factory Environment._fromMap(Map<String, dynamic> map) {
    return Environment._(
      map["_name"] as String,
      map["intNumber"] as int?,
      map["doubleNumber"] as double?,
      map["baseUrl"] as String?,
    );
  }''';
      expect(generated, expected);
    });

    test('Ensure the generated enum types are correct', () {
      final generated = builder.generateEnumTypes(inputFalvors);
      final expected = '''
enum EnvironmentType {
  dev,
  local,
  prod;

  factory EnvironmentType.fromString(String name) {
    return values.firstWhere((EnvironmentType e) => e.name == name);
  }
}''';
      expect(generated, expected);
    });

    test('Ensure the generated toString function is correct', () {
      final generated = builder.generateToString(inputFalvors);
      final expected = '''
@override
  String toString() {
    return '{"_name": \$_name, "intNumber": \$intNumber, "doubleNumber": \$doubleNumber, "baseUrl": \$baseUrl}';
  }''';
      expect(generated, expected);
    });
  });
}
