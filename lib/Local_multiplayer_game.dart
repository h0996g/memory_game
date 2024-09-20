import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class LocalMultiplayerGameScreen extends StatefulWidget {
  const LocalMultiplayerGameScreen({super.key});

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
        preferredSize: const Size.fromHeight(56),
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
            'Memory Game',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100, // Fixed height for player cards
              child: Row(
                children: [
                  Expanded(
                    child: CompactPlayerCard(
                      player: 'Player 1',
                      score: _scorePlayer1,
                      timeLeft: _timeLeftPlayer1,
                      isActive: _currentPlayer == 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CompactPlayerCard(
                      player: 'Player 2',
                      score: _scorePlayer2,
                      timeLeft: _timeLeftPlayer2,
                      isActive: _currentPlayer == 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_timeLeftPlayer1 + _timeLeftPlayer2) / 60,
              backgroundColor: Colors.blue.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
            ),
            const SizedBox(height: 8),
            // Game Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double gridWidth = constraints.maxWidth;
                  double gridHeight = constraints.maxHeight;
                  double itemSize = gridWidth / 4; // 4 is the number of columns
                  int rowCount = (gridHeight / itemSize).floor();

                  // Ensure we don't create more rows than necessary
                  rowCount = min(rowCount, (_numbers.length / 4).ceil());

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: rowCount *
                        4, // Ensure we don't create more items than necessary
                    itemBuilder: (context, index) {
                      if (index >= _numbers.length) {
                        return const SizedBox(); // Empty space for extra cells
                      }
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
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.blueGrey[100],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.blueGrey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.question_mark,
            size: 40,
            color: Colors.blueGrey[600],
          ),
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

class CompactPlayerCard extends StatelessWidget {
  final String player;
  final int score;
  final int timeLeft;
  final bool isActive;

  const CompactPlayerCard({
    super.key,
    required this.player,
    required this.score,
    required this.timeLeft,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isActive ? Border.all(color: Colors.blue.shade500, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            player,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Score',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Colors.blue.shade600
                          : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Time',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '${timeLeft}s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: timeLeft <= 10 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
