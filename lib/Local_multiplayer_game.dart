import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class LocalMultiplayerGameScreen extends StatefulWidget {
  const LocalMultiplayerGameScreen({Key? key}) : super(key: key);

  @override
  _LocalMultiplayerGameScreenState createState() =>
      _LocalMultiplayerGameScreenState();
}

class _LocalMultiplayerGameScreenState extends State<LocalMultiplayerGameScreen>
    with TickerProviderStateMixin {
  final int _numPairs = 8;
  late List<int> _numbers;
  late List<bool> _flipped;
  int? _previousIndex;
  bool _waiting = false;
  int _scorePlayer1 = 0;
  int _scorePlayer2 = 0;
  int _currentPlayer = 1; // 1 for Player 1, 2 for Player 2
  int _steps = 0;
  int _totalPairs = 8;
  int _timeLeftPlayer1 = 30;
  int _timeLeftPlayer2 = 30;
  Timer? _timer;
  bool _isGameActive = true;
  bool _gameEnded = false; // Flag to track if the game has ended

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _numbers = List.generate(_numPairs, (index) => index + 1)
      ..addAll(List.generate(_numPairs, (index) => index + 1))
      ..shuffle(Random());
    _flipped = List.generate(_numbers.length, (_) => false);
    _previousIndex = null;
    _scorePlayer1 = 0;
    _scorePlayer2 = 0;
    _steps = 0;
    _timeLeftPlayer1 = 30;
    _timeLeftPlayer2 = 30;
    _isGameActive = true;
    _gameEnded = false;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentPlayer == 1) {
          if (_timeLeftPlayer1 > 0) {
            _timeLeftPlayer1--;
          } else {
            _switchPlayer();
          }
        } else {
          if (_timeLeftPlayer2 > 0) {
            _timeLeftPlayer2--;
          } else {
            _switchPlayer();
          }
        }

        if ((_timeLeftPlayer1 == 0 && _timeLeftPlayer2 == 0) ||
            (_scorePlayer1 + _scorePlayer2 == _totalPairs)) {
          _endGame();
        }
      });
    });
  }

  void _switchPlayer() {
    if (_currentPlayer == 1 && _timeLeftPlayer2 > 0) {
      _currentPlayer = 2;
    } else if (_currentPlayer == 2 && _timeLeftPlayer1 > 0) {
      _currentPlayer = 1;
    }
    _waiting = false;
    _previousIndex = null;
  }

  void _endGame() {
    if (!_gameEnded) {
      _gameEnded = true;
      _isGameActive = false;
      _timer?.cancel();
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Game Over!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'Player 1 Score: $_scorePlayer1\nPlayer 2 Score: $_scorePlayer2\nSteps: $_steps'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _initializeGame();
                });
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to home
              },
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  }

  void _onCardTap(int index) {
    if (_waiting ||
        _flipped[index] ||
        !_isGameActive ||
        (_currentPlayer == 1 && _timeLeftPlayer1 == 0) ||
        (_currentPlayer == 2 && _timeLeftPlayer2 == 0)) return;

    setState(() {
      _flipped[index] = true;
      _steps++;

      if (_previousIndex == null) {
        _previousIndex = index;
      } else {
        _waiting = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_numbers[_previousIndex!] == _numbers[index]) {
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
            _switchPlayer();
          }
          _previousIndex = null;
          _waiting = false;
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            '1 vs 1 Memory Game',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player Score Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoCard('Player 1', '$_scorePlayer1', Colors.green,
                      _currentPlayer == 1),
                  _buildInfoCard('Player 2', '$_scorePlayer2', Colors.blue,
                      _currentPlayer == 2),
                ],
              ),
              const SizedBox(height: 20),
              // Timer Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimerCard('Time', '$_timeLeftPlayer1', Colors.red,
                      _currentPlayer == 1),
                  _buildTimerCard('Time', '$_timeLeftPlayer2', Colors.red,
                      _currentPlayer == 2),
                ],
              ),
              const SizedBox(height: 20),
              // Game Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _numbers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: 0, end: _flipped[index] ? pi : 0),
                        duration: const Duration(milliseconds: 300),
                        builder: (BuildContext context, double value,
                            Widget? child) {
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, Color color, bool isActive) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard(
      String label, String value, Color color, bool isActive) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      color: Colors.blueGrey[300],
      child: const Center(
        child: Icon(
          Icons.question_mark,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCardBack(int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      color: Colors.white,
      child: Center(
        child: Text(
          '${_numbers[index]}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}
