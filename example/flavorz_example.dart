import 'env.flavorz.dart';

/// After you running `dart run build_runner build`,
/// you can write the following in your main (uncomment the lines)
/// and import the needed files.
///
/// For more info. refer to the README.md file
void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  final type = Environment().type;
  print(type);
}
