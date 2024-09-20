import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  final int _numPairs = 8;
  late List<int> _numbers;
  late List<bool> _flipped;
  int? _previousIndex;
  bool _waiting = false;
  int _score = 0;
  int _steps = 0;
  int _totalPairs = 8;
  int _timeLeft = 60;
  Timer? _timer;
  bool _isGameActive = true;

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
    _score = 0;
    _steps = 0;
    _timeLeft = 60;
    _isGameActive = true;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _isGameActive = false;
        _showGameOverDialog();
      }
    });
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
            'Time\'s Up!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Your score: $_score/$_totalPairs\nSteps: $_steps'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _initializeGame();
                });
              },
              child: const Text('Restart',
                  style: TextStyle(color: Colors.blueGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child:
                  const Text('Home', style: TextStyle(color: Colors.blueGrey)),
            ),
          ],
        );
      },
    );
  }

  void _onCardTap(int index) {
    if (_waiting || _flipped[index] || !_isGameActive) return;

    setState(() {
      _flipped[index] = true;

      if (_previousIndex == null) {
        _previousIndex = index;
        _steps++;
      } else {
        _waiting = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_numbers[_previousIndex!] == _numbers[index]) {
            _score++;
            if (_score == _totalPairs) {
              _timer?.cancel();
              _showWinDialog();
            }
          } else {
            _flipped[_previousIndex!] = false;
            _flipped[index] = false;
          }
          _previousIndex = null;
          _waiting = false;
          setState(() {});
        });
      }
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Congratulations!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'You won!\nScore: $_score/$_totalPairs\nSteps: $_steps\nTime left: $_timeLeft seconds'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _initializeGame();
                });
              },
              child: const Text('Play Again',
                  style: TextStyle(color: Colors.blueGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child:
                  const Text('Home', style: TextStyle(color: Colors.blueGrey)),
            ),
          ],
        );
      },
    );
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
            'Memory Game',
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
              // Timer Section (Circular Design)
              Container(
                width: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Time Left',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_timeLeft',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 10 ? Colors.red : Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _timeLeft /
                          60, // Assuming the total time is 60 seconds
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timeLeft <= 10 ? Colors.red : Colors.blueGrey,
                      ),
                      minHeight: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // Score and Steps Row
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueGrey[200]!, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoItem(Icons.star, 'Score', '$_score/$_totalPairs'),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.blueGrey[300],
                    ),
                    _buildInfoItem(Icons.directions_walk, 'Steps', '$_steps'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Game Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey[600], size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Center(
        child: Text(
          '${_numbers[index]}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
      ),
    );
  }
}
