import 'dart:math';
import 'package:card/screen/online_multiplayer/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:card/components/components.dart';

class OnlineMultiplayerGameScreen extends StatelessWidget {
  const OnlineMultiplayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnlineGameController gameController = Get.put(OnlineGameController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            buildBackgroundShapes(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildAppBar('Online', context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GetX<OnlineGameController>(
                      builder: (DisposableInterface controller) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!gameController.isConnected.value)
                              buildConnectionStatus(
                                gameController.connectionTimedOut.value,
                                gameController.connectToServer,
                              ),
                            if (gameController.isConnected.value &&
                                !gameController.isGameActive.value)
                              buildLobbyArea(
                                gameController.roomIdController,
                                gameController.roomId.value,
                                gameController.createRoom,
                                gameController.joinRoom,
                                gameController.isWaiting.value,
                              ),
                            if (gameController.isConnected.value &&
                                gameController.isGameActive.value) ...[
                              buildPlayerCards2(
                                gameController.scorePlayer1.value,
                                gameController.scorePlayer2.value,
                                gameController.currentPlayer.value,
                              ),
                              const SizedBox(height: 16),
                              buildTurnIndicator(gameController.isMyTurn.value),
                              const SizedBox(height: 16),
                              Expanded(child: _buildGameGrid(gameController)),
                            ],
                          ],
                        );
                      },
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

  Widget _buildGameGrid(OnlineGameController gameController) {
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
            return GetX<OnlineGameController>(
              builder: (DisposableInterface controller) {
                return GestureDetector(
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
                );
              },
            );
          },
        );
      },
    );
  }
}
