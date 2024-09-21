import 'package:card/components/const.dart';
import 'package:card/screen/local_multiplayer/local_multiplayer_controller.dart';
import 'package:card/screen/single_player/single_game_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/components.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          buildBackgroundShapes(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  buildBeautifulTitle(),
                  const SizedBox(height: 60),
                  Expanded(
                    child: ListView(
                      children: [
                        buildButton(context, 'Single Player', Icons.person,
                            const Color(0xFFE57373), () {
                          Get.delete<SingleGameController>();
                          Get.toNamed('/single-player');
                        }),
                        buildButton(context, 'Local Multiplayer', Icons.people,
                            const Color(0xFF81C784), () {
                          Get.delete<LocalMultiplayerController>();
                          Get.toNamed('/local-multiplayer');
                        }),
                        buildButton(context, 'Online Multiplayer', Icons.cloud,
                            const Color(0xFFFFB74D), () {
                          Get.toNamed('/online-multiplayer');
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
