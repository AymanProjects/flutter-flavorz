import 'package:flavours_template/config/environment/environment.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.init();
  print(Environment().versionNumber);
  //runApp
}
