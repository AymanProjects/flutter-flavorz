library flavorz;

import 'package:build/build.dart';
import 'src/flavorz_builder.dart';

/// This will be called once we run `dart run build_runner build`
/// And will generate the output file that contains the `Environment` class.
Builder build(BuilderOptions _) => FlavorBuilder();
