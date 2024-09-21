import 'package:card/screen/local_multiplayer/GameController.dart';
import 'package:card/screen/single_player/MemoryGameScreen.dart';
import 'package:card/screen/online_multiplayer/online_multiplayer_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildBeautifulTitle(),
                  const SizedBox(height: 60),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildButton(
                          context,
                          'Single Player',
                          Icons.person,
                          const Color(0xFFE57373),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MemoryGameScreen()),
                          ),
                        ),
                        _buildButton(context, 'Local Multiplayer', Icons.people,
                            const Color(0xFF81C784), () {
                          Get.delete<GameController>();
                          Get.toNamed('/local-multiplayer');
                        }
                            // () => Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           LocalMultiplayerGameScreen()),
                            // ),
                            ),
                        _buildButton(
                          context,
                          'Online Multiplayer',
                          Icons.cloud,
                          const Color(0xFFFFB74D),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const OnlineMultiplayerGameScreen()),
                          ),
                        ),
                        _buildButton(
                          context,
                          'About',
                          Icons.info,
                          const Color(0xFFBA68C8),
                          _launchURL,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildBeautifulTitle() {
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

  Widget _buildButton(BuildContext context, String text, IconData icon,
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

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://houssameddine.netlify.app');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
