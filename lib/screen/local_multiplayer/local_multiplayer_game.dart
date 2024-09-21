import 'dart:async';
import 'dart:math';
import 'package:card/components/components.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            buildBackgroundShapes(),
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
                        buildPlayerCards(_scorePlayer1, _timeLeftPlayer1,
                            _scorePlayer2, _timeLeftPlayer2, _currentPlayer),
                        const SizedBox(height: 16),
                        buildProgressBar(_timeLeftPlayer1, _timeLeftPlayer2),
                        const SizedBox(height: 16),
                        Expanded(child: _buildGameGrid()),
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
            'Memory Game',
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
