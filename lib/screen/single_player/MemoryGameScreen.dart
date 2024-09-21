import 'package:card/components/components.dart';
import 'package:card/screen/single_player/MemoryGameController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'package:get/get_state_manager/get_state_manager.dart';

class MemoryGameScreen extends StatelessWidget {
  const MemoryGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemoryGameController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            buildBackgroundShapes(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildAppBar('Memory Game', context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GetX<MemoryGameController>(
                          init: controller,
                          builder: (_) {
                            return buildTimerSection(controller.timeLeft.value);
                          },
                        ),
                        const SizedBox(height: 16),
                        GetX<MemoryGameController>(
                          builder: (_) {
                            return buildScoreAndSteps(controller.score.value,
                                controller.totalPairs, controller.steps.value);
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildGameGrid(controller)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGrid(MemoryGameController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: controller.numbers.length,
      itemBuilder: (context, index) {
        return GetX<MemoryGameController>(
          builder: (_) {
            return GestureDetector(
              onTap: () => controller.onCardTap(index),
              child: TweenAnimationBuilder(
                tween: Tween<double>(
                    begin: 0, end: controller.flipped[index] ? pi : 0),
                duration: const Duration(milliseconds: 300),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(value),
                    alignment: Alignment.center,
                    child: value < pi / 2
                        ? buildCardFront()
                        : Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: buildCardBack(index, controller.numbers),
                          ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
