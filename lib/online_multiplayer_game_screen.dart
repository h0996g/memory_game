import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:uuid/uuid.dart';

class OnlineMultiplayerGameScreen extends StatefulWidget {
  const OnlineMultiplayerGameScreen({Key? key}) : super(key: key);

  @override
  _OnlineMultiplayerGameScreenState createState() =>
      _OnlineMultiplayerGameScreenState();
}

class _OnlineMultiplayerGameScreenState
    extends State<OnlineMultiplayerGameScreen> {
  IO.Socket? socket;
  String roomId = '';
  String playerId = '';
  bool isConnected = false;
  bool isWaiting = false;
  String opponentId = '';

  final int _numPairs = 8;
  late List<int> _numbers;
  late List<bool> _flipped;
  int? _previousIndex;
  bool _waiting = false;
  int _scorePlayer1 = 0;
  int _scorePlayer2 = 0;
  int _currentPlayer = 1;
  int _steps = 0;
  int _totalPairs = 8;
  bool _isGameActive = false;
  bool _isMyTurn = false;
  bool _amIFirstPlayer = false;

  TextEditingController roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectToServer();
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

  void connectToServer() {
    print('Attempting to connect to server...');
    // Dispose of the old socket if it exists
    if (socket != null) {
      socket!.dispose();
    }

    // Create a new socket
    socket = IO.io('http://192.168.1.18:3000', <String, dynamic>{
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

    socket!.on('gameRestarted', (data) {
      print('Game restarted: $data');
      setState(() {
        _initializeGame(List<int>.from(data['gameState']['numbers']));
        _currentPlayer = data['startingPlayer'];
        _isMyTurn = (_currentPlayer == 1 && _amIFirstPlayer) ||
            (_currentPlayer == 2 && !_amIFirstPlayer);
      });
      _printGameState();
    });

    socket!.on('roomJoinError', (data) {
      print('Room join error: ${data['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    });
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(
          _scorePlayer1 > _scorePlayer2
              ? 'Player 1 wins!'
              : _scorePlayer1 < _scorePlayer2
                  ? 'Player 2 wins!'
                  : 'It\'s a tie!',
        ),
        actions: [
          TextButton(
            child: const Text('Play Again'),
            onPressed: () {
              Navigator.of(context).pop();
              socket!.emit('restartGame', {'roomId': roomId});
            },
          ),
          TextButton(
            child: const Text('Quit'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Memory Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isConnected)
              Column(
                children: [
                  Text('Connecting to server...'),
                  ElevatedButton(
                    onPressed: connectToServer,
                    child: Text('Retry Connection'),
                  ),
                ],
              ),
            if (isConnected && !_isGameActive)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _createRoom,
                    child: Text('Create Room'),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: roomIdController,
                    decoration: InputDecoration(labelText: 'Room ID'),
                  ),
                  ElevatedButton(
                    onPressed: _joinRoom,
                    child: Text('Join Room'),
                  ),
                  if (roomId.isNotEmpty) Text('Room ID: $roomId'),
                  if (isWaiting) Text('Waiting for opponent...'),
                ],
              ),
            if (isConnected && _isGameActive)
              Expanded(
                child: Column(
                  children: [
                    Text('Room ID: $roomId'),
                    Text('Player ID: $playerId'),
                    Text('Opponent ID: $opponentId'),
                    Text('Player 1 Score: $_scorePlayer1'),
                    Text('Player 2 Score: $_scorePlayer2'),
                    Text(_isMyTurn ? 'Your Turn' : 'Opponent\'s Turn',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _numbers.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _onCardTap(index),
                            child: Card(
                              color:
                                  _flipped[index] ? Colors.white : Colors.blue,
                              child: Center(
                                child: _flipped[index]
                                    ? Text(
                                        '${_numbers[index]}',
                                        style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }
}
