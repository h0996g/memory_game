import 'dart:math';

import 'package:card/components/components.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:uuid/uuid.dart';

class OnlineMultiplayerGameScreen extends StatefulWidget {
  const OnlineMultiplayerGameScreen({super.key});

  @override
  _OnlineMultiplayerGameScreenState createState() =>
      _OnlineMultiplayerGameScreenState();
}

class _OnlineMultiplayerGameScreenState
    extends State<OnlineMultiplayerGameScreen> {
  bool _connectionTimedOut = false;
  IO.Socket? socket;
  String roomId = '';
  String playerId = '';
  bool isConnected = false;
  bool isWaiting = false;
  String opponentId = '';

  late List<int> _numbers;
  late List<bool> _flipped;
  int? _previousIndex;
  bool _waiting = false;
  int _scorePlayer1 = 0;
  int _scorePlayer2 = 0;
  int _currentPlayer = 1;
  int _steps = 0;
  final int _totalPairs = 8;
  bool _isGameActive = false;
  bool _isMyTurn = false;
  bool _amIFirstPlayer = false;

  bool _opponentWantsRestart = false;
  bool _isGameOverDialogOpen = false;
  String _lastWinner = '';

  TextEditingController roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    socket!.dispose();
  }

  void connectToServer() {
    print('Attempting to connect to server...');
    setState(() {
      isConnected = false;
      _connectionTimedOut = false;
    });

    Timer(const Duration(seconds: 5), () {
      if (!isConnected) {
        setState(() {
          _connectionTimedOut = true;
        });
      }
    });

    if (socket != null) {
      socket!.dispose();
    }

    socket =
        IO.io('https://game-memory-socket-io.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'timeout': 10000,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected to server');
      setState(() {
        isConnected = true;
        playerId = const Uuid().v4();
      });
    });

    socket!.onConnectError((error) {
      print('Connection error: $error');
      setState(() {
        isConnected = false;
      });
    });

    socket!.onError((error) {
      print('Socket error: $error');
    });

    socket!.on('roomCreated', (data) {
      print('Room created: $data');
      setState(() {
        roomId = data['roomId'];
        isWaiting = true;
      });
    });

    socket!.on('waitingForOpponent', (data) {
      print('Waiting for opponent in room: ${data['roomId']}');
      setState(() {
        isWaiting = true;
      });
    });

    socket!.on('gameJoined', (data) {
      print('Game joined: $data');
      setState(() {
        roomId = data['roomId'];
        opponentId = data['opponentId'];
        isWaiting = false;
        _isGameActive = true;
        _amIFirstPlayer = data['isFirstPlayer'];
        _isMyTurn = _amIFirstPlayer;
        _initializeGame(List<int>.from(data['gameState']['numbers']));
        _currentPlayer = 1;
      });
      print('Joined room: $roomId with opponent: $opponentId');
      print('Am I first player? $_amIFirstPlayer');
      print('Is it my turn? $_isMyTurn');
      _printGameState();
    });

    socket!.on('gameState', (data) {
      print('Received game state: $data');
      setState(() {
        _numbers = List<int>.from(data['numbers']);
        _flipped = List<bool>.from(data['flipped']);
        _scorePlayer1 = data['scorePlayer1'];
        _scorePlayer2 = data['scorePlayer2'];
        _currentPlayer = data['currentPlayer'];
        _steps = data['steps'];
        _isMyTurn = (_currentPlayer == 1 && _amIFirstPlayer) ||
            (_currentPlayer == 2 && !_amIFirstPlayer);
      });
      _printGameState();
    });

    socket!.on('opponentDisconnected', (_) {
      print('Opponent disconnected');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Opponent Disconnected'),
          content: const Text('Your opponent has left the game.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });

    socket!.on('gameEnded', (data) {
      print('Game ended: $data');
      String winner = data['winner'];
      _showGameOverDialog(winner);
    });

    socket!.on('gameRestarted', (data) {
      print('Game restarted: $data');
      if (_isGameOverDialogOpen) {
        Navigator.of(context).pop(); // Dismiss the dialog if it's open
      }
      setState(() {
        _initializeGame(List<int>.from(data['gameState']['numbers']));
        _currentPlayer = data['startingPlayer'];
        _isMyTurn = (_currentPlayer == 1 && _amIFirstPlayer) ||
            (_currentPlayer == 2 && !_amIFirstPlayer);
        _isGameActive = true;
        _opponentWantsRestart = false;
        _isGameOverDialogOpen = false;
      });
      _printGameState();
    });

    socket!.on('opponentWantsRestart', (_) {
      setState(() {
        _opponentWantsRestart = true;
      });
      if (_isGameOverDialogOpen) {
        Navigator.of(context).pop(); // Close the current dialog
        _showGameOverDialog(_lastWinner); // Reopen with new options
      } else {
        _showRestartDialog();
      }
    });

    socket!.on('opponentQuit', (_) {
      if (_isGameActive) {
        Navigator.of(context)
            .pop(); // Dismiss the game over dialog if it's open
      }
      Navigator.of(context).pop(); // Return to previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opponent has quit the game')),
      );
    });
  }

  void _initializeGame(List<int> numbers) {
    _numbers = numbers;
    _flipped = List.generate(_numbers.length, (_) => false);
    _previousIndex = null;
    _scorePlayer1 = 0;
    _scorePlayer2 = 0;
    _steps = 0;
    _isGameActive = true;
  }

  void _printGameState() {
    print('Game State:');
    print('Room ID: $roomId');
    print('Player ID: $playerId');
    print('Opponent ID: $opponentId');
    print('Am I First Player: $_amIFirstPlayer');
    print('Is My Turn: $_isMyTurn');
    print('Current Player: $_currentPlayer');
    print('Is Game Active: $_isGameActive');
    print('Is Waiting: $_waiting');
    print('Score Player 1: $_scorePlayer1');
    print('Score Player 2: $_scorePlayer2');
    print('Steps: $_steps');
  }

  void _createRoom() {
    socket!.emit('createRoom', {});
  }

  void _joinRoom() {
    if (roomIdController.text.isNotEmpty) {
      socket!.emit('joinRoom', {'roomId': roomIdController.text});
    }
  }

  void _onCardTap(int index) {
    if (_waiting || _flipped[index] || !_isGameActive || !_isMyTurn) {
      return;
    }

    setState(() {
      _flipped[index] = true;
      _steps++;

      print('Emitting flipCard event: $index');
      socket!.emit('flipCard', {'roomId': roomId, 'index': index});

      if (_previousIndex == null) {
        _previousIndex = index;
      } else {
        _waiting = true;
        Future.delayed(const Duration(milliseconds: 1000), () {
          bool matchFound = _numbers[_previousIndex!] == _numbers[index];

          if (matchFound) {
            if (_currentPlayer == 1) {
              _scorePlayer1++;
            } else {
              _scorePlayer2++;
            }
            if (_scorePlayer1 + _scorePlayer2 == _totalPairs) {
              _endGame();
            }
          } else {
            _flipped[_previousIndex!] = false;
            _flipped[index] = false;
            _currentPlayer = 3 - _currentPlayer;
          }

          _isMyTurn = (_currentPlayer == 1 && _amIFirstPlayer) ||
              (_currentPlayer == 2 && !_amIFirstPlayer);

          _previousIndex = null;
          _waiting = false;

          socket!.emit('updateGameState', {
            'roomId': roomId,
            'numbers': _numbers,
            'flipped': _flipped,
            'scorePlayer1': _scorePlayer1,
            'scorePlayer2': _scorePlayer2,
            'currentPlayer': _currentPlayer,
            'steps': _steps,
          });

          setState(() {});
        });
      }
    });
  }

  void _endGame() {
    _isGameActive = false;
    String winner = _scorePlayer1 > _scorePlayer2 ? 'Player 1' : 'Player 2';
    socket!.emit('gameEnded', {'roomId': roomId, 'winner': winner});
  }

  void _showGameOverDialog(String winner) {
    _lastWinner = winner;
    _isGameOverDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(
          winner == 'Player 1'
              ? (_amIFirstPlayer ? 'You win!' : 'Player 1 wins!')
              : (_amIFirstPlayer ? 'Player 2 wins!' : 'You win!'),
        ),
        actions: [
          if (_opponentWantsRestart)
            TextButton(
              child: const Text('Accept Restart'),
              onPressed: () {
                socket!.emit('playerWantsRestart', {'roomId': roomId});
                Navigator.of(context).pop();
                _isGameOverDialogOpen = false;
                _opponentWantsRestart = false;
              },
            ),
          if (!_opponentWantsRestart)
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                socket!.emit('playerWantsRestart', {'roomId': roomId});
                Navigator.of(context).pop();
                _isGameOverDialogOpen = false;
              },
            ),
          TextButton(
            child: const Text('Quit'),
            onPressed: () {
              socket!.emit('playerQuit', {'roomId': roomId});
              Navigator.of(context).pop(); // Dismiss dialog
              Navigator.of(context).pop(); // Return to previous screen
              _isGameOverDialogOpen = false;
            },
          ),
        ],
      ),
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Restart Game'),
        content: const Text(
            'Your opponent wants to restart the game. Do you agree?'),
        actions: [
          TextButton(
            child: const Text('Accept'),
            onPressed: () {
              socket!.emit('playerWantsRestart', {'roomId': roomId});
              Navigator.of(context).pop();
              _opponentWantsRestart = false;
            },
          ),
          TextButton(
            child: const Text('Decline'),
            onPressed: () {
              Navigator.of(context).pop();
              _opponentWantsRestart = false;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isConnected)
                          buildConnectionStatus(
                              _connectionTimedOut, connectToServer),
                        if (isConnected && !_isGameActive)
                          buildLobbyArea(roomIdController, roomId, _createRoom,
                              _joinRoom, isWaiting),
                        if (isConnected && _isGameActive) ...[
                          buildPlayerCards2(
                              _scorePlayer1, _scorePlayer2, _currentPlayer),
                          const SizedBox(height: 16),
                          buildTurnIndicator(_isMyTurn),
                          const SizedBox(height: 16),
                          Expanded(child: _buildGameGrid()),
                        ],
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

  Widget _buildGameGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;
        double gridHeight = constraints.maxHeight;
        double itemSize = gridWidth / 4;
        int rowCount = (gridHeight / itemSize).floor();
        rowCount = min(rowCount, (_numbers.length / 4).ceil());

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
            if (index >= _numbers.length) {
              return const SizedBox();
            }
            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _flipped[index] ? pi : 0),
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
                            child: buildCardBack(index, _numbers),
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
