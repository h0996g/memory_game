import 'package:card/components/const.dart';
import 'package:card/screen/local_multiplayer/local_multiplayer_game.dart';
import 'package:card/screen/online_multiplayer/online_multiplayer_game_screen.dart';
import 'package:card/screen/single_player/local_single_game.dart';
import 'package:card/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/components.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(themeController.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: themeController.toggleTheme,
              )),
        ],
      ),
      // backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          buildBackgroundShapes(context),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  buildBeautifulTitle(context),
                  const SizedBox(height: 60),
                  Expanded(
                    child: ListView(
                      children: [
                        buildButton(context, 'Single Player', Icons.person,
                            const Color(0xFFE57373), () {
                          Get.to(() => const SingleGameScreen());
                        }),
                        buildButton(context, 'Local Multiplayer', Icons.people,
                            const Color(0xFF81C784), () {
                          Get.to(() => const LocalMultiplayerGameScreen());
                        }),
                        buildButton(context, 'Online Multiplayer', Icons.cloud,
                            const Color(0xFFFFB74D), () {
                          Get.to(
                            () => const OnlineMultiplayerGameScreen(),
                          );
                        }),
                        buildButton(
                          context,
                          'About',
                          Icons.info,
                          const Color(0xFFBA68C8),
                          launchURL,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
