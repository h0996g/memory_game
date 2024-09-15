import 'package:card/Local_multiplayer_game.dart';
import 'package:card/MemoryGameScreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200], // Simple background color
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Memory Game',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Classic black text
                ),
              ),
              const SizedBox(height: 80),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(
                        context,
                        'Single Player',
                        Icons.person,
                        Colors.teal, // Changed button color
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MemoryGameScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        'Local Multiplayer',
                        Icons.people,
                        Colors.indigo, // Changed button color
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LocalMultiplayerGameScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        'Online Multiplayer',
                        Icons.cloud,
                        Colors.deepOrange, // Changed button color
                        () {
                          // TODO: Implement online multiplayer
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Online Multiplayer coming soon!')),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        'About',
                        Icons.info,
                        Colors.brown, // Changed button color
                        () {
                          _launchURL();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return Container(
      width: 250,
      height: 60,
      decoration: BoxDecoration(
        color: color, // Button color
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
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

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://houssameddine.netlify.app');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
