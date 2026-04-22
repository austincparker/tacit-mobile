import 'package:flutter_app_base/flavors.dart';
import 'package:flutter_app_base/main.dart' as main_app;

void main() {
  F.appFlavor = Flavor.staging;
  main_app.main();
}
