import 'package:card/home.dart';
import 'package:card/screen/local_multiplayer/local_multiplayer_game.dart';
import 'package:card/screen/single_player/MemoryGameScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(187, 255, 86, 34), // Orange color
    statusBarIconBrightness: Brightness.light, // For light icons
  ));
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      routes: {
        '/': (context) => HomePage(),
        '/local-multiplayer': (context) => LocalMultiplayerGameScreen(),
        '/single-player': (context) => MemoryGameScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Number Memory Game',
      theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            iconTheme: const IconThemeData(color: Colors.black),
            // color: Colors.white,
            backgroundColor: Colors.brown[800], // Primary color for the app bar

            titleTextStyle: const TextStyle(fontSize: 30, color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
          scaffoldBackgroundColor: Colors.white),
      // home: const HomePage(),
    );
  }
}
