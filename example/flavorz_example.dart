import 'env.g.dart';

/// After you running `dart run build_runner build`,
/// you can write the following in your main (uncomment the lines)
/// and import the needed files.
///
/// For more info. refer to the README.md file
void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  await Environment.init();
  if (Environment().type == EnvironmentType.dev) {
    print('We are running the dev environment!');
  }
  //runApp()
}
