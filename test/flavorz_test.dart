import 'dart:convert';
import 'dart:io';
import 'package:build_test/build_test.dart';
import 'package:flavorz/src/flavorz_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Testing Flavorz Code Generator', () {
    test('Run FlavorBuilder Generator For .flavorz.json File', () async {
      final inputSample =
          File('test/test_samples/input_sample.json').readAsStringSync();

      /// We will do a little decoding to remove the \r characters from the file
      Stream<String> outputSample = File('test/test_samples/output_sample.dart')
          .openRead()
          .transform(utf8.decoder) // Decode bytes to UTF-8.
          .transform(LineSplitter());

      String outputSampleNormalized = '';
      await for (var line in outputSample) {
        outputSampleNormalized += '$line\n';
      }

      await testBuilder(
        FlavorBuilder(),
        {
          "flavorz|lib/env_config.flavorz.json": inputSample,
        },
        outputs: {
          "flavorz|lib/env_config.flavorz.dart": outputSampleNormalized,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });
  });
}
