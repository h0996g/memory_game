import 'package:card/widget/compact_player_card.dart';
import 'package:flutter/material.dart';

Widget buildProgressBar(_timeLeftPlayer1, _timeLeftPlayer2) {
  return LinearProgressIndicator(
    value: (_timeLeftPlayer1 + _timeLeftPlayer2) / 60,
    backgroundColor: const Color(0xFFFFCCBC).withOpacity(0.3),
    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
  );
}

Widget buildBackgroundShapes() {
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

Widget buildPlayerCards(_scorePlayer1, _timeLeftPlayer1, _scorePlayer2,
    _timeLeftPlayer2, _currentPlayer) {
  return Row(
    children: [
      Expanded(
        child: CompactPlayerCard(
          player: 'Player 1',
          score: _scorePlayer1,
          timeLeft: _timeLeftPlayer1,
          isActive: _currentPlayer == 1,
          color: const Color(0xFFE57373),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CompactPlayerCard(
          player: 'Player 2',
          score: _scorePlayer2,
          timeLeft: _timeLeftPlayer2,
          isActive: _currentPlayer == 2,
          color: const Color(0xFF81C784),
        ),
      ),
    ],
  );
}

Widget buildCardFront() {
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

Widget buildCardBack(int index, _numbers) {
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
