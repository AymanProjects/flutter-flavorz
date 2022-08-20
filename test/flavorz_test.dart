import 'package:build/build.dart';
import 'package:flavorz/src/flavorz_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Testing Flavorz Code Generator', () {
    final builder = FlavorBuilder();

    test('Ensure Input & output files have identical path', () {
      String inputPath = 'lib/config/env.flavorz.json';
      final outputAssetId =
          builder.createOutputFileId(AssetId('flavorz', inputPath));
      final outputPath = outputAssetId.path;
      expect(outputPath, 'lib/config/env.flavorz.dart');
    });

    test('Ensure the generated Environment attributes are correct', () {
      final inputFalvors = [
        {'_name': 'dev', 'intNumber': 8},
        {'_name': 'local'},
        {'_name': 'local', 'doubleNumber': 2.3, 'baseUrl': '/'},
      ];
      final generatedAttributes = builder.generateAttributes(inputFalvors);
      final expectedAttributes = '''
  final String _name;
  final int? intNumber;
  final double? doubleNumber;
  final String? baseUrl;
''';
      expect(generatedAttributes, expectedAttributes);
    });
  });
}
