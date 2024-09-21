import 'package:card/widget/compact_player_card.dart';
import 'package:flutter/material.dart';

Widget buildAppBar(String title, BuildContext context) {
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
        Text(
          title,
          style: const TextStyle(
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

//! -----------------------Home Screen-----------------------
Widget buildBeautifulTitle() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFF9800).withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          'Memory',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const Text(
          'Game',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 8,
          ),
        ),
      ],
    ),
  );
}

Widget buildButton(BuildContext context, String text, IconData icon,
    Color color, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 18),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
//  -----------------------End of Home Screen-----------------------

//!------------------------Local Multiplayer Game------------------------
Widget buildProgressBar(timeLeftPlayer1, timeLeftPlayer2) {
  return LinearProgressIndicator(
    value: (timeLeftPlayer1 + timeLeftPlayer2) / 60,
    backgroundColor: const Color(0xFFFFCCBC).withOpacity(0.3),
    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
  );
}

Widget buildPlayerCards(scorePlayer1, timeLeftPlayer1, scorePlayer2,
    timeLeftPlayer2, currentPlayer) {
  return Row(
    children: [
      Expanded(
        child: CompactPlayerCard(
          player: 'Player 1',
          score: scorePlayer1,
          timeLeft: timeLeftPlayer1,
          isActive: currentPlayer == 1,
          color: const Color(0xFFE57373),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CompactPlayerCard(
          player: 'Player 2',
          score: scorePlayer2,
          timeLeft: timeLeftPlayer2,
          isActive: currentPlayer == 2,
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

Widget buildCardBack(int index, numbers) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    color: const Color(0xFFFF9800),
    child: Center(
      child: Text(
        '${numbers[index]}',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

// -----------------------End of Local Multiplayer Game-----------------------

//! -----------------------Single Player Game-----------------------
Widget buildTimerSection(timeLeft) {
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
          '$timeLeft',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: timeLeft <= 10 ? Colors.red : const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: timeLeft / 60,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            timeLeft <= 10 ? Colors.red : const Color(0xFFFF9800),
          ),
          minHeight: 10,
        ),
      ],
    ),
  );
}

Widget buildScoreAndSteps(score, totalPairs, steps) {
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
        buildInfoItem(Icons.star, 'Score', '$score/$totalPairs'),
        Container(height: 30, width: 1, color: Colors.grey[300]),
        buildInfoItem(Icons.directions_walk, 'Steps', '$steps'),
      ],
    ),
  );
}

Widget buildInfoItem(IconData icon, String label, String value) {
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

// -----------------------End of Single Player Game-----------------------