import 'dart:math';

import 'package:card/widget/compact_player_card_online.dart';
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
            _buildBackgroundShapes(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isConnected) _buildConnectionStatus(),
                        if (isConnected && !_isGameActive) _buildLobbyArea(),
                        if (isConnected && _isGameActive) ...[
                          _buildPlayerCards(),
                          const SizedBox(height: 16),
                          _buildTurnIndicator(),
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

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: _buildShape(200, const Color(0xFFFFCCBC).withOpacity(0.5)),
        ),
        Positioned(
          bottom: -30,
          right: -30,
          child: _buildShape(150, const Color(0xFFB2DFDB).withOpacity(0.5)),
        ),
        Positioned(
          top: 100,
          right: -20,
          child: _buildShape(100, const Color(0xFFFFECB3).withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _buildShape(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Online',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 48), // To balance the back button
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Connecting to server...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (!_connectionTimedOut)
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)))
        else
          _buildButton(
            'Retry Connection',
            Icons.refresh,
            const Color(0xFFFF9800),
            connectToServer,
          ),
      ],
    );
  }

  Widget _buildLobbyArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          'Create Room',
          Icons.add,
          const Color(0xFFFF9800),
          _createRoom,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: roomIdController,
          decoration: InputDecoration(
            labelText: 'Room ID',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF9800)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildButton(
          'Join Room',
          Icons.login,
          const Color(0xFFFF5722),
          _joinRoom,
        ),
        if (roomId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('Room ID: $roomId',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        if (isWaiting)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Waiting for opponent...',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _buildPlayerCards() {
    return Row(
      children: [
        Expanded(
          child: CompactPlayerCardOnline(
            player: 'Player 1',
            score: _scorePlayer1,
            isActive: _currentPlayer == 1,
            color: const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CompactPlayerCardOnline(
            player: 'Player 2',
            score: _scorePlayer2,
            isActive: _currentPlayer == 2,
            color: const Color(0xFFFF5722),
          ),
        ),
      ],
    );
  }

  Widget _buildTurnIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _isMyTurn ? const Color(0xFFFF9800) : const Color(0xFFFF5722),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _isMyTurn ? 'Your Turn' : 'Opponent\'s Turn',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
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
                        ? _buildCardFront()
                        : Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _buildCardBack(index),
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

  Widget _buildCardFront() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF9800), width: 2),
        ),
        child: const Center(
          child: Icon(Icons.question_mark, size: 40, color: Color(0xFFFF9800)),
        ),
      ),
    );
  }

  Widget _buildCardBack(int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: const Color(0xFFFF9800),
      child: Center(
        child: Text(
          '${_numbers[index]}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 250,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
