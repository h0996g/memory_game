import 'package:card/theme_controller.dart';
import 'package:get/get.dart';

Future<void> registerControllers() async {
  // Register controllers
  Get.put(ThemeController());
}
