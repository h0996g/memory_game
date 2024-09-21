import 'package:flutter/material.dart';

class CompactPlayerCard extends StatelessWidget {
  final String player;
  final int score;
  final int timeLeft;
  final bool isActive;
  final Color color;

  const CompactPlayerCard({
    super.key,
    required this.player,
    required this.score,
    required this.timeLeft,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isActive ? color : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
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
              color: color,
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
                      color: color,
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
                      color:
                          timeLeft <= 10 ? Colors.red : const Color(0xFF81C784),
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
