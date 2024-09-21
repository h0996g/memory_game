import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

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
                        _buildTimerSection(),
                        const SizedBox(height: 16),
                        _buildScoreAndSteps(),
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

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Time Left',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_timeLeft',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _timeLeft <= 10 ? Colors.red : const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _timeLeft / 60,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeLeft <= 10 ? Colors.red : const Color(0xFFFF9800),
            ),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreAndSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(Icons.star, 'Score', '$_score/$_totalPairs'),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _buildInfoItem(Icons.directions_walk, 'Steps', '$_steps'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF9800), size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
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

  // ... (keep all other methods)
}
