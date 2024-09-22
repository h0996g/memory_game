import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:uuid/uuid.dart';

class OnlineGameController extends GetxController {
  IO.Socket? socket;
  var roomId = ''.obs;
  var playerId = ''.obs;
  var isConnected = false.obs;
  var isWaiting = false.obs;
  var opponentId = ''.obs;

  var numbers = <int>[].obs;
  var flipped = <bool>[].obs;
  var previousIndex = Rx<int?>(null);
  var waiting = false.obs;
  var scorePlayer1 = 0.obs;
  var scorePlayer2 = 0.obs;
  var currentPlayer = 1.obs;
  var steps = 0.obs;
  final int totalPairs = 8;
  var isGameActive = false.obs;
  var isMyTurn = false.obs;
  var amIFirstPlayer = false.obs;

  var opponentWantsRestart = false.obs;
  var isGameOverDialogOpen = false.obs;
  var lastWinner = ''.obs;
  var connectionTimedOut = false.obs;

  TextEditingController roomIdController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    connectToServer();
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }

  void connectToServer() {
    print('Attempting to connect to server...');
    isConnected.value = false;
    connectionTimedOut.value = false;

    Timer(const Duration(seconds: 5), () {
      if (!isConnected.value) {
        connectionTimedOut.value = true;
      }
    });

    if (socket != null) {
      socket!.dispose();
    }

    socket =
        IO.io('https://game-memory-socket-io.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'timeout': 20000,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected to server');
      isConnected.value = true;
      playerId.value = const Uuid().v4();
    });

    socket!.onConnectError((error) {
      print('Connection error: $error');
      isConnected.value = false;
    });

    socket!.onError((error) {
      print('Socket error: $error');
    });

    socket!.on('roomCreated', (data) {
      print('Room created: $data');
      roomId.value = data['roomId'];
      isWaiting.value = true;
    });

    socket!.on('gameJoined', (data) {
      print('Game joined: $data');
      roomId.value = data['roomId'];
      opponentId.value = data['opponentId'];
      isWaiting.value = false;
      isGameActive.value = true;
      amIFirstPlayer.value = data['isFirstPlayer'];
      isMyTurn.value = amIFirstPlayer.value;
      initializeGame(List<int>.from(data['gameState']['numbers']));
      currentPlayer.value = 1;
    });

    socket!.on('gameState', (data) {
      print('Received game state: $data');
      numbers.value = List<int>.from(data['numbers']);
      flipped.value = List<bool>.from(data['flipped']);
      scorePlayer1.value = data['scorePlayer1'];
      scorePlayer2.value = data['scorePlayer2'];
      currentPlayer.value = data['currentPlayer'];
      steps.value = data['steps'];
      isMyTurn.value = (currentPlayer.value == 1 && amIFirstPlayer.value) ||
          (currentPlayer.value == 2 && !amIFirstPlayer.value);
    });

    socket!.on('opponentDisconnected', (_) {
      print('Opponent disconnected');
      Get.dialog(
        AlertDialog(
          title: const Text('Opponent Disconnected'),
          content: const Text('Your opponent has left the game.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Get.back();
                Get.back();
              },
            ),
          ],
        ),
      );
    });

    socket!.on('gameEnded', (data) {
      print('Game ended: $data');
      String winner = data['winner'];
      showGameOverDialog(winner);
    });

    socket!.on('gameRestarted', (data) {
      print('Game restarted: $data');
      if (isGameOverDialogOpen.value) {
        Get.back(); // Dismiss the dialog if it's open
      }
      initializeGame(List<int>.from(data['gameState']['numbers']));
      currentPlayer.value = data['startingPlayer'];
      isMyTurn.value = (currentPlayer.value == 1 && amIFirstPlayer.value) ||
          (currentPlayer.value == 2 && !amIFirstPlayer.value);
      isGameActive.value = true;
      opponentWantsRestart.value = false;
      isGameOverDialogOpen.value = false;
    });

    socket!.on('opponentWantsRestart', (_) {
      opponentWantsRestart.value = true;
      if (isGameOverDialogOpen.value) {
        Get.back(); // Close the current dialog
        showGameOverDialog(lastWinner.value); // Reopen with new options
      } else {
        showRestartDialog();
      }
    });

    socket!.on('opponentQuit', (_) {
      if (isGameActive.value) {
        Get.back(); // Dismiss the game over dialog if it's open
      }
      Get.back(); // Return to previous screen
      Get.snackbar('Opponent Quit', 'Your opponent has quit the game');
    });
  }

  void createRoom() {
    socket!.emit('createRoom', {});
  }

  void joinRoom() {
    if (roomIdController.text.isNotEmpty) {
      socket!.emit('joinRoom', {'roomId': roomIdController.text});
    }
  }

  void initializeGame(List<int> initialNumbers) {
    numbers.value = initialNumbers;
    flipped.value = List.generate(numbers.length, (_) => false);
    previousIndex.value = null;
    scorePlayer1.value = 0;
    scorePlayer2.value = 0;
    steps.value = 0;
    isGameActive.value = true;
  }

  void onCardTap(int index) {
    if (waiting.value ||
        flipped[index] ||
        !isGameActive.value ||
        !isMyTurn.value) {
      return;
    }

    flipped[index] = true;
    steps.value++;

    print('Emitting flipCard event: $index');
    socket!.emit('flipCard', {'roomId': roomId.value, 'index': index});

    if (previousIndex.value == null) {
      previousIndex.value = index;
    } else {
      waiting.value = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        bool matchFound = numbers[previousIndex.value!] == numbers[index];

        if (matchFound) {
          if (currentPlayer.value == 1) {
            scorePlayer1.value++;
          } else {
            scorePlayer2.value++;
          }
          if (scorePlayer1.value + scorePlayer2.value == totalPairs) {
            endGame();
          }
        } else {
          flipped[previousIndex.value!] = false;
          flipped[index] = false;
          currentPlayer.value = 3 - currentPlayer.value;
        }

        isMyTurn.value = (currentPlayer.value == 1 && amIFirstPlayer.value) ||
            (currentPlayer.value == 2 && !amIFirstPlayer.value);

        previousIndex.value = null;
        waiting.value = false;

        socket!.emit('updateGameState', {
          'roomId': roomId.value,
          'numbers': numbers,
          'flipped': flipped,
          'scorePlayer1': scorePlayer1.value,
          'scorePlayer2': scorePlayer2.value,
          'currentPlayer': currentPlayer.value,
          'steps': steps.value,
        });

        update();
      });
    }
  }

  void endGame() {
    isGameActive.value = false;
    String winner =
        scorePlayer1.value > scorePlayer2.value ? 'Player 1' : 'Player 2';
    socket!.emit('gameEnded', {'roomId': roomId.value, 'winner': winner});
  }

  void showGameOverDialog(String winner) {
    lastWinner.value = winner;
    isGameOverDialogOpen.value = true;
    Get.dialog(
      AlertDialog(
        title: const Text('Game Over'),
        content: Text(
          winner == 'Player 1'
              ? (amIFirstPlayer.value ? 'You win!' : 'Player 1 wins!')
              : (amIFirstPlayer.value ? 'Player 2 wins!' : 'You win!'),
        ),
        actions: [
          if (opponentWantsRestart.value)
            TextButton(
              child: const Text('Accept Restart'),
              onPressed: () {
                socket!.emit('playerWantsRestart', {'roomId': roomId.value});
                Get.back();
                isGameOverDialogOpen.value = false;
                opponentWantsRestart.value = false;
              },
            ),
          if (!opponentWantsRestart.value)
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                socket!.emit('playerWantsRestart', {'roomId': roomId.value});
                Get.back();
                isGameOverDialogOpen.value = false;
              },
            ),
          TextButton(
            child: const Text('Quit'),
            onPressed: () {
              socket!.emit('playerQuit', {'roomId': roomId.value});
              Get.back(); // Dismiss dialog
              Get.back(); // Return to previous screen
              isGameOverDialogOpen.value = false;
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showRestartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Restart Game'),
        content: const Text(
            'Your opponent wants to restart the game. Do you agree?'),
        actions: [
          TextButton(
            child: const Text('Accept'),
            onPressed: () {
              socket!.emit('playerWantsRestart', {'roomId': roomId.value});
              Get.back();
              opponentWantsRestart.value = false;
            },
          ),
          TextButton(
            child: const Text('Decline'),
            onPressed: () {
              Get.back();
              opponentWantsRestart.value = false;
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
