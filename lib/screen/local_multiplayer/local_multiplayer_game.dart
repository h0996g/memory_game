import 'dart:math';
import 'package:card/screen/local_multiplayer/GameController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:card/components/components.dart';

class LocalMultiplayerGameScreen extends StatelessWidget {
  const LocalMultiplayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());

    gameController.setShowGameOverDialogCallback(
        () => _showGameOverDialog(context, gameController));

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
                        Obx(() => buildPlayerCards(
                              gameController.scorePlayer1.value,
                              gameController.timeLeftPlayer1.value,
                              gameController.scorePlayer2.value,
                              gameController.timeLeftPlayer2.value,
                              gameController.currentPlayer.value,
                            )),
                        const SizedBox(height: 16),
                        Obx(() => buildProgressBar(
                              gameController.timeLeftPlayer1.value,
                              gameController.timeLeftPlayer2.value,
                            )),
                        const SizedBox(height: 16),
                        Expanded(child: _buildGameGrid(gameController)),
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

  void _showGameOverDialog(
      BuildContext context, GameController gameController) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Game Over!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'Player 1 Score: ${gameController.scorePlayer1.value}\nPlayer 2 Score: ${gameController.scorePlayer2.value}\nSteps: ${gameController.steps.value}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameController.initializeGame();
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                // gameController.initializeGame();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameGrid(GameController gameController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;
        double gridHeight = constraints.maxHeight;
        double itemSize = gridWidth / 4;
        int rowCount = (gridHeight / itemSize).floor();
        rowCount = min(rowCount, (gameController.numbers.length / 4).ceil());

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: rowCount * 4,
          itemBuilder: (context, index) {
            if (index >= gameController.numbers.length) {
              return const SizedBox();
            }
            return Obx(() => GestureDetector(
                  onTap: () => gameController.onCardTap(index),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(
                        begin: 0, end: gameController.flipped[index] ? pi : 0),
                    duration: const Duration(milliseconds: 300),
                    builder:
                        (BuildContext context, double value, Widget? child) {
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
                                child: buildCardBack(
                                    index, gameController.numbers),
                              ),
                      );
                    },
                  ),
                ));
          },
        );
      },
    );
  }
}
