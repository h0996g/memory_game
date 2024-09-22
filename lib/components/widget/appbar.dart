import 'package:card/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

PreferredSizeWidget buildAppBar({
  required String title,
  required BuildContext context,
  bool showBackButton = true,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    // centerTitle: true,

    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    actions: [
      GetX<ThemeController>(
        builder: (ThemeController themeController) {
          return IconButton(
            icon: Icon(
              themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: themeController.toggleTheme,
          );
        },
      ),
    ],
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Get.isDarkMode
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [
                  const Color(0xFFFF9800),
                  const Color(0xFFFF9800),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}
