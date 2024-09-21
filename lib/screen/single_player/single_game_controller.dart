import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SingleGameController extends GetxController {
  final int numPairs = 8;
  final RxList<int> numbers = <int>[].obs;
  final RxList<bool> flipped = <bool>[].obs;
  final RxInt previousIndex = RxInt(-1);
  final RxBool waiting = false.obs;
  final RxInt score = 0.obs;
  final RxInt steps = 0.obs;
  final int totalPairs = 8;
  final RxInt timeLeft = 60.obs;
  Timer? timer;
  final RxBool isGameActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    initializeGame();
  }

  void initializeGame() {
    numbers.value = List.generate(numPairs, (index) => index + 1)
      ..addAll(List.generate(numPairs, (index) => index + 1))
      ..shuffle(Random());
    flipped.value = List.generate(numbers.length, (_) => false);
    previousIndex.value = -1;
    score.value = 0;
    steps.value = 0;
    timeLeft.value = 60;
    isGameActive.value = true;
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        timer.cancel();
        isGameActive.value = false;
        showGameOverDialog();
      }
    });
  }

  void showGameOverDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Time\'s Up!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            'Your score: ${score.value}/$totalPairs\nSteps: ${steps.value}'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              initializeGame();
            },
            child:
                const Text('Restart', style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Home', style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void onCardTap(int index) {
    if (waiting.value || flipped[index] || !isGameActive.value) return;

    flipped[index] = true;

    if (previousIndex.value == -1) {
      previousIndex.value = index;
      steps.value++;
    } else {
      waiting.value = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (numbers[previousIndex.value] == numbers[index]) {
          score.value++;
          if (score.value == totalPairs) {
            timer?.cancel();
            showWinDialog();
          }
        } else {
          flipped[previousIndex.value] = false;
          flipped[index] = false;
        }
        previousIndex.value = -1;
        waiting.value = false;
      });
    }
  }

  void showWinDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Congratulations!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            'You won!\nScore: ${score.value}/$totalPairs\nSteps: ${steps.value}\nTime left: ${timeLeft.value} seconds'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              initializeGame();
            },
            child: const Text('Play Again',
                style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Home', style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
