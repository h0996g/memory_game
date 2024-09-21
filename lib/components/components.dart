import 'package:card/widget/compact_player_card.dart';
import 'package:card/widget/compact_player_card_online.dart';
import 'package:flutter/material.dart';

Widget buildAppBar(String title, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDarkMode
            ? [Colors.grey[900]!, Colors.grey[800]!]
            : [const Color(0xFFFF9800), const Color(0xFFFF5722)],
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

Widget buildBackgroundShapes(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Stack(
    children: [
      Positioned(
        top: -50,
        left: -50,
        child: _buildShape(
            200,
            isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : const Color(0xFFFFCCBC).withOpacity(0.5),
            context),
      ),
      Positioned(
        bottom: -30,
        right: -30,
        child: _buildShape(
            150,
            isDarkMode
                ? Colors.grey[700]!.withOpacity(0.3)
                : const Color(0xFFB2DFDB).withOpacity(0.5),
            context),
      ),
      Positioned(
        top: 100,
        right: -20,
        child: _buildShape(
            100,
            isDarkMode
                ? Colors.grey[600]!.withOpacity(0.3)
                : const Color(0xFFFFECB3).withOpacity(0.5),
            context),
      ),
    ],
  );
}

Widget _buildShape(double size, Color color, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.2)
              : color.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    ),
  );
}

//! -----------------------Home Screen-----------------------
Widget buildBeautifulTitle(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDarkMode
            ? [Colors.grey[800]!, Colors.grey[700]!]
            : [const Color(0xFFFF9800), const Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : const Color(0xFFFF9800).withOpacity(0.3),
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
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                    color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
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
                      color: isDarkMode ? Colors.white : Colors.grey[800],
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
Widget buildProgressBar(
    int timeLeftPlayer1, int timeLeftPlayer2, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return LinearProgressIndicator(
    value: (timeLeftPlayer1 + timeLeftPlayer2) / 60,
    backgroundColor: isDarkMode
        ? Colors.grey[700]!.withOpacity(0.3)
        : const Color(0xFFFFCCBC).withOpacity(0.3),
    valueColor: AlwaysStoppedAnimation<Color>(
      isDarkMode ? Colors.orange[300]! : const Color(0xFFFF9800),
    ),
  );
}

Widget buildPlayerCards(int scorePlayer1, int timeLeftPlayer1, int scorePlayer2,
    int timeLeftPlayer2, int currentPlayer, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Row(
    children: [
      Expanded(
        child: CompactPlayerCard(
          player: 'Player 1',
          score: scorePlayer1,
          timeLeft: timeLeftPlayer1,
          isActive: currentPlayer == 1,
          color: isDarkMode ? Colors.red[300]! : const Color(0xFFE57373),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CompactPlayerCard(
          player: 'Player 2',
          score: scorePlayer2,
          timeLeft: timeLeftPlayer2,
          isActive: currentPlayer == 2,
          color: isDarkMode ? Colors.green[300]! : const Color(0xFF81C784),
        ),
      ),
    ],
  );
}

Widget buildCardFront(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: isDarkMode ? Colors.grey[800] : Colors.white,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800), width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          size: 40,
          color: isDarkMode ? Colors.orange[300] : const Color(0xFFFF9800),
        ),
      ),
    ),
  );
}

Widget buildCardBack(int index, List<int> numbers, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    color: isDarkMode ? Colors.orange[700] : const Color(0xFFFF9800),
    child: Center(
      child: Text(
        '${numbers[index]}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.grey[900] : Colors.white,
        ),
      ),
    ),
  );
}
// -----------------------End of Local Multiplayer Game-----------------------

//! -----------------------Single Player Game-----------------------
Widget buildTimerSection(int timeLeft, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.2)
              : const Color(0xFFFF9800).withOpacity(0.3),
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
            color: isDarkMode ? Colors.white70 : Colors.grey[800],
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
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            timeLeft <= 10 ? Colors.red : const Color(0xFFFF9800),
          ),
          minHeight: 10,
        ),
      ],
    ),
  );
}

Widget buildScoreAndSteps(
    int score, int totalPairs, int steps, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.2)
              : const Color(0xFFFF9800).withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildInfoItem(
            Icons.star_rounded, 'Score', '$score/$totalPairs', context),
        Container(
            height: 30,
            width: 1,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
        buildInfoItem(Icons.scatter_plot_sharp, 'Steps', '$steps', context),
      ],
    ),
  );
}

Widget buildInfoItem(
    IconData icon, String label, String value, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}
// -----------------------End of Single Player Game-----------------------

// ! -----------------------Online Game-----------------------
Widget buildConnectionStatus(bool connectionTimedOut,
    VoidCallback connectToServer, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Connecting to server...',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.orange[100] : Colors.black,
        ),
      ),
      const SizedBox(height: 20),
      if (!connectionTimedOut)
        CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.orange[300]! : const Color(0xFFFF9800)))
      else
        buildButton2(
            'Retry Connection',
            Icons.refresh,
            isDarkMode ? Colors.orange[300]! : const Color(0xFFFF9800),
            connectToServer,
            context),
    ],
  );
}

Widget buildLobbyArea(
    TextEditingController roomIdController,
    String roomId,
    VoidCallback createRoom,
    VoidCallback joinRoom,
    bool isWaiting,
    BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      buildButton2(
        'Create Room',
        Icons.add,
        isDarkMode ? Colors.orange[300]! : const Color(0xFFFF9800),
        createRoom,
        context,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: roomIdController,
        decoration: InputDecoration(
          labelText: 'Room ID',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color:
                    isDarkMode ? Colors.orange[300]! : const Color(0xFFFF9800)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color:
                    isDarkMode ? Colors.orange[400]! : const Color(0xFFFF5722),
                width: 2),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
          labelStyle: TextStyle(
              color: isDarkMode ? Colors.orange[100] : Colors.grey[700]),
        ),
        style: TextStyle(color: isDarkMode ? Colors.orange[100] : Colors.black),
      ),
      const SizedBox(height: 20),
      buildButton2(
        'Join Room',
        Icons.login,
        isDarkMode ? Colors.orange[400]! : const Color(0xFFFF5722),
        joinRoom,
        context,
      ),
      if (roomId.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Room ID: $roomId',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.orange[100] : Colors.black,
            ),
          ),
        ),
      if (isWaiting)
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Waiting for opponent...',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: isDarkMode ? Colors.orange[200] : Colors.black54,
            ),
          ),
        ),
    ],
  );
}

Widget buildButton2(String text, IconData icon, Color color,
    VoidCallback onPressed, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    width: 250,
    height: 60,
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[850] : color,
      borderRadius: BorderRadius.circular(12),
      border: isDarkMode ? Border.all(color: color, width: 2) : null,
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : color.withOpacity(0.3),
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
              Icon(icon, color: isDarkMode ? color : Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: isDarkMode ? color : Colors.white,
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

Widget buildPlayerCards2(int scorePlayer1, int scorePlayer2, int currentPlayer,
    BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Row(
    children: [
      Expanded(
        child: CompactPlayerCardOnline(
          player: 'Player 1',
          score: scorePlayer1,
          isActive: currentPlayer == 1,
          color: isDarkMode ? Colors.orange[300]! : const Color(0xFFFF9800),
          isDarkMode: isDarkMode,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CompactPlayerCardOnline(
          player: 'Player 2',
          score: scorePlayer2,
          isActive: currentPlayer == 2,
          color: isDarkMode ? Colors.orange[400]! : const Color(0xFFFF5722),
          isDarkMode: isDarkMode,
        ),
      ),
    ],
  );
}

Widget buildTurnIndicator(bool isMyTurn, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: isDarkMode
          ? Colors.grey[850]
          : (isMyTurn ? const Color(0xFFFF9800) : const Color(0xFFFF5722)),
      borderRadius: BorderRadius.circular(12),
      border: isDarkMode
          ? Border.all(
              color: isMyTurn ? Colors.orange[300]! : Colors.orange[100]!,
              width: 2,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      isMyTurn ? 'Your Turn' : 'Opponent\'s Turn',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode
            ? (isMyTurn ? Colors.orange[300] : Colors.orange[100])
            : Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
