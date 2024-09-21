import 'package:flutter/material.dart';

class CompactPlayerCardOnline extends StatelessWidget {
  final String player;
  final int score;
  final bool isActive;
  final Color color;

  const CompactPlayerCardOnline({
    super.key,
    required this.player,
    required this.score,
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
          Text(
            'Score: $score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
