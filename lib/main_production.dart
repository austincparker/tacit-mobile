import 'package:flutter_app_base/flavors.dart';
import 'package:flutter_app_base/main.dart' as main_app;

void main() {
  F.appFlavor = Flavor.production;
  main_app.main();
}
