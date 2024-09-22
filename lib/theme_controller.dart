import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _isDarkMode = GetStorage().read('isDarkMode') == null
      ? false.obs
      : GetStorage().read('isDarkMode') == true
          ? true.obs
          : false.obs;
  var storage = GetStorage();
  bool get isDarkMode => _isDarkMode.value;

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await storage.write('isDarkMode', _isDarkMode.value);
    print(storage.read('isDarkMode'));
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
