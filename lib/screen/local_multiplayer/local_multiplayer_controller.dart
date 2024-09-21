import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';

class LocalMultiplayerController extends GetxController {
  final int numPairs = 8;
  final RxList<int> numbers = <int>[].obs;
  final RxList<bool> flipped = <bool>[].obs;
  final RxInt previousIndex = RxInt(-1);
  final RxBool waiting = false.obs;
  final RxInt scorePlayer1 = 0.obs;
  final RxInt scorePlayer2 = 0.obs;
  final RxInt currentPlayer = 1.obs;
  final RxInt steps = 0.obs;
  final int totalPairs = 8;
  final RxInt timeLeftPlayer1 = 30.obs;
  final RxInt timeLeftPlayer2 = 30.obs;
  Timer? timer;
  final RxBool isGameActive = true.obs;
  final RxBool gameEnded = false.obs;

  Function? showGameOverDialogCallback;

  void setShowGameOverDialogCallback(Function callback) {
    showGameOverDialogCallback = callback;
  }

  @override
  void onInit() {
    super.onInit();
    initializeGame();
  }

  @override
  void dispose() {
// TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  void initializeGame() {
    numbers.value = List.generate(numPairs, (index) => index + 1)
      ..addAll(List.generate(numPairs, (index) => index + 1))
      ..shuffle(Random());
    flipped.value = List.generate(numbers.length, (_) => false);
    previousIndex.value = -1;
    scorePlayer1.value = 0;
    scorePlayer2.value = 0;
    steps.value = 0;
    timeLeftPlayer1.value = 30;
    timeLeftPlayer2.value = 30;
    isGameActive.value = true;
    gameEnded.value = false;
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentPlayer.value == 1) {
        if (timeLeftPlayer1.value > 0) {
          timeLeftPlayer1.value--;
        } else {
          switchPlayer();
        }
      } else {
        if (timeLeftPlayer2.value > 0) {
          timeLeftPlayer2.value--;
        } else {
          switchPlayer();
        }
      }

      if ((timeLeftPlayer1.value == 0 && timeLeftPlayer2.value == 0) ||
          (scorePlayer1.value + scorePlayer2.value == totalPairs)) {
        endGame();
      }
    });
  }

  void switchPlayer() {
    if (currentPlayer.value == 1 && timeLeftPlayer2.value > 0) {
      currentPlayer.value = 2;
    } else if (currentPlayer.value == 2 && timeLeftPlayer1.value > 0) {
      currentPlayer.value = 1;
    }
    waiting.value = false;
    previousIndex.value = -1;
  }

  void endGame() {
    if (!gameEnded.value) {
      gameEnded.value = true;
      isGameActive.value = false;
      timer?.cancel();
      showGameOverDialogCallback?.call();
    }
  }

  void onCardTap(int index) {
    if (waiting.value ||
        flipped[index] ||
        !isGameActive.value ||
        (currentPlayer.value == 1 && timeLeftPlayer1.value == 0) ||
        (currentPlayer.value == 2 && timeLeftPlayer2.value == 0)) return;

    flipped[index] = true;
    steps.value++;

    if (previousIndex.value == -1) {
      previousIndex.value = index;
    } else {
      waiting.value = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (numbers[previousIndex.value] == numbers[index]) {
          if (currentPlayer.value == 1) {
            scorePlayer1.value++;
          } else {
            scorePlayer2.value++;
          }
          if (scorePlayer1.value + scorePlayer2.value == totalPairs) {
            endGame();
          }
        } else {
          flipped[previousIndex.value] = false;
          flipped[index] = false;
          switchPlayer();
        }
        previousIndex.value = -1;
        waiting.value = false;
      });
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
